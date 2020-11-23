part of pulmonary_monitor_app;

/// This class implements the sensing layer incl. setting up
/// a [Study] with [MeasureTask]s and [Measure]s.
class Sensing implements StudyManager {
  Study study;
  StudyController controller;

  /// the list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes =>
      (controller != null) ? controller.executor.probes : List();

  Sensing() : super() {
    // create and register external sampling packages
    //SamplingPackageRegistry.register(ConnectivitySamplingPackage());
    SamplingPackageRegistry().register(ContextSamplingPackage());
    //SamplingPackageRegistry.register(CommunicationSamplingPackage());
    SamplingPackageRegistry().register(AudioSamplingPackage());
    SamplingPackageRegistry().register(SurveySamplingPackage());
    //SamplingPackageRegistry.register(HealthSamplingPackage());

    // create and register external data managers
    DataManagerRegistry().register(CarpDataManager());
  }

  /// Start sensing.
  Future<void> start() async {
    // Get the study.
    study = await this.getStudy(settings.studyId);

    // Create a Study Controller that can manage this study, initialize it, and start it.
    controller = StudyController(study);
    await controller.initialize();

    // start sensing
    controller.resume();

    // listening on all data events from the study and print it (for debugging purpose).
    controller.events.forEach(print);
  }

  /// Stop sensing.
  void stop() async {
    controller.stop();
    study = null;
  }

  Future<void> initialize() => null;

  Future<Study> getStudy(String studyId) async {
    return _getPulmonaryStudy(studyId);
  }

  Future<Study> _getPulmonaryStudy(String studyId) async {
    if (study == null) {
      study = Study(studyId, await settings.userId)
        ..name = 'Pulmonary Monitor'
        ..description =
            "With the Pulmonary Monitor you can monitor your respiratory health. "
                "By using the phones sensors, including the microphone, it will try to monitor you breathing, heart rate, sleep, social contact to others, and your movement. "
                "You will also be able to fill in a simple daily survey to help us understand how you're doing. "
                "Before you start, please also fill in the demographich survey. "
        ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
        // collect basic device measures continously
        ..addTriggerTask(
            ImmediateTrigger(),
            AutomaticTask()
              ..measures = SamplingSchema.debug().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  SensorSamplingPackage.LIGHT,
                  SensorSamplingPackage.PEDOMETER,
                  DeviceSamplingPackage.MEMORY,
                  DeviceSamplingPackage.DEVICE,
                  DeviceSamplingPackage.BATTERY,
                  DeviceSamplingPackage.SCREEN,
                ],
              ))
        // collect location, weather and air quality every 5 minutes
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(minutes: 5)),
            Task()
              ..measures = SamplingSchema.common().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  ContextSamplingPackage.LOCATION,
                  ContextSamplingPackage.WEATHER,
                  ContextSamplingPackage.AIR_QUALITY,
                ],
              ))
        // collect location and activity measures continously (event-based)
        ..addTriggerTask(
            ImmediateTrigger(),
            Task()
              ..measures = SamplingSchema.common().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  ContextSamplingPackage.GEOLOCATION,
                  ContextSamplingPackage.ACTIVITY,
                ],
              ))
        // collect local weather and air quality as an app task
        ..addTriggerTask(
            ImmediateTrigger(),
            AppTask(
              type: UserTask.ONE_TIME_SENSING_TYPE,
              title: "Weather & Air Quality",
              description: "Collect local weather and air quality",
            )..measures = SamplingSchema.common().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  ContextSamplingPackage.WEATHER,
                  ContextSamplingPackage.AIR_QUALITY,
                ],
              ))
        // collect demographics once when the study starts
        ..addTriggerTask(
            ImmediateTrigger(),
            AppTask(
              type: SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE,
              title: surveys.demographics.title,
              description: surveys.demographics.description,
              minutesToComplete: surveys.demographics.minutesToComplete,
            )
              ..measures.add(RPTaskMeasure(
                MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                name: surveys.demographics.title,
                enabled: true,
                surveyTask: surveys.demographics.survey,
              ))
              ..measures.add(Measure(
                MeasureType(NameSpace.CARP, ContextSamplingPackage.LOCATION),
              )))
        // collect symptoms on a daily basis
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(days: 1)),
            AppTask(
              type: SurveyUserTask.SURVEY_TYPE,
              title: surveys.symptoms.title,
              description: surveys.symptoms.description,
              minutesToComplete: surveys.symptoms.minutesToComplete,
            )
              ..measures.add(RPTaskMeasure(
                MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                name: surveys.symptoms.title,
                enabled: true,
                surveyTask: surveys.symptoms.survey,
              ))
              ..measures.add(Measure(
                MeasureType(NameSpace.CARP, ContextSamplingPackage.LOCATION),
              )))
        // collect a coughing sample on a daily basis
        // also collect location, and local weather and air quality of this sample
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(days: 2)),
            AppTask(
              type: AudioUserTask.AUDIO_TYPE,
              title: "Coughing",
              description:
                  'In this small exercise we would like to collect sound samples of coughing.',
              instructions:
                  'Please press the record button below, and then cough 5 times.',
              minutesToComplete: 3,
            )
              ..measures.add(AudioMeasure(
                MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
                name: "Coughing",
                studyId: studyId,
              ))
              ..measures.add(Measure(
                MeasureType(NameSpace.CARP, ContextSamplingPackage.LOCATION),
                name: "Current location",
              ))
              ..measures.add(Measure(
                MeasureType(NameSpace.CARP, ContextSamplingPackage.WEATHER),
                name: "Local weather",
              ))
              ..measures.add(Measure(
                MeasureType(NameSpace.CARP, ContextSamplingPackage.AIR_QUALITY),
                name: "Local air quality location",
              )))
        // collect a reading / audio sample on a daily basis
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(days: 2)),
            AppTask(
              type: AudioUserTask.AUDIO_TYPE,
              title: "Reading",
              description:
                  'In this small exercise we would like to collect sound data while you are reading.',
              instructions:
                  'Please press the record button below, and then read the following text.\n\n'
                  'Many, many years ago lived an emperor, who thought so much of new clothes that he spent all his money in order to obtain them; his only ambition was to be always well dressed. '
                  'He did not care for his soldiers, and the theatre did not amuse him; the only thing, in fact, he thought anything of was to drive out and show a new suit of clothes. '
                  'He had a coat for every hour of the day; and as one would say of a king "He is in his cabinet," so one could say of him, "The emperor is in his dressing-room."',
              minutesToComplete: 3,
            )..measures.add(AudioMeasure(
                MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
                name: "Reading",
                studyId: studyId,
              )))
        // when the reading (audio) measure is collect, the add a user task to
        // collect location, and local weather and air quality
        ..addTriggerTask(
            ConditionalSamplingEventTrigger(
              measureType:
                  MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
              resumeCondition: (Datum datum) => true,
              pauseCondition: (Datum datum) => true,
            ),
            AppTask(
              type: UserTask.ONE_TIME_SENSING_TYPE,
              title: "Location, Weather & Air Quality",
              description: "Collect location, weather and air quality",
            )..measures = SamplingSchema.common().getMeasureList(
                namespace: NameSpace.CARP,
                types: [
                  ContextSamplingPackage.LOCATION,
                  ContextSamplingPackage.WEATHER,
                  ContextSamplingPackage.AIR_QUALITY,
                ],
              ));
    }

    return study;
  }

  Future<Study> _getConditionalStudy(String studyId) async {
    if (study == null) {
      study = Study(studyId, await settings.userId)
            ..name = 'Conditional Monitor'
            ..description = 'This is a test study.'
            ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
            ..addTriggerTask(
                ConditionalSamplingEventTrigger(
                  measureType:
                      MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                  resumeCondition: (Datum datum) => true,
                  pauseCondition: (Datum datum) => true,
                ),
                AppTask(
                  type: UserTask.ONE_TIME_SENSING_TYPE,
                  title: "Weather & Air Quality",
                  description: "Collect local weather and air quality",
                )..measures = SamplingSchema.common().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      ContextSamplingPackage.WEATHER,
                      ContextSamplingPackage.AIR_QUALITY,
                    ],
                  ))
            ..addTriggerTask(
                ImmediateTrigger(),
                AppTask(
                  type: UserTask.ONE_TIME_SENSING_TYPE,
                  title: "Location",
                  description: "Collect current location",
                )..measures = SamplingSchema.common().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      ContextSamplingPackage.LOCATION,
                    ],
                  ))
            ..addTriggerTask(
                ImmediateTrigger(),
                AppTask(
                  type: SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE,
                  title: surveys.demographics.title,
                  description: surveys.demographics.description,
                  minutesToComplete: surveys.demographics.minutesToComplete,
                )
                  ..measures.add(RPTaskMeasure(
                    MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                    name: surveys.demographics.title,
                    enabled: true,
                    surveyTask: surveys.demographics.survey,
                  ))
                  ..measures.add(Measure(
                    MeasureType(
                        NameSpace.CARP, ContextSamplingPackage.LOCATION),
                  )))
//
            ..addTriggerTask(
                PeriodicTrigger(period: Duration(minutes: 1)),
                AppTask(
                  type: SurveyUserTask.SURVEY_TYPE,
                  title: surveys.symptoms.title,
                  description: surveys.symptoms.description,
                  minutesToComplete: surveys.symptoms.minutesToComplete,
                )
                  ..measures.add(RPTaskMeasure(
                    MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                    name: surveys.symptoms.title,
                    enabled: true,
                    surveyTask: surveys.symptoms.survey,
                  ))
                  ..measures.add(Measure(
                    MeasureType(
                        NameSpace.CARP, ContextSamplingPackage.LOCATION),
                  )))
          // ..addTriggerTask(
          //     PeriodicTrigger(period: Duration(minutes: 2)),
          //     AppTask(
          //       type: AudioUserTask.AUDIO_TYPE,
          //       title: "Coughing",
          //       description:
          //           'In this small exercise we would like to collect sound samples of coughing.',
          //       instructions:
          //           'Please press the record button below, and then cough 5 times.',
          //       minutesToComplete: 3,
          //     )
          //       ..measures.add(AudioMeasure(
          //         MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
          //         name: "Coughing",
          //         studyId: studyId,
          //       ))
          //       ..measures.add(Measure(
          //         MeasureType(
          //             NameSpace.CARP, ContextSamplingPackage.LOCATION),
          //         name: "Current location",
          //       )))
          // ..addTriggerTask(
          //     PeriodicTrigger(period: Duration(minutes: 2)),
          //     AppTask(
          //       type: AudioUserTask.AUDIO_TYPE,
          //       title: "Reading",
          //       description:
          //           'In this small exercise we would like to collect sound data while you are reading.',
          //       instructions:
          //           'Please press the record button below, and then read the following text.\n\n'
          //           'Many, many years ago lived an emperor, who thought so much of new clothes that he spent all his money in order to obtain them; his only ambition was to be always well dressed. '
          //           'He did not care for his soldiers, and the theatre did not amuse him; the only thing, in fact, he thought anything of was to drive out and show a new suit of clothes. '
          //           'He had a coat for every hour of the day; and as one would say of a king "He is in his cabinet," so one could say of him, "The emperor is in his dressing-room."',
          //       minutesToComplete: 3,
          //     )
          //       ..measures.add(AudioMeasure(
          //         MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
          //         name: "Reading",
          //         studyId: studyId,
          //       ))
          //       ..measures.add(Measure(
          //         MeasureType(
          //             NameSpace.CARP, ContextSamplingPackage.LOCATION),
          //         name: "Current location",
          //       )))

          //
          ;
    }
    return study;
  }

  /// Return a [DataEndPoint] of the specified type.
  DataEndPoint getDataEndpoint(String type) {
    assert(type != null);
    switch (type) {
      case DataEndPointTypes.PRINT:
        return new DataEndPoint(DataEndPointTypes.PRINT);
      case DataEndPointTypes.FILE:
        return FileDataEndPoint(
            bufferSize: 50 * 1000, zip: true, encrypt: false);
      case DataEndPointTypes.CARP:
        return CarpDataEndPoint(CarpUploadMethod.DATA_POINT,
            name: 'CARP Staging Server',
            uri: settings.uri,
            clientId: settings.clientID,
            clientSecret: settings.clientSecret,
            email: settings.username,
            password: settings.password);
//        return CarpDataEndPoint(
//          CarpUploadMethod.BATCH_DATA_POINT,
//          name: 'CARP Staging Server',
//          uri: uri,
//          clientId: clientID,
//          clientSecret: clientSecret,
//          email: username,
//          password: password,
//          bufferSize: 40 * 1000,
//          zip: false,
//          deleteWhenUploaded: false,
//        );
//        return CarpDataEndPoint(
//          CarpUploadMethod.FILE,
//          name: 'CARP Staging Server',
//          uri: uri,
//          clientId: clientID,
//          clientSecret: clientSecret,
//          email: username,
//          password: password,
//          bufferSize: 20 * 1000,
//          zip: true,
//          deleteWhenUploaded: false,
//        );
      default:
        return new DataEndPoint(DataEndPointTypes.PRINT);
    }
  }
}

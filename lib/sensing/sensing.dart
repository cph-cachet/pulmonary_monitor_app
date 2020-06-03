part of pulmonary_monitor_app;

/// This class implements the sensing layer incl. setting up a [Study] with [MeasureTask]s and [Measure]s.
class Sensing {
  Study study;

  StudyController controller;
  StudyManager mock = new StudyMock();

  /// the list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes => (controller != null) ? controller.executor.probes : List();

  Sensing() : super() {
    // create and register external sampling packages
    //SamplingPackageRegistry.register(ConnectivitySamplingPackage());
    SamplingPackageRegistry.register(ContextSamplingPackage());
    //SamplingPackageRegistry.register(CommunicationSamplingPackage());
    SamplingPackageRegistry.register(AudioSamplingPackage());
    SamplingPackageRegistry.register(SurveySamplingPackage());
    //SamplingPackageRegistry.register(HealthSamplingPackage());

    // create and register external data managers
    DataManagerRegistry.register(CarpDataManager());
  }

  /// Start sensing.
  Future<void> start() async {
    // Get the study.
    study = await mock.getStudy(settings.studyId);

    // Create a Study Controller that can manage this study, initialize it, and start it.
    controller = StudyController(study, debugLevel: DebugLevel.DEBUG);
    //controller = StudyController(study, samplingSchema: aware); // a controller using the AWARE test schema
    //controller = StudyController(study, privacySchemaName: PrivacySchema.DEFAULT); // a controller w. privacy
    await controller.initialize();

    controller.resume();

    // listening on all data events from the study and print it (for debugging purpose).
    controller.events.forEach(print);

    // listening on a specific probe
    //ProbeRegistry.probes[DataType.LOCATION].events.forEach(print);

    // listening on data manager events
    // controller.dataManager.events.forEach(print);
  }

  /// Stop sensing.
  void stop() async {
    controller.stop();
    study = null;
  }
}

/// Used as a mock [StudyManager] to generate a local [Study].
class StudyMock implements StudyManager {
  Future<void> initialize() {}

  Study _study;

  Future<Study> getStudy(String studyId) async {
    return _getPulmonaryStudy(studyId);
  }

  Future<Study> _getPulmonaryStudy(String studyId) async {
    if (_study == null) {
      _study = Study(studyId, await settings.userId)
            ..name = 'Pulmonary Monitor'
            ..description = "With the Pulmonary Monitor you can monitor your respiratory health. "
                "By using the phones sensors, including the microphone, it will try to monitor you breathing, heart rate, sleep, social contact to others, and your movement. "
                "You will also be able to fill in a simple daily survey to help us understand how you're doing. "
                "Before you start, please also fill in the demographich survey. "
            ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
            ..addTriggerTask(
                ImmediateTrigger(),
                AutomaticTask()
                  ..measures = SamplingSchema.debug().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      //SensorSamplingPackage.ACCELEROMETER,
                      //SensorSamplingPackage.GYROSCOPE,
                      SensorSamplingPackage.LIGHT,
                      SensorSamplingPackage.PEDOMETER,
                    ],
                  ))
            //TODO - add when the RxDart issue w. survey package is fixed
//            ..addTriggerTask(
//                DelayedTrigger(delay: 10 * 1000),
//                Task()
//                  ..measures = SamplingSchema.common().getMeasureList(
//                    namespace: NameSpace.CARP,
//                    types: [
//                      ConnectivitySamplingPackage.BLUETOOTH,
//                      ConnectivitySamplingPackage.WIFI,
//                      ConnectivitySamplingPackage.CONNECTIVITY,
//                    ],
//                  ))
//        ..addTriggerTask(
//            ImmediateTrigger(),
//            Task()
//              ..measures = SamplingSchema.common().getMeasureList(
//                namespace: NameSpace.CARP,
//                types: [
//                  AppsSamplingPackage.APP_USAGE,
//                  AppsSamplingPackage.APPS,
//                ],
//              ))
            ..addTriggerTask(
                ImmediateTrigger(),
                AutomaticTask()
                  ..measures = SamplingSchema.common().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      DeviceSamplingPackage.MEMORY,
                      DeviceSamplingPackage.DEVICE,
                      DeviceSamplingPackage.BATTERY,
                      DeviceSamplingPackage.SCREEN,
                    ],
                  ))
//            ..addTriggerTask(
//                PeriodicTrigger(period: 1 * 20 * 1000),
//                Task()
//                  ..measures = SamplingSchema.common().getMeasureList(
//                    namespace: NameSpace.CARP,
//                    types: [
//                      ContextSamplingPackage.LOCATION,
//                      //ContextSamplingPackage.WEATHER,
//                      //ContextSamplingPackage.AIR_QUALITY,
//                    ],
//                  ))
//            ..addTriggerTask(
//                ImmediateTrigger(),
//                Task()
//                  ..measures = SamplingSchema.common().getMeasureList(
//                    namespace: NameSpace.CARP,
//                    types: [
//                      //ContextSamplingPackage.LOCATION,
//                      ContextSamplingPackage.GEOLOCATION,
//                      //ContextSamplingPackage.ACTIVITY,
//                      //ContextSamplingPackage.GEOFENCE,
//                    ],
//                  ))
            ..addTriggerTask(
                ImmediateTrigger(), // collect local weather and air quality as an app task
                AppTask(
                  name: "Weather & Air Quality",
                  description: "Collect local weather and air quality",
                  onResume: bloc.addSensingTask,
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
                  name: "Location",
                  description: "Collect current location",
                  onResume: bloc.addSensingTask,
                )..measures = SamplingSchema.common().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      ContextSamplingPackage.LOCATION,
                    ],
                  ))
            ..addTriggerTask(
                ImmediateTrigger(),
                AppTask(
                  name: surveys.demographics.title,
                  description: surveys.demographics.description,
                  minutesToComplete: surveys.demographics.minutesToComplete,
                  onResume: bloc.addTaskWithSurvey,
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
            ..addTriggerTask(
                // TODO make this a recurrent scheduled trigger, once pr. day
                PeriodicTrigger(period: Duration(seconds: 40)),
                AppTask(
                  name: surveys.symptoms.title,
                  description: surveys.symptoms.description,
                  minutesToComplete: surveys.symptoms.minutesToComplete,
                  onResume: bloc.addTaskWithSurvey,
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
            ..addTriggerTask(
                // TODO make this a recurrent scheduled trigger, once pr. day
                PeriodicTrigger(period: Duration(seconds: 30)),
                AppTask(
                  name: "Coughing",
                  description: 'In this small exercise we would like to collect sound samples of coughing.',
                  instructions: 'Please press the record button below, and then cough 5 times.',
                  minutesToComplete: 3,
                  onResume: bloc.addTaskWithAudio,
                )
                  ..measures.add(AudioMeasure(
                    MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
                    name: "Coughing",
                    studyId: studyId,
                  ))
                  ..measures.add(Measure(
                    MeasureType(NameSpace.CARP, ContextSamplingPackage.LOCATION),
                    name: "Current location",
                  )))
            ..addTriggerTask(
                // TODO make this a recurrent scheduled trigger, once pr. day
                PeriodicTrigger(period: Duration(seconds: 20)),
                AppTask(
                  name: "Reading",
                  description: 'In this small exercise we would like to collect sound data while you are reading.',
                  instructions: 'Please press the record button below, and then read the following text.\n\n'
                      'Many, many years ago lived an emperor, who thought so much of new clothes that he spent all his money in order to obtain them; his only ambition was to be always well dressed. '
                      'He did not care for his soldiers, and the theatre did not amuse him; the only thing, in fact, he thought anything of was to drive out and show a new suit of clothes. '
                      'He had a coat for every hour of the day; and as one would say of a king "He is in his cabinet," so one could say of him, "The emperor is in his dressing-room."',
                  minutesToComplete: 3,
                  onResume: bloc.addTaskWithAudio,
                )
                  ..measures.add(AudioMeasure(
                    MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
                    name: "Reading",
                    studyId: studyId,
                  ))
                  ..measures.add(Measure(
                    MeasureType(NameSpace.CARP, ContextSamplingPackage.LOCATION),
                    name: "Current location",
                  )))
//            ..addTriggerTask(
//                ImmediateTrigger(),
//                Task()
//                  ..measures = SamplingSchema.common().getMeasureList(
//                    namespace: NameSpace.CARP,
//                    types: [
//                      AudioSamplingPackage.NOISE,
//                    ],
//                  ))
//            ..addTriggerTask(
//                PeriodicTrigger(period: 5 * 60 * 1000, duration: 60 * 1000),
//                Task(name: 'Audio')
//                  ..measures
//                      .add(Measure(MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO), name: "Audio Recording")))
//            ..addTriggerTask(
//                PeriodicTrigger(period: 60 * 60 * 100),
//                Task('Health')
//                  ..addMeasure(HealthMeasure(MeasureType(NameSpace.CARP, HealthSamplingPackage.HEALTH),
//                      HealthDataType.STEPS, Duration(hours: 1)))
//                  ..addMeasure(HealthMeasure(MeasureType(NameSpace.CARP, HealthSamplingPackage.HEALTH),
//                      HealthDataType.HEART_RATE, Duration(hours: 1))))

//            ..addTriggerTask(
//                ImmediateTrigger(),
//                Task()
//                  ..measures = SamplingSchema.common().getMeasureList(
//                    namespace: NameSpace.CARP,
//                    types: [
//                      CommunicationSamplingPackage.CALENDAR,
//                      CommunicationSamplingPackage.TEXT_MESSAGE_LOG,
//                      CommunicationSamplingPackage.TEXT_MESSAGE,
//                      CommunicationSamplingPackage.PHONE_LOG,
//                      CommunicationSamplingPackage.TELEPHONY,
//                    ],
//                  ))
          //
          ;
    }
    return _study;
  }

  /// Return a [DataEndPoint] of the specified type.
  DataEndPoint getDataEndpoint(String type) {
    assert(type != null);
    switch (type) {
      case DataEndPointTypes.PRINT:
        return new DataEndPoint(DataEndPointTypes.PRINT);
      case DataEndPointTypes.FILE:
        return FileDataEndPoint(bufferSize: 50 * 1000, zip: true, encrypt: false);
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

SamplingSchema get aware => SamplingSchema()
  ..type = SamplingSchemaType.NORMAL
  ..name = 'AWARE equivalent sampling schema'
  ..description =
      'This Study is a technical evaluation of the CARP Mobile Sensing framework. It simulates the AWARE configuration in order to compare data sampling and battery drain.'
  ..powerAware = false
  ..measures.addEntries([
    MapEntry(
        SensorSamplingPackage.ACCELEROMETER,
        PeriodicMeasure(
          MeasureType(NameSpace.CARP, SensorSamplingPackage.ACCELEROMETER),
          name: "Accelerometer",
          enabled: true,
          frequency: Duration(milliseconds: 200), // How often to start a measure
          duration: Duration(milliseconds: 2), // Window size
        )),
    MapEntry(
        SensorSamplingPackage.GYROSCOPE,
        PeriodicMeasure(
          MeasureType(NameSpace.CARP, SensorSamplingPackage.GYROSCOPE),
          name: "Gyroscope",
          enabled: true,
          frequency: Duration(milliseconds: 200), // How often to start a measure
          duration: Duration(milliseconds: 2), // Window size
        )),
    MapEntry(
        SensorSamplingPackage.LIGHT,
        PeriodicMeasure(
          MeasureType(NameSpace.CARP, SensorSamplingPackage.LIGHT),
          name: "Ambient Light",
          frequency: Duration(seconds: 60), // How often to start a measure
          duration: Duration(seconds: 1), // Window size
        )),
    MapEntry(
        AppsSamplingPackage.APPS,
        Measure(
          MeasureType(NameSpace.CARP, AppsSamplingPackage.APPS),
          name: 'Installed Apps',
        )),
    MapEntry(AppsSamplingPackage.APP_USAGE,
        MarkedMeasure(MeasureType(NameSpace.CARP, AppsSamplingPackage.APP_USAGE), name: 'App Usage')),
    MapEntry(DeviceSamplingPackage.BATTERY,
        Measure(MeasureType(NameSpace.CARP, DeviceSamplingPackage.BATTERY), name: 'Battery')),
    MapEntry(DeviceSamplingPackage.SCREEN,
        Measure(MeasureType(NameSpace.CARP, DeviceSamplingPackage.SCREEN), name: 'Screen Activity (lock/on/off)')),
//    MapEntry(
//        ConnectivitySamplingPackage.BLUETOOTH,
//        PeriodicMeasure(MeasureType(NameSpace.CARP, ConnectivitySamplingPackage.BLUETOOTH),
//            name: 'Nearby Devices (Bluetooth Scan)', frequency: 60 * 1000, duration: 3 * 1000)),
//    MapEntry(
//        ConnectivitySamplingPackage.WIFI,
//        PeriodicMeasure(MeasureType(NameSpace.CARP, ConnectivitySamplingPackage.WIFI),
//            name: 'Wifi network names (SSID / BSSID)', frequency: 60 * 1000, duration: 5 * 1000)),
//    MapEntry(
//        CommunicationSamplingPackage.PHONE_LOG,
//        PhoneLogMeasure(MeasureType(NameSpace.CARP, CommunicationSamplingPackage.PHONE_LOG),
//            name: 'Phone Log', days: 1)),
//    MapEntry(
//        CommunicationSamplingPackage.TEXT_MESSAGE_LOG,
//        Measure(MeasureType(NameSpace.CARP, CommunicationSamplingPackage.TEXT_MESSAGE_LOG),
//            name: 'Text Message (SMS) Log')),
//    MapEntry(CommunicationSamplingPackage.TEXT_MESSAGE,
//        Measure(MeasureType(NameSpace.CARP, CommunicationSamplingPackage.TEXT_MESSAGE), name: 'Text Message (SMS)')),
    MapEntry(
        ContextSamplingPackage.LOCATION,
        LocationMeasure(MeasureType(NameSpace.CARP, ContextSamplingPackage.LOCATION),
            name: 'Location', enabled: true, frequency: 30 * 1000)),
    MapEntry(ContextSamplingPackage.ACTIVITY,
        Measure(MeasureType(NameSpace.CARP, ContextSamplingPackage.ACTIVITY), name: 'Activity Recognition')),
//    MapEntry(
//        ContextSamplingPackage.WEATHER,
//        WeatherMeasure(MeasureType(NameSpace.CARP, ContextSamplingPackage.WEATHER),
//            name: 'Local Weather', apiKey: '12b6e28582eb9298577c734a31ba9f4f')),
  ]);

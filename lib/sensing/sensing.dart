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
    controller = StudyController(study);
    //controller = StudyController(study, samplingSchema: aware); // a controller using the AWARE test schema
    //controller = StudyController(study, privacySchemaName: PrivacySchema.DEFAULT); // a controller w. privacy
    await controller.initialize();

    controller.start();

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

    //return _getCoverageStudy('#5-coverage');
    //return _getHighFrequencyStudy('DF#4dD-high-frequency');
    //return _getAllProbesAsAwareStudy('#4-aware-carp');
    //return _getAllMeasuresStudy(studyId);
    //return _getAllProbesAsAwareCarpUploadStudy();
    //return _getAudioStudy(studyId);
    //return _getESenseStudy(studyId);
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
                Task()
                  ..measures = SamplingSchema.common().getMeasureList(
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
                Task()
                  ..measures = SamplingSchema.common().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      DeviceSamplingPackage.MEMORY,
                      DeviceSamplingPackage.DEVICE,
                      DeviceSamplingPackage.BATTERY,
                      DeviceSamplingPackage.SCREEN,
                    ],
                  ))
            ..addTriggerTask(
                PeriodicTrigger(period: 60 * 60 * 1000), // collect local weather and air quality once pr. hour
                Task()
                  ..measures = SamplingSchema.common().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      ContextSamplingPackage.WEATHER,
                      ContextSamplingPackage.AIR_QUALITY,
                    ],
                  ))
            ..addTriggerTask(
                ImmediateTrigger(),
                Task()
                  ..measures = SamplingSchema.common().getMeasureList(
                    namespace: NameSpace.CARP,
                    types: [
                      //ContextSamplingPackage.LOCATION,
                      ContextSamplingPackage.GEOLOCATION,
                      //ContextSamplingPackage.ACTIVITY,  //TODO - update when Thomas' new package is loaded
                      //ContextSamplingPackage.GEOFENCE,
                    ],
                  ))
            ..addTriggerTask(
                ImmediateTrigger(),
                Task('Demographics Survey')
                  ..measures.add(RPTaskMeasure(
                    MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                    name: 'DEMO',
                    enabled: true,
                    surveyTask: surveys.demographics.survey,
                    onSurveyTriggered: bloc.onDemographicsSurveyTriggered,
                    onSurveySubmit: bloc.onSurveySubmit,
                  )))
            ..addTriggerTask(
                // TODO make this a recurrent scheduled trigger, once pr. day
                PeriodicTrigger(period: 60 * 1000),
                Task('WHO-5 Survey')
                  ..measures.add(RPTaskMeasure(
                    MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                    name: 'WHO5',
                    enabled: true,
                    surveyTask: surveys.who5.survey,
                    onSurveyTriggered: bloc.onWHO5SurveyTriggered,
                    onSurveySubmit: bloc.onSurveySubmit,
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
            ..addTriggerTask(
                PeriodicTrigger(period: 5 * 60 * 1000, duration: 60 * 1000),
                Task('Audio')
                  ..measures
                      .add(Measure(MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO), name: "Audio Recording")))
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
          frequency: 200, // How often to start a measure
          duration: 2, // Window size
        )),
    MapEntry(
        SensorSamplingPackage.GYROSCOPE,
        PeriodicMeasure(MeasureType(NameSpace.CARP, SensorSamplingPackage.GYROSCOPE),
            name: "Gyroscope",
            enabled: true,
            frequency: 200, // How often to start a measure
            duration: 2 // Window size
            )),
    MapEntry(
        SensorSamplingPackage.LIGHT,
        PeriodicMeasure(MeasureType(NameSpace.CARP, SensorSamplingPackage.LIGHT),
            name: "Ambient Light",
            frequency: 60 * 1000, // How often to start a measure
            duration: 1000 // Window size
            )),
    MapEntry(
        AppsSamplingPackage.APPS,
        Measure(
          MeasureType(NameSpace.CARP, AppsSamplingPackage.APPS),
          name: 'Installed Apps',
        )),
    MapEntry(
        AppsSamplingPackage.APP_USAGE,
        AppUsageMeasure(MeasureType(NameSpace.CARP, AppsSamplingPackage.APP_USAGE),
            // collect app usage every 10 min for the last 10 min
            name: 'Apps Usage',
            duration: 10 * 60 * 1000)),
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

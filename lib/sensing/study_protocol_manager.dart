/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of pulmonary_monitor_app;

/// This is a simple local [StudyProtocolManager].
///
/// This class shows how to configure a [StudyProtocol] with [Tigger]s,
/// [TaskDescriptor]s and [Measure]s.
class LocalStudyProtocolManager implements StudyProtocolManager {
  @override
  Future initialize() async {}

  /// Get a data endpoint for this study.
  DataEndPoint getDataEndpoint(String type) {
    switch (type) {
      case DataEndPointTypes.SQLITE:
        return SQLiteDataEndPoint();
      case DataEndPointTypes.FILE:
        return FileDataEndPoint(
          bufferSize: 50 * 1000,
          zip: true,
          encrypt: false,
        );
      case DataEndPointTypes.CARP:
        return CarpDataEndPoint(
            uploadMethod: CarpUploadMethod.DATA_POINT,
            name: 'CARP Production Server',
            uri: uri,
            clientId: clientID,
            clientSecret: clientSecret,
            email: username,
            password: password);
      default:
        return DataEndPoint(type: type);
    }
  }

  /// Create a new CAMS study protocol.
  @override
  Future<SmartphoneStudyProtocol> getStudyProtocol(String studyId) async {
    SmartphoneStudyProtocol protocol = SmartphoneStudyProtocol(
      name: 'Pulmonary Monitor',
      ownerId: 'alex@uni.dk',
    );
    protocol.protocolDescription = StudyDescription(
        title: 'Pulmonary Monitor',
        description:
            "With the Pulmonary Monitor you can monitor your respiratory health. "
            "By using the phones sensors, including the microphone, it will try to monitor you breathing, heart rate, sleep, social contact to others, and your movement. "
            "You will also be able to fill in a simple daily survey to help us understand how you're doing. "
            "Before you start, please also fill in the demographich survey. ",
        purpose:
            'To collect basic data from users in their everyday life in order '
            'to investigate pulmonary-related symptoms.',
        responsible: StudyResponsible(
          id: 'jakba',
          title: 'Professor',
          address: 'Ørsteds Plads, 2100 Kgs. Lyngby',
          affiliation: 'Technical University of Denmark',
          email: 'jakba@dtu.dk',
          name: 'Jakob E. Bardram',
        ));

    // define the data end point , i.e., where to store data
    protocol.dataEndPoint = getDataEndpoint(DataEndPointTypes.SQLITE);

    // define which devices are used for data collection.
    Smartphone phone = Smartphone();
    protocol.addMasterDevice(phone);

    // Define the online weather service and add it as a 'device'
    WeatherService weatherService =
        WeatherService(apiKey: '12b6e28582eb9298577c734a31ba9f4f');
    protocol.addConnectedDevice(weatherService);

    // Define the online air quality service and add it as a 'device'
    AirQualityService airQualityService =
        AirQualityService(apiKey: '9e538456b2b85c92647d8b65090e29f957638c77');
    protocol.addConnectedDevice(airQualityService);

    // build-in measure from sensor and device sampling packages
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        BackgroundTask()
          ..addMeasures([
            Measure(type: SensorSamplingPackage.PEDOMETER),
            Measure(type: SensorSamplingPackage.LIGHT),
            Measure(type: DeviceSamplingPackage.SCREEN),
            Measure(type: DeviceSamplingPackage.MEMORY),
            Measure(type: DeviceSamplingPackage.BATTERY),
          ]),
        phone);

    // activity measure using the phone
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        BackgroundTask()
          ..addMeasure(Measure(type: ContextSamplingPackage.ACTIVITY)),
        phone);

    // Define the online location service and add it as a 'device'
    LocationService locationService = LocationService();
    protocol.addConnectedDevice(locationService);

    // Add a background task that continously collects geolocation and mobility
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        BackgroundTask()
          ..addMeasure(Measure(type: ContextSamplingPackage.GEOLOCATION))
          ..addMeasure(Measure(type: ContextSamplingPackage.MOBILITY)),
        locationService);

    // collect demographics & location once the study starts
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        RPAppTask(
            type: SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE,
            title: surveys.demographics.title,
            description: surveys.demographics.description,
            minutesToComplete: surveys.demographics.minutesToComplete,
            notification: true,
            rpTask: surveys.demographics.survey)
          ..addMeasure(Measure(type: ContextSamplingPackage.LOCATION)),
        phone);

    // collect symptoms daily at 13:30
    protocol.addTriggeredTask(
        RecurrentScheduledTrigger(
          type: RecurrentType.daily,
          time: TimeOfDay(hour: 13, minute: 30),
        ),
        RPAppTask(
            type: SurveyUserTask.SURVEY_TYPE,
            title: surveys.symptoms.title,
            description: surveys.symptoms.description,
            minutesToComplete: surveys.symptoms.minutesToComplete,
            rpTask: surveys.symptoms.survey)
          ..addMeasure(Measure(type: ContextSamplingPackage.LOCATION)),
        phone);

    // perform a cognitive assessment
    protocol.addTriggeredTask(
        IntervalTrigger(period: Duration(hours: 2)),
        RPAppTask(
            type: SurveyUserTask.COGNITIVE_ASSESSMENT_TYPE,
            title: surveys.cognition.title,
            description: surveys.cognition.description,
            minutesToComplete: surveys.cognition.minutesToComplete,
            rpTask: surveys.cognition.survey)
          ..addMeasure(Measure(type: ContextSamplingPackage.LOCATION)),
        phone);

    // perform a Parkisons' assessment
    protocol.addTriggeredTask(
        IntervalTrigger(period: Duration(hours: 2)),
        RPAppTask(
            type: SurveyUserTask.COGNITIVE_ASSESSMENT_TYPE,
            title: "Parkinsons' Assessment",
            description: "A simple task assessing finger tapping speed.",
            minutesToComplete: 3,
            rpTask: RPOrderedTask(
              identifier: "parkinsons_assessment",
              steps: [
                RPInstructionStep(
                    identifier: 'parkinsons_instruction',
                    title: "Parkinsons' Disease Assessment",
                    text:
                        "In the following pages, you will be asked to solve two simple test which will help assess your symptoms on a daily basis. "
                        "Each test has an instruction page, which you should read carefully before starting the test.\n\n"
                        "Please sit down comfortably and hold the phone in one hand while performing the test with the other."),
                RPFlankerActivity(
                  'flanker_1',
                  lengthOfTest: 30,
                  numberOfCards: 10,
                ),
                RPTappingActivity(
                  'tapping_1',
                  lengthOfTest: 10,
                )
              ],
            ))
          ..addMeasures([
            Measure(type: SensorSamplingPackage.ACCELEROMETER),
            Measure(type: SensorSamplingPackage.GYROSCOPE),
          ]),
        phone);

    // collect a coughing sample on a daily basis
    // also collect location, and local weather and air quality of this sample
    protocol.addTriggeredTask(
        IntervalTrigger(period: Duration(days: 1)),
        AppTask(
          type: AudioUserTask.AUDIO_TYPE,
          title: "Coughing",
          description:
              'In this small exercise we would like to collect sound samples of coughing.',
          instructions:
              'Please press the record button below, and then cough 5 times.',
          minutesToComplete: 3,
          notification: true,
        )..addMeasures(
            [
              Measure(type: MediaSamplingPackage.AUDIO),
              Measure(type: ContextSamplingPackage.LOCATION),
              Measure(type: ContextSamplingPackage.WEATHER),
              Measure(type: ContextSamplingPackage.AIR_QUALITY),
            ],
          ),
        phone);

    // collect a reading / audio sample on a daily basis
    protocol.addTriggeredTask(
        IntervalTrigger(period: Duration(days: 1)),
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
        )..measures.add(Measure(type: MediaSamplingPackage.AUDIO)),
        phone);

    // add a task that keeps reappearing when done
    var environmentTask = AppTask(
      type: BackgroundSensingUserTask.ONE_TIME_SENSING_TYPE,
      title: "Location, Weather & Air Quality",
      description: "Collect location, weather and air quality",
    )..addMeasures([
        Measure(type: ContextSamplingPackage.LOCATION),
        Measure(type: ContextSamplingPackage.WEATHER),
        Measure(type: ContextSamplingPackage.AIR_QUALITY),
      ]);

    protocol.addTriggeredTask(ImmediateTrigger(), environmentTask, phone);
    protocol.addTriggeredTask(
        UserTaskTrigger(
            taskName: environmentTask.name,
            resumeCondition: UserTaskState.done),
        environmentTask,
        phone);

    return protocol;
  }

  @override
  Future<bool> saveStudyProtocol(String studyId, StudyProtocol protocol) async {
    throw UnimplementedError();
  }
}

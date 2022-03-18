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
  Future initialize() async {}

  /// Get a data endpoint for this study.
  DataEndPoint getDataEndpoint(String type) {
    switch (type) {
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

    // define which devices are used for data collection.
    Smartphone phone = Smartphone();
    protocol.addMasterDevice(phone);

    // collect basic device measures continously
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AutomaticTask()
          ..measures = SamplingPackageRegistry().common.getMeasureList(
            types: [
              SensorSamplingPackage.LIGHT,
              SensorSamplingPackage.PEDOMETER,
              DeviceSamplingPackage.MEMORY,
              DeviceSamplingPackage.DEVICE,
              DeviceSamplingPackage.BATTERY,
              DeviceSamplingPackage.SCREEN,
            ],
          ),
        phone);

    // collect location, weather and air quality every 5 minutes
    protocol.addTriggeredTask(
        PeriodicTrigger(
          period: Duration(minutes: 5),
          duration: const Duration(seconds: 2),
        ),
        AutomaticTask()
          ..measures = SamplingPackageRegistry().common.getMeasureList(
            types: [
              ContextSamplingPackage.LOCATION,
              ContextSamplingPackage.WEATHER,
              ContextSamplingPackage.AIR_QUALITY,
            ],
          ),
        phone);

    // collect location and activity measures continously (event-based)
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AutomaticTask()
          ..measures = SamplingPackageRegistry().common.getMeasureList(
            types: [
              ContextSamplingPackage.GEOLOCATION,
              ContextSamplingPackage.ACTIVITY,
            ],
          ),
        phone);

    // add an app task that once pr. hour asks the user to
    // collect weather and air quality - and notify the user
    protocol.addTriggeredTask(
        PeriodicTrigger(
          period: Duration(hours: 1),
          duration: const Duration(seconds: 2),
        ),
        AppTask(
          type: SensingUserTask.ONE_TIME_SENSING_TYPE,
          title: "Weather & Air Quality",
          description: "Collect local weather and air quality",
          notification: true,
        )..measures = SamplingPackageRegistry().common.getMeasureList(
            types: [
              ContextSamplingPackage.WEATHER,
              ContextSamplingPackage.AIR_QUALITY,
            ],
          ),
        phone);

    // collect demographics & location once when the study starts
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AppTask(
          type: SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE,
          title: surveys.demographics.title,
          description: surveys.demographics.description,
          minutesToComplete: surveys.demographics.minutesToComplete,
          notification: true,
        )
          ..measures.add(RPTaskMeasure(
            type: SurveySamplingPackage.SURVEY,
            name: surveys.demographics.title,
            description: surveys.demographics.description,
            surveyTask: surveys.demographics.survey,
          ))
          ..measures.add(Measure(type: ContextSamplingPackage.LOCATION)),
        phone);

    // collect symptoms on a daily basis
    protocol.addTriggeredTask(
        PeriodicTrigger(
          period: Duration(days: 1),
          duration: const Duration(seconds: 2),
        ),
        AppTask(
          type: SurveyUserTask.SURVEY_TYPE,
          title: surveys.symptoms.title,
          description: surveys.symptoms.description,
          minutesToComplete: surveys.symptoms.minutesToComplete,
        )
          ..measures.add(RPTaskMeasure(
            type: SurveySamplingPackage.SURVEY,
            name: surveys.symptoms.title,
            description: surveys.symptoms.description,
            surveyTask: surveys.symptoms.survey,
          ))
          ..measures.add(Measure(type: ContextSamplingPackage.LOCATION)),
        phone);

    // perform a cognitive assessment
    protocol.addTriggeredTask(
        PeriodicTrigger(
          period: Duration(minutes: 2),
          duration: const Duration(seconds: 2),
        ),
        AppTask(
          type: SurveyUserTask.COGNITIVE_ASSESSMENT_TYPE,
          title: surveys.cognition.title,
          description: surveys.cognition.description,
          minutesToComplete: surveys.cognition.minutesToComplete,
        )
          ..measures.add(RPTaskMeasure(
            type: SurveySamplingPackage.SURVEY,
            name: surveys.cognition.title,
            description: surveys.cognition.description,
            surveyTask: surveys.cognition.survey,
          ))
          ..measures.add(Measure(type: ContextSamplingPackage.LOCATION)),
        phone);

    // perform a Parkisons' assessment
    protocol.addTriggeredTask(
        PeriodicTrigger(
          period: Duration(minutes: 2),
          duration: const Duration(seconds: 2),
        ),
        AppTask(
          type: SurveyUserTask.COGNITIVE_ASSESSMENT_TYPE,
          title: "Parkinsons' Assessment",
          description: "A simple task assessing finger tapping speed.",
          minutesToComplete: 3,
        )
          ..measures.add(RPTaskMeasure(
            type: SurveySamplingPackage.SURVEY,
            surveyTask:
                RPOrderedTask(identifier: "parkinsons_assessment", steps: [
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
            ]),
          ))
          ..measures.add(Measure(type: SensorSamplingPackage.ACCELEROMETER))
          ..measures.add(Measure(type: SensorSamplingPackage.GYROSCOPE)),
        phone);

    // collect a coughing sample on a daily basis
    // also collect location, and local weather and air quality of this sample
    protocol.addTriggeredTask(
        PeriodicTrigger(
          period: Duration(days: 1),
          duration: const Duration(seconds: 2),
        ),
        AppTask(
          type: AudioUserTask.AUDIO_TYPE,
          title: "Coughing",
          description:
              'In this small exercise we would like to collect sound samples of coughing.',
          instructions:
              'Please press the record button below, and then cough 5 times.',
          minutesToComplete: 3,
          notification: true,
        )
          ..measures.add(CAMSMeasure(
            type: MediaSamplingPackage.AUDIO,
            name: "Coughing",
            description: "Collects an audio recording of coughing",
          ))
          ..measures.addAll(SamplingPackageRegistry().common.getMeasureList(
            types: [
              ContextSamplingPackage.LOCATION,
              ContextSamplingPackage.WEATHER,
              ContextSamplingPackage.AIR_QUALITY,
            ],
          )),
        phone);

    // collect a reading / audio sample on a daily basis
    protocol.addTriggeredTask(
        PeriodicTrigger(
          period: Duration(days: 1),
          duration: const Duration(seconds: 2),
        ),
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
        )..measures.add(CAMSMeasure(
            type: MediaSamplingPackage.AUDIO,
            name: "Reading",
            description:
                "Collects an audio recording while reading a text aloud",
          )),
        phone);

    // when the reading (audio) measure is collected, the add a user task to
    // collect location, and local weather and air quality
    protocol.addTriggeredTask(
        ConditionalSamplingEventTrigger(
          measureType: MediaSamplingPackage.AUDIO,
          resumeCondition: (DataPoint dataPoint) => true,
          pauseCondition: (DataPoint dataPoint) => true,
        ),
        AppTask(
          type: SensingUserTask.ONE_TIME_SENSING_TYPE,
          title: "Location, Weather & Air Quality",
          description: "Collect location, weather and air quality",
        )..measures.addAll(SamplingPackageRegistry().common.getMeasureList(
            types: [
              ContextSamplingPackage.LOCATION,
              ContextSamplingPackage.WEATHER,
              ContextSamplingPackage.AIR_QUALITY,
            ],
          )),
        phone);

    return protocol;
  }

  Future<bool> saveStudyProtocol(String studyId, StudyProtocol protocol) async {
    throw UnimplementedError();
  }
}

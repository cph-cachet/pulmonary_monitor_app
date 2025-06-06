# Pulmonary Monitor Flutter App

The Pulmonary Monitor Flutter App is designed to monitor pulmonary (i.e., respiratory) symptoms.
It is build using the [CARP Mobile Sensing](https://pub.dev/packages/carp_mobile_sensing) (CAMS) Framework, which is part of the [Copenhagen Research Platform](https://carp.cachet.dk) (CARP) from the [Copenhagen Center for Health Technology](https://www.cachet.dk).

It follows the Flutter Business Logic Component (BLoC) architecture, as described in the
[CARP Mobile Sensing App](https://github.com/cph-cachet/carp.sensing-flutter/tree/master/apps/carp_mobile_sensing_app).

In particular, this app is designed to demonstrate how the CAMS [`AppTask`](https://pub.dev/documentation/carp_mobile_sensing/latest/domain/AppTask-class.html) is used. An elaborate presentation of the app task model is available on the [CAMS wiki](https://github.com/cph-cachet/carp.sensing-flutter/wiki/4.-The-AppTask-Model).

## Design Rationale

The work on this app started with a collaboration with the [COVID-19 Sounds App](https://www.covid-19-sounds.org/en/) project at the University of Cambridge.

Pulmonary Monitor is designed to sample the following data:

* device data - device, memory, light,
* context data - location, activity, weather, and air quality
* surveys - demographics and daily symptoms
* sound - coughing and reading
* cognitive performance - using a set of cognitive tests

All of this is configured in the [`study_protocol_manager.dart`](lib/sensing/study_protocol_manager.dart) file. Compared to the standard CAMS example app, this app makes extensive use of `AppTask`s for collecting surveys and sound samples. However, it also illustrates how "normal" sensing measures can be wrapped in an `AppTask`. For example, there is an app task collecting weather and air quality measures. And it illustrates how background sensing can be added to an app task. For example, accelerometer and gyroscope data is collected while the user performs a cognitive assessment.

The user-interface of the app is shown in Figure 1.

![pm_0](https://user-images.githubusercontent.com/1196642/99997746-e5a81980-2dbd-11eb-833f-7b28cb37fd05.png)
![pm_1](https://user-images.githubusercontent.com/1196642/99997786-f22c7200-2dbd-11eb-86ac-d6a9b44c549d.png)

**Figure 1** - User interface of the Pulmonary Monitor app. Left: Study overview. Right: Task list for the user to do.

## App Tasks

The task list (Figure 1 right) is created from the different `AppTask`s defined in the [`study_protocol_manager.dart`](lib/sensing/study_protocol_manager.dart) file. There are four kind of app tasks defined:

1. A **sensing** task wrapped in an app task collecting weather and air quality.
2. Two types of **survey** tasks collecting demographics and daily symptoms.
3. Two types of **audio** tasks, collecting sound while the user is coughing and reading.
4. One **cognitive** task with two cognitive tests assessing cognitive functioning and finger tapping speed, respectively.

### Sensing App Task

The sensing app task collects `location`, `weather` and `air_quality` measures (all defined in the [`carp_context_package`](https://pub.dev/packages/carp_context_package)). This app task appears at the bottom of the task list in Figure 1. This app task is defined like this:

````dart
SmartphoneStudyProtocol protocol = SmartphoneStudyProtocol(
  name: 'Pulmonary Monitor',
  ownerId: 'alex@uni.dk',
);

// Define which devices are used for data collection.
Smartphone phone = Smartphone();
protocol.addPrimaryDevice(phone);

...

// add an app task that once pr. hour asks the user to
// collect weather and air quality - and notify the user
protocol.addTaskControl(
    PeriodicTrigger(period: Duration(hours: 1)),
    AppTask(
        type: BackgroundSensingUserTask.SENSING_TYPE,
        title: "Location, Weather & Air Quality",
        description: "Collect location, weather and air quality",
        notification: true,
        measures: [
          Measure(type: ContextSamplingPackage.LOCATION),
          Measure(type: ContextSamplingPackage.WEATHER),
          Measure(type: ContextSamplingPackage.AIR_QUALITY),
        ]),
    phone);
````

The above code adds an [`PeriodicTrigger`](https://pub.dev/documentation/carp_mobile_sensing/latest/domain/PeriodicTrigger-class.html) with an [`AppTask`](https://pub.dev/documentation/carp_mobile_sensing/latest/domain/AppTask-class.html) of type `sensing`.
This app task contains the three measures of location, weather, and air quality.
The result of this sensing configuration is that an app task is added to the task list every hour, and when it is activated by the user (by pushing the `PRESS HERE TO FINISH TASK` button), the measurements are collected during a 10-second window. When the measurements have been collected, the app task is marked as "done" in the task list, illustrated by a green check mark as shown in Figure 2.

![pm_2](https://user-images.githubusercontent.com/1196642/100003816-f3ae6800-2dc6-11eb-9734-381a8b376a10.png)

**Figure 2** - Task list with a "done" sensing task.

This app task has also enabled `notification` and a notification about this task will be added to the phone's notification system.
If the user presses this notification, s/he is taken to the app (but **NOT** the task itself (this is a more complicated issue, which is supported by CAMS, but not implemented in the PulmonaryMonitor app (yet))).
If the user does the task from the app (by pushing the `PRESS HERE TO FINISH TASK` button), the notification will be removed again.

### Survey App Task

A survey (as defined in the [`carp_survey_package`](https://pub.dev/packages/carp_survey_package)) can be wrapped in an app task, which will add the survey to the task list.
In Figure 1, there are two types of surveys; a demographics survey and a survey of daily symptoms.
These are configured in the [`study_protocol_manager.dart`](https://github.com/cph-cachet/pulmonary_monitor_app/blob/master/lib/sensing/study_protocol_manager.dart) file like this:

````dart
// Collect demographics & location once the study starts.
protocol.addTaskControl(
    ImmediateTrigger(),
    RPAppTask(
        type: SurveyUserTask.SURVEY_TYPE,
          title: 'Demographics',
          description: 'A short 4-item survey on your background.',
          minutesToComplete: 1,
        notification: true,
        rpTask: surveys.demographics.survey,
        measures: [Measure(type: ContextSamplingPackage.CURRENT_LOCATION)]),
    phone);
````

This configuration adds the demographics survey (as defined in the [`surveys.dart`](lib/sensing/surveys.dart) file) immediately to the task list.  Note that a `LOCATION` measure is also added. This will have the effect that location is sampled, when the survey is done - i.e., we know **where** the user filled in this survey.

The configuration of the daily symptoms survey is similar. This survey is, however, triggered once per day at 13:30 and hence added to the task list daily. Again, location is collected when the survey is filled in.

````dart
// Collect symptoms daily at 13:30
protocol.addTaskControl(
    RecurrentScheduledTrigger(
      type: RecurrentType.daily,
      time: TimeOfDay(hour: 13, minute: 30),
    ),
    RPAppTask(
        type: SurveyUserTask.SURVEY_TYPE,
        title: 'Symptoms',
        description: 'A short 1-item survey on your daily symptoms.',
        minutesToComplete: 1,
        rpTask: surveys.symptoms.survey,
        measures: [Measure(type: ContextSamplingPackage.CURRENT_LOCATION)]),
    phone);
````

Note that this app task does not issue a notification.

Figure 3 shows how this looks on the user interface.

![pm_5](https://user-images.githubusercontent.com/1196642/100005547-691b3800-2dc9-11eb-989d-b5b948487717.png)
![pm_6](https://user-images.githubusercontent.com/1196642/100005570-71737300-2dc9-11eb-9208-b8d665a8d650.png)

**Figure 3** - Left: The daily symptoms survey, shown when the user starts the task. Right: The task list showing that the two surveys have been filled in ("done").

### Audio App Task

Another type of app tasks used in the Pulmonary Monitor app are two types of audio tasks, which sample audio from the user when coughing and reading a text aloud. Both use the `AUDIO` measure defined in the [`carp_audio_package`](https://pub.dev/packages/carp_audio_package).

The configuration of the coughing audio app task is defined like this:

````dart
// Collect a coughing sample on a daily basis.
// Also collect current location, and local weather and air quality of this
// sample.
protocol.addTaskControl(
    PeriodicTrigger(period: Duration(days: 1)),
    AppTask(
      type: AudioUserTask.AUDIO_TYPE,
      title: "Coughing",
      description:
          'In this small exercise we would like to collect sound samples of coughing.',
      instructions:
          'Please press the record button below, and then cough 5 times.',
      minutesToComplete: 3,
      notification: true,
      measures: [
        Measure(type: MediaSamplingPackage.AUDIO),
        Measure(type: ContextSamplingPackage.CURRENT_LOCATION),
        Measure(type: ContextSamplingPackage.WEATHER),
        Measure(type: ContextSamplingPackage.AIR_QUALITY),
      ],
    ),
    phone);
````

This configuration adds an app task to the task list once per day of type `AUDIO_TYPE`.
And it uses notifications.
This app task will collect four types of measures when started; an `AUDIO` recording, current `LOCATION`, local `WEATHER`, and local `AIR_QUALITY`.

![pm_7](https://user-images.githubusercontent.com/1196642/100006854-70dbdc00-2dcb-11eb-9e42-0cba30c4af07.png)
![pm_9](https://user-images.githubusercontent.com/1196642/100006878-776a5380-2dcb-11eb-91ca-2ee1a3aef618.png)

**Figure 4** - Left: The daily coughing audio sampling, shown when the user starts the task. Right: The task list showing that the coughing task has been "done".

### Cognition Testing App Task

The last type of app tasks used in the app is the cognitive tests from the [cognition_package](https://pub.dev/packages/cognition_package). Cognitive test are modelled just like a survey, and can be added to the protocol like a survey.

Below is an example of adding an assessment of Parkinson's Disease which consists of an instruction step, a timer step, and two cognitive tests (Flanker and Tapping tests). Note that accelerometer and gyroscope data is collected throughput the test (in order to assess tremor).

```dart
// Perform a Parkinson's assessment.
// This is strictly speaking not part of monitoring pulmonary symptoms,
// but is included to illustrate the use of cognitive tests from the
// cognition package.
protocol.addTaskControl(
    PeriodicTrigger(period: Duration(hours: 2)),
    RPAppTask(
        type: SurveyUserTask.COGNITIVE_ASSESSMENT_TYPE,
        title: "Parkinson's' Assessment",
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
            RPTimerStep(
              identifier: 'RPTimerStepID',
              timeout: Duration(seconds: 6),
              title:
                  "Please stand up and hold the phone in one hand and lift it in a straight arm until you hear the sound.",
              playSound: true,
            ),
            RPFlankerActivity(
              identifier: 'flanker_1',
              lengthOfTest: 30,
              numberOfCards: 10,
            ),
            RPTappingActivity(
              identifier: 'tapping_1',
              lengthOfTest: 10,
            )
          ],
        ),
        measures: [
          Measure(type: SensorSamplingPackage.ACCELERATION),
          Measure(type: SensorSamplingPackage.ROTATION),
        ]),
    phone);
```

## User Task Model

As explained in the tutorial on the [AppTask model on the CAMS wiki](https://github.com/cph-cachet/carp.sensing-flutter/wiki/4.-The-AppTask-Model), the runtime of app tasks are handled by so-called [`UserTask`](https://pub.dev/documentation/carp_mobile_sensing/latest/runtime/UserTask-class.html).
A `UserTask` defines what happens when the user click the "PRESS HERE TO FINISH TASK" button.
We shall not go into these details here (please see the tutorial), but just mention that the handling of the audio app tasks above, is done using a user task model specific to the PulmonaryMonitor app.

This user task model is specified in the [`lib/sensing/user_task.dart`](lib/sensing/audio_user_task.dart) file.
This file defines:

* An `AudioUserTask` which defines a `UserTask` for what should happen when the audio app task is started.
* A `PulmonaryUserTaskFactory` which is a [`UserTaskFactory`](https://pub.dev/documentation/carp_mobile_sensing/latest/runtime/UserTaskFactory-class.html), which can create a `UserTask` based on the type of app task. In this case an `AudioUserTask`.

The definition of `AudioUserTask` is:

````dart
/// A user task handling audio recordings.
///
/// The [widget] returns an [AudioMeasurePage] that can be shown on the UI.
///
/// When the recording is started (calling the [onRecord] method),
/// the background task collecting sensor measures is started.
class AudioUserTask extends UserTask {
  static const String AUDIO_TYPE = 'audio';

  final StreamController<int> _countDownController =
      StreamController.broadcast();
  Stream<int> get countDownEvents => _countDownController.stream;
  Timer? _timer;

  /// Duration of audio recording in seconds.
  int recordingDuration = 10;

  AudioUserTask(super.executor, [this.recordingDuration = 10]);

  @override
  bool get hasWidget => true;

  @override
  Widget? get widget => AudioMeasurePage(audioUserTask: this);

  /// Callback when recording is to start.
  /// When recording is started, background sensing is also started.
  void onRecord() {
    backgroundTaskExecutor.start();

    // start the countdown, once tick pr. second.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _countDownController.add(--recordingDuration);

      if (recordingDuration <= 0) {
        _timer?.cancel();
        _countDownController.close();

        // stop the background sensing and mark this task as done
        backgroundTaskExecutor.stop();
        super.onDone();
      }
    });
  }
}
````

When this user task is to be shown in the UI, the [`widget`](https://pub.dev/documentation/carp_mobile_sensing/latest/runtime/UserTask/widget.html) property is shown. This `AudioUserTask` returns an [`AudioMeasurePage`](lib/ui/audio_measure_page.dart) as a widget (Figure 4 left).
When the user clicks the red button to start recording, the `onRecord()` method is called.
This method starts background sampling (i.e. starts collecting all the measures defined in the task) and starts a count-down, which - when finished - stops the sampling and marks this task as "done".

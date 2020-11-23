# Pulmonary Monitor Flutter App

The Pulmonary Monitor Flutter App is designed to monitor pulmonary (i.e., respiratory) symptoms.
It is build using the [CARP Mobile Sensing](https://pub.dev/packages/carp_mobile_sensing) 
(CAMS) Framework, which is part of the [CACHET Research Platform](https://carp.cachet.dk) (CARP) from the [Copenhagen Center for Health Technology](https://www.cachet.dk).

It follows the Flutter Business Logic Component (BLoC) architecture, as described in the 
[CARP Mobile Sensing App](https://github.com/cph-cachet/carp.sensing-flutter/tree/master/carp_mobile_sensing_app).

In particular, this app is designed to demonstrate how the CAMS [`AppTask`](https://pub.dev/documentation/carp_mobile_sensing/latest/domain/AppTask-class.html) is used. An elaborate presentation of the app task model is available on the [CAMS wiki](https://github.com/cph-cachet/carp.sensing-flutter/wiki/3.1-The-AppTask-Model).

## Design Rationale

The work on this app started with a collaboration with the [COVID-19 Sounds App](https://www.covid-19-sounds.org/en/) project at the University of Cambridge.

Pulmonary Monitor is designed to sample the following data:

* device data - device, memory, light, 
* context data - location, activity, weather, and air quality
* surveys - demographics and daily symptoms
* sound - coughing and reading

All of this is configured in the [`sensing.dart`](https://github.com/cph-cachet/pulmonary_monitor_app/blob/master/lib/sensing/sensing.dart) file. Compared to the standard CAMS example app, this app makes extensive use of `AppTask`s for collecting surveys and sound samples. However, it also illustrates how "normal" sensing measures can be wrapped in an `AppTask`. For example, there is an app task collecting weather and air quality measures. 

The user-interface of the app is shown below.

![pm_0](https://user-images.githubusercontent.com/1196642/99997746-e5a81980-2dbd-11eb-833f-7b28cb37fd05.png)
![pm_1](https://user-images.githubusercontent.com/1196642/99997786-f22c7200-2dbd-11eb-86ac-d6a9b44c549d.png)

**Figure 1** - User interface of the Pulmonary Monitor app. Left: Study overview. Right: Task list for the user to do.

## App Tasks

The task list (Figure 1 right) is created from the different `AppTask`s defined in the [`sensing.dart`](https://github.com/cph-cachet/pulmonary_monitor_app/blob/master/lib/sensing/sensing.dart) file. There are three kind of app tasks defined:

1. A **sensing** task wrapped in an app task
2. Two types of **survey** tasks, each wrapped in an app task
3. Two types of **audio** tasks, each wrapped in an app task

### Sensing App Task

The sesing app task collects `weather` and `air_quality` measures (both defined in the [`carp_context_package`](https://pub.dev/packages/carp_context_package)). This app task appears at the bottom of the task list. This app task is defined like this:

````dart
study = Study('1234', 'user@dtu.dk')
    ..name = 'Pulmonary Monitor'
    ..description =
        "With the Pulmonary Monitor you can monitor your respiratory health. ..."
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
````

The above code add an `ImmediateTrigger` with an `AppTask` of type `ONE_TIME_SENSING_TYPE`. This app task contains the two measures of `weather` and `air_quality`. 
The result of this sensing configuration is that an app task is imediately added to the task list and when it is activated by the user (by pushing the `PRESS HERE TO FINISH TASK` button), the measures are resumed exactly once. When the measures has been collected, the app task is markede as "done" in the task list, illustrated by a green check mark as shown in Figure 2 left.

![pm_2](https://user-images.githubusercontent.com/1196642/100003816-f3ae6800-2dc6-11eb-9734-381a8b376a10.png)

**Figure 2** - User interface of the Pulmonary Monitor app. Left: Task list with a "done" sensing task.


### Survey App Task

A survey (as defined in the [`carp_survey_package`](https://pub.dev/packages/carp_survey_package)) can be wrapped in an app task, which will add the survey to the task list. In Figure 1, there are two type of suevey added; a demographics survey and a survey of daily symptoms.
These are configured in the [`sensing.dart`](https://github.com/cph-cachet/pulmonary_monitor_app/blob/master/lib/sensing/sensing.dart) file like this:

````dart
study = Study('1234', 'user@dtu.dk')
   ...
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
````

This configuration add the demographics survey (as defined in `surveys.demographics.survey`) immediately to the task list.  Note that a `location` measure is also added. This will have the effect that location is sampled, when the survey is done - i.e., we know where the user filled in the survey.

The configuration of the daily symptoms survey is similar. This survey is, however, triggered once per day and hence added to the task list daily. Again, location is collected when the survey is filled in.

````dart
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
````

Figure 3 shows how this looks on the user interface.

![pm_5](https://user-images.githubusercontent.com/1196642/100005547-691b3800-2dc9-11eb-989d-b5b948487717.png)
![pm_6](https://user-images.githubusercontent.com/1196642/100005570-71737300-2dc9-11eb-9208-b8d665a8d650.png)

**Figure 3** - Left: The daily symptoms survey, shown when the user starts the task. Right: The task list showing that the two surveys have been filled in ("done").


### Audio App Task

The last type of app task using in the Pulmonary Monitor app is two type of audio tasks, which samples audio samples from the user when coughing and reading a text alound. Both use the `audio` measure defined in the [`carp_audio_package`](https://pub.dev/packages/carp_audio_package).

The configuration of the coughing audio app task is defined like this:

````dart
    ..addTriggerTask(
        PeriodicTrigger(period: Duration(days: 1)),
        AppTask(
          type: AudioUserTask.AUDIO_TYPE,
          title: "Coughing",
          description: 'In this small exercise we would like to collect sound samples of coughing.',
          instructions: 'Please press the record button below, and then cough 5 times.',
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
````

This configuration add an app task to the task list once per day of type `AUDIO_TYPE`. 
This app task will collect four types of measures when started; an `audio` recording, current `location`, local `weather`, and local `air_quality`. 

![pm_7](https://user-images.githubusercontent.com/1196642/100006854-70dbdc00-2dcb-11eb-9e42-0cba30c4af07.png)
![pm_9](https://user-images.githubusercontent.com/1196642/100006878-776a5380-2dcb-11eb-91ca-2ee1a3aef618.png)

**Figure 4** - Left: The daily coughing audio sampling, shown when the user starts the task. Right: The task list showing that the coughing task has been "done".


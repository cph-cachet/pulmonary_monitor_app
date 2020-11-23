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
2. Two types of **survey** task wrapped in an app task
3. Two types of **audio** tasks wrapped in an app task

### Sensing App Task

The sesing app task collects `weather` and `air_quality` measures (both defined in the [`carp_context_package`](https://pub.dev/packages/carp_context_package)). This app task appears at the bottom of the task list. This app task is defined like this:

````dart
study = Study(studyId, await settings.userId)
    ..name = 'Pulmonary Monitor'
    ..description =
        "With the Pulmonary Monitor you can monitor your respiratory health. ..."
..addTriggerTask(
            ImmediateTrigger(),
            AppTask(
              type: OneTimeSensingUserTask.ONE_TIME_SENSING_TYPE,
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

### Survey App Task

### Audio App Task














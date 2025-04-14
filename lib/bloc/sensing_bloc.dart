part of '../main.dart';

class SensingBLoC {
  // -------------------------------------------------------------------- //
  //                      TESTING PARAMETERS                              //
  // -------------------------------------------------------------------- //

  /// Deployment ID used for testing. This is used across app restart if not null.
  final String? testStudyDeploymentId = 'ae8076a3-7170-4bcf-b66c-64639a7a9eee';

  /// Should we save the app task queue across app restart
  bool get saveAppTaskQueueAcrossAppRestart => testStudyDeploymentId != null;

  // -------------------------------------------------------------------- //

  SmartphoneDeployment? get deployment => Sensing().deployment;
  StudyDeploymentModel? _model;

  /// The list of available app tasks for the user to address.
  List<UserTask> get tasks => AppTaskController().userTaskQueue;

  /// Get the study for this app.
  StudyDeploymentModel get studyDeploymentModel =>
      _model ??= StudyDeploymentModel(deployment!);

  SensingBLoC();

  Future<void> init() async {
    Settings().debugLevel = DebugLevel.debug;

    Settings().saveAppTaskQueue = saveAppTaskQueueAcrossAppRestart;

    await Settings().init();
    await Sensing().initialize();
    info('$runtimeType initialized');

    // This show how an app can listen to user task events.
    // Is not used in this app.
    AppTaskController().userTaskEvents.listen((event) {
      switch (event.state) {
        case UserTaskState.initialized:
          //
          break;
        case UserTaskState.enqueued:
          //
          break;
        case UserTaskState.dequeued:
          //
          break;
        case UserTaskState.started:
          //
          break;
        case UserTaskState.done:
          //
          break;
        case UserTaskState.undefined:
          //
          break;
        case UserTaskState.canceled:
          //
          break;
        case UserTaskState.expired:
          //
          break;
        case UserTaskState.notified:
          //
          break;
      }
    });
  }

  void start() async => Sensing().controller?.executor.start();
  void stop() async => Sensing().controller?.stop();

  /// Is sensing running, i.e. has the study executor been resumed?
  bool get isRunning =>
      (Sensing().controller != null) &&
      Sensing().controller!.executor.state == ExecutorState.started;
}

final bloc = SensingBLoC();

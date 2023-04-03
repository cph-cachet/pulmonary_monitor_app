part of pulmonary_monitor_app;

class SensingBLoC {
  SmartphoneDeployment? get deployment => Sensing().deployment;
  StudyDeploymentModel? _model;

  /// The list of available app tasks for the user to address.
  List<UserTask> get tasks => AppTaskController().userTaskQueue;

  /// Get the study for this app.
  StudyDeploymentModel get studyDeploymentModel =>
      _model ??= StudyDeploymentModel(deployment!);

  SensingBLoC();

  Future init() async {
    Settings().debugLevel = DebugLevel.debug;

    // don't store the app task queue across app restart
    Settings().saveAppTaskQueue = false;

    await Settings().init();
    await LocalResourceManager().initialize();
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
      }
    });
  }

  void start() async => Sensing().controller?.executor?.start();
  void stop() async => Sensing().controller?.stop();

  /// Is sensing running, i.e. has the study executor been resumed?
  bool get isRunning =>
      (Sensing().controller != null) &&
      Sensing().controller!.executor!.state == ExecutorState.started;
}

final bloc = SensingBLoC();

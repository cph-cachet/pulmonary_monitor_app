part of pulmonary_monitor_app;

class SensingBLoC {
  CAMSMasterDeviceDeployment get deployment => Sensing().deployment;
  StudyDeploymentModel _model;

  /// The list of available app tasks for the user to address.
  List<UserTask> get tasks => AppTaskController().userTaskQueue;

  /// Is sensing running, i.e. has the study executor been resumed?
  bool get isRunning =>
      (Sensing().controller != null) &&
      Sensing().controller.executor.state == ProbeState.resumed;

  /// Get the study for this app.
  StudyDeploymentModel get studyDeploymentModel =>
      _model ??= StudyDeploymentModel(deployment);

  SensingBLoC();

  Future init() async {
    Settings().debugLevel = DebugLevel.DEBUG;
    await settings.init();
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
          // TODO: Handle this case.
          break;
      }
    });
  }

  void resume() async => Sensing().controller.resume();
  void pause() => Sensing().controller.pause();
  void stop() async => Sensing().controller.stop();
  void dispose() async => Sensing().controller.stop();

  // /// Add a [Datum] object to the stream of events.
  // void addDatum(Datum datum) => sensing.controller.executor.addDatum(datum);

  // /// Add a error to the stream of events.
  // void addError(Object error, [StackTrace stacktrace]) =>
  //     sensing.controller.executor.addError(error, stacktrace);
}

final bloc = SensingBLoC();

part of pulmonary_monitor_app;

class SensingBLoC {
  //List<UserTask> _tasks = List<UserTask>();
  //final List<AppTaskEvent> _tasks = [];

  final Sensing sensing = Sensing();

  /// the list of available task for the user to fill out.
  //List<UserTask> get tasks => _tasks;

  /// the list of available app tasks for the user to address.
  List<UserTask> get tasks => AppTaskController().userTaskQueue;

  /// Is sensing running, i.e. has the study executor been resumed?
  bool get isRunning =>
      (sensing.controller != null) &&
      sensing.controller.executor.state == ProbeState.resumed;

  /// Get the study for this app.
  StudyModel get study =>
      sensing.study != null ? StudyModel(sensing.study) : null;

  /// Get a list of tasks for the user
  //Iterable<UserTaskModel> get userTasks => tasks.map((task) => UserTaskModel(task));

  /// Get the data model for this study.
  DataModel get data => null;

  SensingBLoC();

  Future<void> init() async {
    AppTaskController().registerUserTaskFactory(PulmonaryUserTaskFactory());

    AppTaskController().userTaskEvents.listen((event) {
      AppTask _task = event.task;
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
        case UserTaskState.onhold:
          //
          break;
        case UserTaskState.done:
          //
          break;
        case UserTaskState.undefined:
          //
          break;
      }
    });
  }

  Future<void> start() async => sensing.start();

  void pause() => sensing.controller.pause();

  void resume() async => sensing.controller.resume();

  void stop() async => sensing.stop();

  void dispose() async => sensing.stop();

  /// Add a [Datum] object to the stream of events.
  void addDatum(Datum datum) => sensing.controller.executor.addDatum(datum);

  /// Add a error to the stream of events.
  void addError(Object error, [StackTrace stacktrace]) =>
      sensing.controller.executor.addError(error, stacktrace);

  // void addSensingTask(TaskExecutor executor) {
  //   AppTask _task = (executor.task as AppTask);
  //   debug('Adding SensingTask : $executor');
  //
  //   final SensingUserTask _userTask = SensingUserTask(
  //     type: UserTaskType.sensing,
  //     title: _task.title,
  //     description: _task.description,
  //     executor: executor,
  //   );
  //
  //   _tasks.add(_userTask);
  // }
  //
  // void addTaskWithSurvey(TaskExecutor executor) {
  //   AppTask _task = (executor.task as AppTask);
  //   debug('Adding TaskWithSurvey - executor : $executor, task : $_task');
  //
  //   final SurveyUserTask _userTask = SurveyUserTask(
  //     type: UserTaskType.daily_survey,
  //     title: _task.title,
  //     description: _task.description,
  //     instructions: _task.instructions,
  //     minutesToComplete: _task.minutesToComplete,
  //     executor: executor,
  //   );
  //
  //   _tasks.add(_userTask);
  // }
  //
  // void addTaskWithAudio(TaskExecutor executor) {
  //   AppTask _task = (executor.task as AppTask);
  //   debug('Adding TaskWithAudio - executor : $executor, task : $_task');
  //
  //   final AudioUserTask _userTask = AudioUserTask(
  //     type: UserTaskType.audio_recording,
  //     title: _task.title,
  //     description: _task.description,
  //     instructions: _task.instructions,
  //     minutesToComplete: _task.minutesToComplete,
  //     recordingDuration: 5,
  //     executor: executor,
  //   );
  //
  //   _tasks.add(_userTask);
  // }
}

final bloc = SensingBLoC();

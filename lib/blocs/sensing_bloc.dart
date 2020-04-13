part of pulmonary_monitor_app;

class SensingBLoC {
  final Sensing sensing = Sensing();
  //SurveyPage surveyPage;

  List<UserTask> _tasks = List<UserTask>();

  /// the list of available task for the user to fill out.
  List<UserTask> get tasks => _tasks;

  /// Is sensing running, i.e. has the study executor been resumed?
  bool get isRunning => (sensing.controller != null) && sensing.controller.executor.state == ProbeState.resumed;

  /// Get the study for this app.
  StudyModel get study => sensing.study != null ? StudyModel(sensing.study) : null;

  /// Get a list of tasks for the user
  Iterable<UserTaskModel> get userTasks => tasks.map((task) => UserTaskModel(task));

  /// Get the data model for this study.
  DataModel get data => null;

  Future<void> init() async {}

  Future<void> start() async => sensing.start();

  void pause() => sensing.controller.pause();

  void resume() async => sensing.controller.resume();

  void stop() async => sensing.stop();

  void dispose() async => sensing.stop();

  void addSensingTask(TaskExecutor executor) {
    AppTask _task = (executor.task as AppTask);
    print('>>> addSensingTask : $executor');

    final SensingUserTask _userTask = SensingUserTask(
      type: UserTaskType.sensing,
      heading: _task.name,
      description: _task.description,
      executor: executor,
    );

    _tasks.add(_userTask);
  }

  void addTaskWithSurvey(TaskExecutor executor) {
    AppTask _task = (executor.task as AppTask);
    print('>>> addTaskWithSurvey - executor : $executor, task : $_task');

    final SurveyUserTask _userTask = SurveyUserTask(
      type: UserTaskType.daily_survey,
      heading: _task.name,
      description: _task.description,
      minutesToComplete: _task.minutesToComplete,
      executor: executor,
    );

    _tasks.add(_userTask);
  }
}

final bloc = SensingBLoC();

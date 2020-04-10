part of pulmonary_monitor_app;

class SensingBLoC {
  final Sensing sensing = Sensing();
  SurveyPage surveyPage;

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

  void onWHO5SurveyTriggered(SurveyPage surveyPage) {
    print(' onWHO5SurveyTriggered : $surveyPage');

    SurveyUserTask task = SurveyUserTask(
        type: UserTaskType.daily_survey,
        heading: surveys.who5.title,
        description: surveys.who5.description,
        minutesToComplete: surveys.who5.minutesToComplete,
        survey: surveyPage);

    surveyPage.resultCallback = task.resultCallback;

    _tasks.add(task);
  }

  void onDemographicsSurveyTriggered(SurveyPage surveyPage) {
    print(' onDemographicsSurveyTriggered : $surveyPage');

    SurveyUserTask task = SurveyUserTask(
        type: UserTaskType.demographic_survey,
        heading: surveys.demographics.title,
        description: surveys.demographics.description,
        minutesToComplete: surveys.demographics.minutesToComplete,
        survey: surveyPage);

    surveyPage.resultCallback = task.resultCallback;

    _tasks.add(task);
  }

  void onSurveySubmit(RPTaskResult result) {}
}

final bloc = SensingBLoC();

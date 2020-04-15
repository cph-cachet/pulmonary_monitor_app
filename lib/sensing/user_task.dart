part of pulmonary_monitor_app;

/// Enumerates the different types of tasks.
enum UserTaskType { demographic_survey, daily_survey, audio_recording, sensing }

/// Enumerates the different states of a task.
enum UserTaskState { created, resumed, paused, done }

class UserTask {
  final UserTaskType type;
  final String heading;
  final String description;

  /// How many minutes will it take to complete this task?
  final int minutesToComplete;

  /// The time this task was added to the list.
  DateTime timestamp;

  /// The callback that is called when the task is tapped or otherwise activated.
  void onPressed(BuildContext context) {
    // default implementation is no-op
  }

  /// The callback that is called when the task is finished.
  void onDone() {
    state = UserTaskState.done;
  }

  /// The state of this task.
  UserTaskState state;

  UserTask({
    @required this.type,
    @required this.heading,
    this.description,
    this.minutesToComplete,
    this.state = UserTaskState.created,
    //@required this.onPressed,
  })  : assert(type != null),
        assert(heading != null) {
    timestamp = DateTime.now();
  }
}

class SensingUserTask extends UserTask {
  TaskExecutor executor;

  SensingUserTask({
    @required UserTaskType type,
    String heading,
    String description,
    int minutesToComplete,
    UserTaskState state = UserTaskState.created,
    @required this.executor,
  })  : assert(type != null),
        assert(heading != null),
        assert(executor != null),
        super(
          type: type,
          heading: heading,
          description: description,
          minutesToComplete: minutesToComplete,
          state: state,
        );

  void onPressed(BuildContext context) {
    print(">>> onPressed in SensingUserTask, executor: $executor, state: ${executor?.state}");
    executor?.start();
    onDone();
  }

  void onDone() {
    super.onDone();
  }
}

class SurveyUserTask extends UserTask {
  TaskExecutor executor;
  BuildContext _context;
  SurveyProbe mySurveyProbe;

  SurveyUserTask({
    @required UserTaskType type,
    String heading,
    String description,
    int minutesToComplete,
    UserTaskState state = UserTaskState.created,
    @required this.executor,
  })  : assert(type != null),
        assert(heading != null),
        assert(executor != null),
        super(
          type: type,
          heading: heading,
          description: Uuid().v1().toString(),
          minutesToComplete: minutesToComplete,
          state: state,
        ) {
    // looking for the survey probe (i.e. a [SurveyProbe]) in this executor
    // we need to add the callback functions to it
    for (Probe probe in executor.probes) {
      if (probe is SurveyProbe) {
        mySurveyProbe = probe;
        break; // only supports one survey pr. task
      }
    }
  }

  void onPressed(BuildContext context) {
    print(">>> onPressed in NewSurveyUserTask, executor: $executor, state: ${executor?.state}, _context: $_context");

    // check if this task is created (i.e. new) before starting it
    // TODO - allow for resuming paused tasks?
    if (state == UserTaskState.created) {
      _context = context;
      mySurveyProbe.onSurveyTriggered = onSurveyTriggered;
      mySurveyProbe.onSurveySubmit = onSurveySubmit;

      if (executor?.state == ProbeState.initialized)
        executor?.start();
      else
        executor?.resume();

      state = UserTaskState.done;
    }
  }

  void onSurveyTriggered(SurveyPage surveyPage) {
    print(">>> onSurveyTriggered in NewSurveyUserTask, _context: $_context, surveyPage: ${surveyPage}");
    Navigator.of(_context).push(MaterialPageRoute(builder: (context) => surveyPage));
  }

  void onSurveySubmit(RPTaskResult result) {
    print(">>> onSurveySubmit in NewSurveyUserTask, result: $result");
    executor?.pause();
    onDone();
  }
}

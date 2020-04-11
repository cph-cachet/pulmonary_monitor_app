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

class SurveyUserTask extends UserTask {
  SurveyPage survey;

  SurveyUserTask({
    @required UserTaskType type,
    String heading,
    String description,
    int minutesToComplete,
    UserTaskState state = UserTaskState.created,
    //@required VoidCallback onPressed,
    @required this.survey,
  })  : assert(type != null),
        assert(heading != null),
        assert(survey != null),
        super(
          type: type,
          heading: heading,
          description: description,
          minutesToComplete: minutesToComplete,
          state: state,
        );

  void onPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => survey));
    state = UserTaskState.resumed;
  }

  void resultCallback(RPTaskResult result) => onDone();
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
    print(">>> onPressed in SensingUserTask, executor: $executor, state: ${executor.state}");
    if (executor != null) executor.start();
    state = UserTaskState.done;
  }
}

part of pulmonary_monitor_app;

/// Enumerates the different types of tasks.
enum UserTaskType { demographic_survey, daily_survey, audio_recording }

/// Enumerates the different states of a task.
enum UserTaskState { created, resumed, paused, done }

class UserTask {
  final UserTaskType type;
  final String heading;
  final String description;

  /// The callback that is called when the task is tapped or otherwise activated.
  void onPressed(BuildContext context) {
    // default implementation is no-op
  }

  /// The state of this task.
  UserTaskState state;

  UserTask({
    @required this.type,
    @required this.heading,
    this.description,
    this.state = UserTaskState.created,
    //@required this.onPressed,
  })  : assert(type != null),
        assert(heading != null);
}

class SurveyUserTask extends UserTask {
  SurveyPage survey;

  SurveyUserTask({
    @required UserTaskType type,
    String heading,
    String description,
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
          state: state,
        );

  void onPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => survey));
    state = UserTaskState.done;
  }
}

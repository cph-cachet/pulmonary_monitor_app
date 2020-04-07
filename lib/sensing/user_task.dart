part of pulmonary_monitor_app;

/// Enumerates the different types of tasks.
enum UserTaskType { demographic_survey, daily_survey, audio_recording }

/// Enumerates the different states of a task.
enum UserTaskState { created, resumed, paused, done }

class UserTask {
  UserTaskState state;

  UserTaskType type;
  String heading;
  String description;

  UserTask(this.type, this.heading, {this.description, this.state = UserTaskState.created});
}

class SurveyUserTask extends UserTask {
  SurveyPage survey;

  SurveyUserTask(UserTaskType type, String heading,
      {String description, UserTaskState state = UserTaskState.created, this.survey})
      : super(type, heading, description: description, state: state);
}

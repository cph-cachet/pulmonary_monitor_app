part of pulmonary_monitor_app;

class TasksModel {
  List<UserTaskModel> _tasks = [];
  List<UserTaskModel> get tasks => _tasks;
}

class UserTaskModel {
  UserTask task;

  UserTaskType get type => task.type;
  UserTaskState get state => task.state;

  /// The icon for the type of this task.
  Icon get typeIcon => taskTypeIcon[type];

  ///A printer-friendly name for this task.
  String get heading => task.heading;

  ///A printer-friendly description of this task.
  String get description => task.description;

  /// The icon for the state of this task.
  Icon get stateIcon => taskStateIcon[state];

  UserTaskModel(this.task)
      : assert(task != null, 'A TaskModel must be initialized with a Task.'),
        super();
}

Map<UserTaskType, Icon> get taskTypeIcon => {
      UserTaskType.demographic_survey: Icon(Icons.person, color: CACHET.ORANGE),
      UserTaskType.daily_survey: Icon(Icons.question_answer, color: CACHET.CYAN),
      UserTaskType.audio_recording: Icon(Icons.record_voice_over, color: CACHET.GREEN),
    };

taskStateLabel(UserTaskState state) {
  switch (state) {
    case UserTaskState.created:
      return "Created";
    case UserTaskState.resumed:
      return "Resumed";
    case UserTaskState.paused:
      return "Paused";
    case UserTaskState.done:
      return "Done";
  }
}

Map<UserTaskState, Icon> get taskStateIcon => {
      UserTaskState.created: Icon(Icons.notifications, color: CACHET.YELLOW),
      UserTaskState.resumed: Icon(Icons.play_arrow, color: CACHET.GREY_4),
      UserTaskState.paused: Icon(Icons.pause, color: CACHET.GREY_4),
      UserTaskState.done: Icon(Icons.check, color: CACHET.GREEN),
    };

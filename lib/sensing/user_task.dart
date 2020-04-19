part of pulmonary_monitor_app;

/// Enumerates the different types of tasks.
enum UserTaskType { demographic_survey, daily_survey, audio_recording, sensing }

/// Enumerates the different states of a task.
enum UserTaskState { created, resumed, paused, done }

class UserTask {
  final UserTaskType type;
  final String heading;
  final String description;
  final String instructions;

  StreamController<UserTaskState> _stateController = StreamController<UserTaskState>();
  Stream<UserTaskState> get stateEvents => _stateController.stream.asBroadcastStream();

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

  UserTaskState _state = UserTaskState.created;

  /// The state of this task.
  UserTaskState get state => _state;

  set state(UserTaskState state) {
    _state = state;
    _stateController.add(state);
  }

  UserTask({
    @required this.type,
    @required this.heading,
    this.description,
    this.instructions,
    this.minutesToComplete,
  })  : assert(type != null),
        assert(heading != null) {
    timestamp = DateTime.now();
    state = UserTaskState.created;
  }
}

class SensingUserTask extends UserTask {
  TaskExecutor executor;

  SensingUserTask({
    @required UserTaskType type,
    String heading,
    String description,
    String instructions,
    int minutesToComplete,
    @required this.executor,
  })  : assert(type != null),
        assert(heading != null),
        assert(executor != null),
        super(
          type: type,
          heading: heading,
          description: description,
          instructions: instructions,
          minutesToComplete: minutesToComplete,
        );

  void onPressed(BuildContext context) {
    print(">>> onPressed in SensingUserTask, executor: $executor, state: ${executor?.state}");
    executor?.resume();
    onDone();
  }

  void onDone() {
    super.onDone();
  }
}

class SurveyUserTask extends SensingUserTask {
  BuildContext _context;
  SurveyProbe mySurveyProbe;

  SurveyUserTask({
    @required UserTaskType type,
    String heading,
    String description,
    String instructions,
    int minutesToComplete,
    @required TaskExecutor executor,
  })  : assert(type != null),
        assert(heading != null),
        assert(executor != null),
        super(
          type: type,
          heading: heading,
          description: description,
          instructions: instructions,
          minutesToComplete: minutesToComplete,
          executor: executor,
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
    // check if this task is created (i.e. new) before starting it
    // TODO - allow for resuming paused tasks?
    if (state == UserTaskState.created) {
      _context = context;
      mySurveyProbe.onSurveyTriggered = onSurveyTriggered;
      mySurveyProbe.onSurveySubmit = onSurveySubmit;

      executor?.resume();

      state = UserTaskState.done;
    }
  }

  void onSurveyTriggered(SurveyPage surveyPage) {
    Navigator.of(_context).push(MaterialPageRoute(builder: (context) => surveyPage));
  }

  void onSurveySubmit(RPTaskResult result) {
    executor?.pause();
    onDone();
  }
}

class AudioUserTask extends SensingUserTask {
  StreamController<int> _countDownController = StreamController<int>();
  Stream<int> get countDownEvents => _countDownController.stream.asBroadcastStream();

  /// Duration of audio recording in seconds.
  int recordingDuration;

  AudioUserTask({
    @required UserTaskType type,
    String heading,
    String description,
    String instructions,
    int minutesToComplete,
    this.recordingDuration = 30,
    @required TaskExecutor executor,
  })  : assert(type != null),
        assert(heading != null),
        assert(executor != null),
        super(
          type: type,
          heading: heading,
          description: description,
          instructions: instructions,
          minutesToComplete: minutesToComplete,
          executor: executor,
        );

  void onPressed(BuildContext context) {
    // check if this task is created (i.e. new) before starting it
    // TODO - allow for resuming paused tasks?
    if (state == UserTaskState.created) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AudioMeasurePage(audioUserTask: this)));
    }
  }

  /// Callback when recording is to start.
  void onRecord() {
    // only allow to start recording if not already started.
    if (state == UserTaskState.created) {
      state = UserTaskState.resumed;
      executor?.resume();

      Timer.periodic(new Duration(seconds: 1), (timer) {
        _countDownController.add(--recordingDuration);

        if (recordingDuration == 0) {
          timer.cancel();
          _countDownController.close();

          executor?.pause();
          state = UserTaskState.done;
        }
      });
    }
  }

  /// Callback when recording is to stop.
  void onStop() {
    state = UserTaskState.done;
    executor?.pause();
  }
}

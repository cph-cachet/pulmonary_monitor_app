part of pulmonary_monitor_app;

class AudioUserTask extends UserTask {
  static const String AUDIO_TYPE = 'audio';

  StreamController<int> _countDownController =
      StreamController<int>.broadcast();
  Stream<int> get countDownEvents => _countDownController.stream;

  /// Duration of audio recording in seconds.
  int recordingDuration = 10;

  AudioUserTask(AppTaskExecutor executor) : super(executor);

  void onStart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AudioMeasurePage(audioUserTask: this)),
    );
  }

  /// Callback when recording is to start.
  void onRecord() {
    state = UserTaskState.started;
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

class PulmonaryUserTaskFactory implements UserTaskFactory {
  List<String> types = [
    SurveyUserTask.SURVEY_TYPE,
    SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE,
    AudioUserTask.AUDIO_TYPE,
  ];

  UserTask create(AppTaskExecutor executor) {
    switch (executor.appTask.type) {
      case SurveyUserTask.SURVEY_TYPE:
      case SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE:
        return SurveyUserTask(executor);
      case AudioUserTask.AUDIO_TYPE:
        return AudioUserTask(executor);
      default:
        return SensingUserTask(executor);
    }
  }
}

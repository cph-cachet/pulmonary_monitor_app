part of pulmonary_monitor_app;

/// A user task handling audio recordings.
/// When started, creates a [AudioMeasurePage] and shows it to the user.
class AudioUserTask extends UserTask {
  static const String AUDIO_TYPE = 'audio';

  StreamController<int> _countDownController = StreamController.broadcast();
  Stream<int> get countDownEvents => _countDownController.stream;

  /// Duration of audio recording in seconds.
  int recordingDuration = 10;

  AudioUserTask(AppTaskExecutor executor) : super(executor);

  void onStart(BuildContext context) {
    super.onStart(context);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AudioMeasurePage(audioUserTask: this)),
    );
  }

  /// Callback when recording is to start.
  void onRecord() {
    executor.resume();

    Timer.periodic(new Duration(seconds: 1), (timer) {
      _countDownController.add(--recordingDuration);

      if (recordingDuration == 0) {
        timer.cancel();
        _countDownController.close();

        executor.pause();
        state = UserTaskState.done;
      }
    });
  }
}

class PulmonaryUserTaskFactory implements UserTaskFactory {
  List<String> types = [
    AudioUserTask.AUDIO_TYPE,
  ];

  UserTask create(AppTaskExecutor executor) {
    switch (executor.appTask.type) {
      case AudioUserTask.AUDIO_TYPE:
        return AudioUserTask(executor);
      default:
        return SensingUserTask(executor);
    }
  }
}

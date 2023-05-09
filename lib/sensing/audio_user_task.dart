part of pulmonary_monitor_app;

/// A user task handling audio recordings.
/// When started, creates a [AudioMeasurePage] and shows it to the user.
class AudioUserTask extends UserTask {
  static const String AUDIO_TYPE = 'audio';

  final StreamController<int> _countDownController =
      StreamController.broadcast();
  Stream<int> get countDownEvents => _countDownController.stream;
  Timer? _timer;

  /// Duration of audio recording in seconds.
  int recordingDuration = 10;

  AudioUserTask(AppTaskExecutor executor) : super(executor);

  @override
  bool get hasWidget => true;

  @override
  Widget? get widget => AudioMeasurePage(audioUserTask: this);

  /// Callback when recording is to start.
  void onRecord() {
    executor.start();

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _countDownController.add(--recordingDuration);

      if (recordingDuration <= 0) {
        _timer?.cancel();
        _countDownController.close();

        executor.stop();
        state = UserTaskState.done;
      }
    });
  }
}

class PulmonaryUserTaskFactory implements UserTaskFactory {
  @override
  List<String> types = [
    AudioUserTask.AUDIO_TYPE,
  ];

  @override
  UserTask create(AppTaskExecutor executor) {
    switch (executor.task.type) {
      case AudioUserTask.AUDIO_TYPE:
        return AudioUserTask(executor);
      default:
        return BackgroundSensingUserTask(executor);
    }
  }
}

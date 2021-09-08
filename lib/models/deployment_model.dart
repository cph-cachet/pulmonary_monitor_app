part of pulmonary_monitor_app;

class StudyDeploymentModel {
  SmartphoneDeployment deployment;

  // String get name => deployment?.name ?? '';
  String get title => deployment.protocolDescription?.title ?? '';
  String get description =>
      deployment.protocolDescription?.description ??
      'No description available.';
  Image get image => Image.asset('assets/images/running.png');
  String get userID => deployment.userId ?? '';
  // String get samplingStrategy => 'NORMAL';
  String get dataEndpoint => deployment.dataEndPoint.toString();

  /// Events on the state of the study executor
  Stream<ProbeState> get studyExecutorStateEvents =>
      Sensing().controller!.executor!.stateEvents;

  /// Current state of the study executor (e.g., resumed, paused, ...)
  ProbeState get studyState => Sensing().controller!.executor!.state;

  /// Get all sesing events (i.e. all [Datum] objects being collected).
  Stream<DataPoint> get data => Sensing().controller!.data;

  /// The total sampling size so far since this study was started.
  int get samplingSize => Sensing().controller!.samplingSize;

  StudyDeploymentModel(this.deployment) : super();
}

part of '../main.dart';

class StudyDeploymentModel {
  SmartphoneDeployment deployment;

  // String get name => deployment?.name ?? '';
  String get studyDeploymentId => deployment.studyDeploymentId;
  String get title =>
      deployment.studyDescription?.title ?? deployment.studyDeploymentId;
  String get description =>
      deployment.studyDescription?.description ?? 'No description available.';
  Image get image => Image.asset('assets/images/running.png');
  String get userID => deployment.participantId ?? '';
  // String get samplingStrategy => 'NORMAL';
  String get dataEndpoint => deployment.dataEndPoint.toString();

  /// Events on the state of the study executor
  Stream<ExecutorState> get studyExecutorStateEvents =>
      Sensing().controller!.executor.stateEvents;

  /// Current state of the study executor (e.g., resumed, paused, ...)
  ExecutorState get studyState => Sensing().controller!.executor.state;

  /// Get all sensing events (i.e. all [Datum] objects being collected).
  Stream<Measurement> get measurements => Sensing().controller!.measurements;

  /// The total sampling size so far since this study was started.
  int get samplingSize => Sensing().controller!.samplingSize;

  StudyDeploymentModel(this.deployment) : super();
}

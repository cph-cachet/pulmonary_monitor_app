// part of '../main.dart';

// class StudyDeploymentModel {
//   Study study;

//   String get name => study.name;
//   String get description => study.description ?? 'No description available.';
//   Image get image => Image.asset('assets/images/running.png');
//   String get userID => study.userId;
//   String get samplingStrategy => study.samplingStrategy;
//   String get dataEndpoint => study.dataEndPoint.toString();

//   /// Events on the state of the study executor
//   Stream<ProbeState> get studyExecutorStateEvents =>
//       bloc.sensing.controller.executor.stateEvents;

//   /// Current state of the study executor (e.g., resumed, paused, ...)
//   ProbeState get studyState => bloc.sensing.controller.executor.state;

//   /// Get all sesing events (i.e. all [Datum] objects being collected).
//   Stream<Datum> get samplingEvents => bloc.sensing.controller.events;

//   /// The total sampling size so far since this study was started.
//   int get samplingSize => bloc.sensing.controller.samplingSize;

//   StudyDeploymentModel(this.study) : super() {
//     assert(
//         study != null, 'A StudyModel must be initialized with a real Study.');
//   }
// }

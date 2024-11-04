/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of pulmonary_monitor_app;

/// This class implements the sensing layer.
///
/// In particular, it shown how sensing is configured locally on a phone, without
/// the need for using the CARP Web Service infrastructure. Hence, this app shows
/// how to create and run a protocol locally and store data locally in a SQLite
/// database.
///
/// It also shows how sensing is "recovered" during app restart.
///
/// Mo... including:
///
///  * getting a [SmartphoneStudyProtocol] from the [LocalStudyProtocolManager]
///
///
///  up a [Study] with [Task]s and [Measure]s.
class Sensing {
  static final Sensing _instance = Sensing._();
  StudyDeploymentStatus? _status;
  Study? _study;
  SmartphoneDeploymentController? _controller;
  late StudyProtocolManager manager;
  late SmartPhoneClientManager client;
  DeploymentService deploymentService = SmartphoneDeploymentService();

  SmartphoneDeployment? get deployment => _controller?.deployment;

  /// Get the status of the study deployment.
  StudyDeploymentStatus? get status => _status;
  Study? get study => _study;
  SmartphoneDeploymentController? get controller => _controller;

  /// the list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes =>
      (_controller != null) ? _controller!.executor.probes : [];

  /// the list of connected devices.
  // List<DeviceManager> get runningDevices =>
  //     DeviceController().devices.values.toList();

  /// Get the singleton sensing instance
  factory Sensing() => _instance;

  Sensing._() {
    // Create and register external sampling packages
    SamplingPackageRegistry().register(ContextSamplingPackage());
    SamplingPackageRegistry().register(MediaSamplingPackage());
    SamplingPackageRegistry().register(SurveySamplingPackage());
    // SamplingPackageRegistry().register(ConnectivitySamplingPackage());
    //SamplingPackageRegistry().register(CommunicationSamplingPackage());
    //SamplingPackageRegistry().register(AppsSamplingPackage());

    // Register the special-purpose audio user task factory
    AppTaskController().registerUserTaskFactory(PulmonaryUserTaskFactory());

    manager = LocalStudyProtocolManager();
  }

  /// Initialize and setup sensing.
  Future<void> initialize() async {
    // Get the protocol from the local study protocol manager.
    // Note that the study id is NOT used here.
    final protocol = await manager.getStudyProtocol('ignored');

    // Create and configure a client manager for this phone
    client = SmartPhoneClientManager();
    await client.configure(
      deploymentService: deploymentService,
      deviceController: DeviceController(),
    );

    // Add the study to the client directly from the protocol,
    // using the same deployment id across app restart.
    _study = await client.addStudyFromProtocol(
        protocol!, bloc.testStudyDeploymentId);

    // Get the study controller and try to deploy the study.
    //
    // Note that if the study has already been deployed on this phone
    // it has been cached locally in a file and the local cache will
    // be used pr. default.
    // If not deployed before (i.e., cached) the study deployment will be
    // fetched from the deployment service.
    _controller = client.getStudyRuntime(study!.studyDeploymentId);
    await controller?.tryDeployment(useCached: true);

    // Configure the controller
    await controller?.configure();

    // Start sampling
    controller?.start();

    // Listening on the measurements and print them as json to the debug console
    _controller!.measurements
        .listen((measurement) => print(toJsonString(measurement)));
  }
}

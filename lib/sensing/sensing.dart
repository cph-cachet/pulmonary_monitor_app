/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of pulmonary_monitor_app;

/// This class implements the sensing layer incl. setting up a [Study] with [Task]s and [Measure]s.
class Sensing {
  static final Sensing _instance = Sensing._();
  StudyDeploymentStatus? _status;
  StudyProtocol? _protocol;
  SmartphoneDeploymentController? _controller;
  late StudyProtocolManager manager;
  late SmartPhoneClientManager client;

  SmartphoneDeployment? get deployment =>
      _controller?.deployment as SmartphoneDeployment?;

  /// Get the status of the study deployment.
  StudyDeploymentStatus? get status => _status;
  StudyProtocol? get protocol => _protocol;
  SmartphoneDeploymentController? get controller => _controller;

  /// the list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes =>
      (_controller != null) ? _controller!.executor!.probes : [];

  /// the list of connected devices.
  // List<DeviceManager> get runningDevices =>
  //     DeviceController().devices.values.toList();

  /// Get the singleton sensing instance
  factory Sensing() => _instance;

  Sensing._() {
    // create and register external sampling packages
    // SamplingPackageRegistry().register(ConnectivitySamplingPackage());
    SamplingPackageRegistry().register(ContextSamplingPackage());
    SamplingPackageRegistry().register(MediaSamplingPackage());
    SamplingPackageRegistry().register(SurveySamplingPackage());
    //SamplingPackageRegistry().register(CommunicationSamplingPackage());
    //SamplingPackageRegistry().register(AppsSamplingPackage());
    // SamplingPackageRegistry().register(ESenseSamplingPackage());

    // create and register external data managers
    DataManagerRegistry().register(CarpDataManager());

    // register the special-purpose audio user task factory
    AppTaskController().registerUserTaskFactory(PulmonaryUserTaskFactory());

    manager = LocalStudyProtocolManager();
  }

  /// Initialize and setup sensing.
  Future<void> initialize() async {
    // get the protocol from the study protocol manager based on the
    // study deployment id
    _protocol = await manager.getStudyProtocol(testStudyDeploymentId);

    // deploy this protocol using the on-phone deployment service
    // reuse the study deployment id, so we have the same id on the phone deployment
    _status = await SmartphoneDeploymentService().createStudyDeployment(
      _protocol!,
      testStudyDeploymentId,
    );

    String deviceRolename = _status!.masterDeviceStatus!.device.roleName;

    // create and configure a client manager for this phone
    client = SmartPhoneClientManager();
    await client.configure();

    // add and deploy this study deployment
    _controller = await client.addStudy(testStudyDeploymentId, deviceRolename);
    await _controller?.tryDeployment();

    // configure the controller and resume sampling
    await _controller!.configure(
      privacySchemaName: PrivacySchema.DEFAULT,
    );
    // controller.resume();

    // listening on the data stream and print them as json to the debug console
    _controller!.data.listen((data) => print(toJsonString(data)));
  }
}

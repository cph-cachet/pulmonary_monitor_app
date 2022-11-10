import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_connectivity_package/connectivity.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_audio_package/media.dart';
import 'package:carp_survey_package/survey.dart';

import '../lib/main.dart';

String _encode(Object object) =>
    const JsonEncoder.withIndent(' ').convert(object);

void main() {
  // creating an empty protocol to initialize json serialization
  StudyProtocol? protocol;
  late Smartphone phone;
  late LocationService loc;

  setUp(() async {
    // register the different sampling package since we're using measures from them
    SamplingPackageRegistry().register(ConnectivitySamplingPackage());
    SamplingPackageRegistry().register(ContextSamplingPackage());
    SamplingPackageRegistry().register(MediaSamplingPackage());
    SamplingPackageRegistry().register(SurveySamplingPackage());

    // Initialization of serialization
    CarpMobileSensing();

    // Define which devices are used for data collection.
    phone = Smartphone();
    loc = LocationService();
  });

  group("Local Study Protocol Manager", () {
    setUp(() async {
      // generate the protocol
      protocol = await LocalStudyProtocolManager()
          .getStudyProtocol('CAMS App v 0.33.0');
    });

    test('CAMSStudyProtocol -> JSON', () async {
      print(protocol);
      print(_encode(protocol!));
      expect(protocol?.ownerId, 'alex@uni.dk');
    });

    test('StudyProtocol -> JSON -> StudyProtocol :: deep assert', () async {
      print('#1 : $protocol');
      final studyJson = _encode(protocol!);

      SmartphoneStudyProtocol protocolFromJson =
          SmartphoneStudyProtocol.fromJson(
              json.decode(studyJson) as Map<String, dynamic>);
      expect(_encode(protocolFromJson), equals(studyJson));
      print('#2 : $protocolFromJson');
    });

    test('JSON File -> StudyProtocol', () async {
      // Read the study protocol from json file
      String plainJson = File('test/json/protocol.json').readAsStringSync();

      StudyProtocol protocol = StudyProtocol.fromJson(
          json.decode(plainJson) as Map<String, dynamic>);

      expect(protocol.ownerId, 'abc@dtu.dk');
      expect(protocol.masterDevices.first.roleName, phone.roleName);
      expect(protocol.connectedDevices.first.roleName, loc.roleName);
      print(_encode(protocol));
    });
  });
}

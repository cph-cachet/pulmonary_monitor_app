library pulmonary_monitor_app;

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/services.dart';

// the CARP packages
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
//import 'package:carp_connectivity_package/connectivity.dart';
//import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:carp_audio_package/media.dart';
//import 'package:carp_health_package/health_package.dart';
// import 'package:carp_backend/carp_backend.dart';

import 'package:research_package/research_package.dart';
import 'package:cognition_package/cognition_package.dart';

part 'app.dart';
part 'bloc/sensing_bloc.dart';
part 'sensing/sensing.dart';
part 'sensing/surveys.dart';
part 'sensing/audio_user_task.dart';
part 'sensing/study_protocol_manager.dart';
part 'sensing/informed_consent.dart';
part 'model/probe_description.dart';
part 'model/deployment_model.dart';
part 'ui/task_list_page.dart';
part 'ui/data_viz_page.dart';
part 'ui/study_viz_page.dart';
part 'ui/informed_consent_page.dart';
part 'ui/cachet.dart';
part 'ui/audio_measure_page.dart';

void main() {
  // Make sure to initialize CAMS incl. json serialization
  CarpMobileSensing.ensureInitialized();
  CognitionPackage.ensureInitialized();

  runApp(const App());
}

String toJsonString(Object object) =>
    const JsonEncoder.withIndent(' ').convert(object);

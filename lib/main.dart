library pulmonary_monitor_app;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:research_package/research_package.dart';
import 'research_package_objects/infomed_consent_objects.dart';
import 'research_package_objects/linear_survey_objects.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
//import 'package:carp_connectivity_package/connectivity.dart';
//import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:carp_audio_package/audio.dart';
//import 'package:carp_health_package/health_package.dart';
import 'package:carp_backend/carp_backend.dart';

part 'app.dart';
part 'sensing/sensing.dart';
part 'sensing/surveys.dart';
part 'sensing/user_task.dart';
part 'models/probe_description.dart';
part 'models/study_model.dart';
part 'models/data_models.dart';
part 'blocs/sensing_bloc.dart';
part 'blocs/settings_bloc.dart';
part 'ui/task_list_page.dart';
part 'ui/data_viz_page.dart';
part 'ui/study_viz_page.dart';
part 'ui/informed_consent_page.dart';
part 'ui/linear_survey_page.dart';
part 'ui/cachet.dart';
part 'ui/audio_measure_page.dart';

void main() {
  runApp(PulmonaryMonitorApp());
}

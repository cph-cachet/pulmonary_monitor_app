library pulmonary_monitor_app;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
//import 'package:carp_connectivity_package/connectivity.dart';
//import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:research_package/research_package.dart';
import 'package:carp_audio_package/audio.dart';
//import 'package:carp_health_package/health_package.dart';
import 'package:carp_backend/carp_backend.dart';

part 'app.dart';
part 'sensing/sensing.dart';
part 'sensing/surveys.dart';
part 'models/probe_models.dart';
part 'models/probe_description.dart';
part 'models/study_model.dart';
part 'models/data_models.dart';
part 'blocs/sensing_bloc.dart';
part 'blocs/settings_bloc.dart';
part 'ui/probe_list.dart';
part 'ui/data_viz.dart';
part 'ui/survey_ui.dart';
part 'ui/study_viz.dart';
part 'ui/cachet.dart';

void main() {
  runApp(App());
}

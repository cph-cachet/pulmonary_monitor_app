//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

import 'linear_survey_page.dart';
import 'research_package_objects/infomed_consent_objects.dart';
import 'dart:convert';

class InformedConsentPage extends StatefulWidget {
  @override
  State createState() => new _InformedConsentPage();
}

class _InformedConsentPage extends State<InformedConsentPage> {
  String _encode(Object object) =>
      const JsonEncoder.withIndent(' ').convert(object);

  void resultCallback(RPTaskResult result, BuildContext context) {
    // Do anything with the result
    print(_encode(result));

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LinearSurveyPage()));
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: consentTask,
      onSubmit: (result) {
        resultCallback(result, context);
      },
    );
  }
}

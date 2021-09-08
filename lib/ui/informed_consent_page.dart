part of pulmonary_monitor_app;

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
      task: LocalResourceManager().informedConsent,
      onSubmit: (result) {
        resultCallback(result, context);
      },
    );
  }
}

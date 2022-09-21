/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of pulmonary_monitor_app;

/// A local resource manager handling:
///  * informed consent
///  * localization
class LocalResourceManager
    implements InformedConsentManager, LocalizationManager {
  RPOrderedTask? _informedConsent;

  static final LocalResourceManager _instance = LocalResourceManager._();
  factory LocalResourceManager() => _instance;

  LocalResourceManager._() {
    // to initialize json serialization for RP classes
    RPOrderedTask(identifier: '', steps: []);
  }

  @override
  Future initialize() async {
    // initialize local cached values
    await getInformedConsent();
  }

  @override
  RPOrderedTask get informedConsent =>
      _informedConsent ??
      RPOrderedTask(
        identifier: 'empty',
        steps: [],
      );

  @override
  Future<RPOrderedTask?> getInformedConsent() async {
    if (_informedConsent == null) {
      RPConsentSection overviewSection = RPConsentSection(
          type: RPConsentSectionType.Overview)
        ..summary = "Welcome to this survey"
        ..content =
            "Overview dolor sit amet, consectetur adipiscing elit. Aenean a mi porttitor, bibendum elit elementum, placerat augue. Quisque eu sollicitudin tortor, sed egestas ante. Sed convallis, mauris quis malesuada convallis, lectus ante vestibulum ante, vel lobortis magna dui eu nisl. Proin ac pellentesque nulla. Morbi facilisis dui aliquam quam pulvinar efficitur. Duis at lorem vitae leo pharetra ultricies. Proin viverra eleifend varius. Nulla sed nisi ut enim placerat venenatis. Maecenas imperdiet accumsan ligula id varius. Donec rhoncus gravida odio vitae convallis.Nullam at tempor erat. Praesent euismod orci nec sollicitudin placerat. Nunc nec nibh efficitur, mattis ante sit amet, scelerisque libero. Aliquam et mollis erat. Pellentesque aliquam convallis turpis sit amet molestie. Duis accumsan venenatis imperdiet. Integer quis est non elit varius mattis. Donec hendrerit in nisl eget sollicitudin. Nulla sapien lacus, mattis non orci sed, commodo tincidunt risus.";

      RPConsentSection dataGatheringSection = RPConsentSection(
          type: RPConsentSectionType.DataGathering)
        ..summary = "This is a summary for Data Gathering."
        ..content =
            "Data Gathering dolor sit amet, consectetur adipiscing elit. Aenean a mi porttitor, bibendum elit elementum, placerat augue. Quisque eu sollicitudin tortor, sed egestas ante. Sed convallis, mauris quis malesuada convallis, lectus ante vestibulum ante, vel lobortis magna dui eu nisl. Proin ac pellentesque nulla. Morbi facilisis dui aliquam quam pulvinar efficitur. Duis at lorem vitae leo pharetra ultricies. Proin viverra eleifend varius. Nulla sed nisi ut enim placerat venenatis. Maecenas imperdiet accumsan ligula id varius. Donec rhoncus gravida odio vitae convallis.Nullam at tempor erat. Praesent euismod orci nec sollicitudin placerat. Nunc nec nibh efficitur, mattis ante sit amet, scelerisque libero. Aliquam et mollis erat. Pellentesque aliquam convallis turpis sit amet molestie. Duis accumsan venenatis imperdiet. Integer quis est non elit varius mattis. Donec hendrerit in nisl eget sollicitudin. Nulla sapien lacus, mattis non orci sed, commodo tincidunt risus.";

      RPConsentSection privacySection = RPConsentSection(
          type: RPConsentSectionType.Privacy)
        ..summary = "This is a summary for Privacy."
        ..content =
            "Privacy dolor sit amet, consectetur adipiscing elit. Aenean a mi porttitor, bibendum elit elementum, placerat augue. Quisque eu sollicitudin tortor, sed egestas ante. Sed convallis, mauris quis malesuada convallis, lectus ante vestibulum ante, vel lobortis magna dui eu nisl. Proin ac pellentesque nulla. Morbi facilisis dui aliquam quam pulvinar efficitur. Duis at lorem vitae leo pharetra ultricies. Proin viverra eleifend varius. Nulla sed nisi ut enim placerat venenatis. Maecenas imperdiet accumsan ligula id varius. Donec rhoncus gravida odio vitae convallis.Nullam at tempor erat. Praesent euismod orci nec sollicitudin placerat. Nunc nec nibh efficitur, mattis ante sit amet, scelerisque libero. Aliquam et mollis erat. Pellentesque aliquam convallis turpis sit amet molestie. Duis accumsan venenatis imperdiet. Integer quis est non elit varius mattis. Donec hendrerit in nisl eget sollicitudin. Nulla sapien lacus, mattis non orci sed, commodo tincidunt risus.";

      RPConsentSection timeCommitmentSection = RPConsentSection(
          type: RPConsentSectionType.TimeCommitment)
        ..summary = "This is a summary for Time Commitment."
        ..content =
            "Time commitment dolor sit amet, consectetur adipiscing elit. Aenean a mi porttitor, bibendum elit elementum, placerat augue. Quisque eu sollicitudin tortor, sed egestas ante. Sed convallis, mauris quis malesuada convallis, lectus ante vestibulum ante, vel lobortis magna dui eu nisl. Proin ac pellentesque nulla. Morbi facilisis dui aliquam quam pulvinar efficitur. Duis at lorem vitae leo pharetra ultricies. Proin viverra eleifend varius. Nulla sed nisi ut enim placerat venenatis. Maecenas imperdiet accumsan ligula id varius. Donec rhoncus gravida odio vitae convallis.Nullam at tempor erat. Praesent euismod orci nec sollicitudin placerat. Nunc nec nibh efficitur, mattis ante sit amet, scelerisque libero. Aliquam et mollis erat. Pellentesque aliquam convallis turpis sit amet molestie. Duis accumsan venenatis imperdiet. Integer quis est non elit varius mattis. Donec hendrerit in nisl eget sollicitudin. Nulla sapien lacus, mattis non orci sed, commodo tincidunt risus.";

      RPConsentSignature signature =
          RPConsentSignature(identifier: "consentSignatureID");

      RPConsentDocument consentDocument = RPConsentDocument(
          title: 'Demo Consent',
          sections: [
            overviewSection,
            dataGatheringSection,
            privacySection,
            timeCommitmentSection
          ])
        ..addSignature(signature);

      RPConsentReviewStep consentReviewStep = RPConsentReviewStep(
        identifier: "consentreviewstepID",
        consentDocument: consentDocument,
      )
        ..reasonForConsent = 'By tapping AGREE you can take part in the study'
        ..text = 'Agreed?'
        ..title = "Consent Review Step Title";

      RPVisualConsentStep consentVisualStep = RPVisualConsentStep(
        identifier: "visualStep",
        consentDocument: consentDocument,
      );

      RPInstructionStep intoductionStep = RPInstructionStep(
        identifier: "introductionID",
        title: "Welcome!",
        text:
            "Welcome to this study! We would like to kindly ask you to look over these terms and information which gives you an introduction to the study.",
        detailText:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ultricies feugiat turpis nec efficitur. Integer in pharetra libero. Proin a leo eu enim porttitor hendrerit. Suspendisse vestibulum interdum mollis. Donec in sapien ut orci ultricies laoreet. Ut maximus ante id arcu feugiat scelerisque. Proin non rutrum libero. Aliquam blandit arcu ac dolor consequat maximus. Integer et dolor quis quam tempor porta quis vel nibh. Phasellus ullamcorper fringilla lorem, ac tempus sem cursus a. Aliquam maximus facilisis quam. Morbi hendrerit tempor tellus, ac hendrerit augue tincidunt eu. Cras convallis lorem at nulla mattis tristique.",
        footnote: "(1) Important footnote",
        imagePath: "assets/images/waving-hand.png",
      );

      RPCompletionStep finalStep = RPCompletionStep(
        identifier: "finalID",
        title: "Thank You!",
        text: "We saved your consent document.",
      );

      _informedConsent = RPOrderedTask(
        identifier: "consentTaskID",
        steps: [
          intoductionStep,
          consentVisualStep,
          consentReviewStep,
          finalStep
        ],
      );
    }
    return _informedConsent;
  }

  @override
  Future<bool> setInformedConsent(RPOrderedTask informedConsent) async {
    _informedConsent = informedConsent;
    return true;
  }

  @override
  Future<bool> deleteInformedConsent() async {
    _informedConsent = null;
    return true;
  }

  @override
  Future<bool> deleteLocalizations(Locale locale) {
    throw UnimplementedError();
  }

  final String basePath = 'assets/lang';

  @override
  Future<Map<String, String>> getLocalizations(Locale locale) async {
    String path = '$basePath/${locale.languageCode}.json';
    print("$runtimeType - loading '$path'");
    String jsonString = await rootBundle.loadString(path);

    Map<String, dynamic> jsonMap =
        json.decode(jsonString) as Map<String, dynamic>;
    Map<String, String> translations =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    return translations;
  }

  @override
  Future<bool> setLocalizations(
      Locale locale, Map<String, dynamic> localizations) {
    throw UnimplementedError();
  }
}

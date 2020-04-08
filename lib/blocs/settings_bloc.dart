part of pulmonary_monitor_app;

class SettingsBLoC {
  // Generate a unique and anonymous user id for this user.
  // TODO - should be persisted between app restarts
  String _userId = Uuid().v4();

  /// The unique anonymous user id.
  String get userId => _userId;

  String get studyId => "2";

  /// The CARP username.
  String get username => "researcher@example.com";

  /// The CARP password.
  String get password => "..."; //decrypt("lkjhf98sdvhcksdmnfewoiywefhowieyurpo2hjr");

  /// The URI of the CARP server.
  String get uri => "http://staging.carp.cachet.dk:8080";

  String get clientID => "carp";
  String get clientSecret => "carp";
}

final settings = SettingsBLoC();

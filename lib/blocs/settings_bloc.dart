part of pulmonary_monitor_app;

class SettingsBLoC {
  static const String USER_UI_KEY = "user_id";

  SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get preferences async {
    if (_preferences == null) _preferences = await SharedPreferences.getInstance();
    return _preferences;
  }

  String _userId;

  /// The unique anonymous user id.
  ///
  /// This id is stored on the phone in-between session and should therefore be the same for the same phone.
  Future<String> get userId async {
    if (_userId == null) {
      _userId = (await preferences).get(USER_UI_KEY);
      if (_userId == null) {
        _userId = Uuid().v4();
        (await preferences).setString(USER_UI_KEY, _userId);
      }
    }
    return _userId;
  }

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

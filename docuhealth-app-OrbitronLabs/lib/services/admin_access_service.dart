class AdminAccessService {
  static final AdminAccessService _instance = AdminAccessService._internal();
  factory AdminAccessService() => _instance;
  AdminAccessService._internal();

  static const Duration _sessionDuration = Duration(minutes: 30);

  String? _deviceId;
  String? _password;
  DateTime? _authenticatedAt;

  bool isSessionActiveFor(String? deviceId) {
    if (deviceId == null ||
        deviceId.isEmpty ||
        _deviceId != deviceId ||
        _password == null ||
        _authenticatedAt == null) {
      return false;
    }

    final isExpired =
        DateTime.now().difference(_authenticatedAt!) > _sessionDuration;
    if (isExpired) {
      clearSession();
      return false;
    }

    return true;
  }

  String? passwordFor(String? deviceId) {
    if (!isSessionActiveFor(deviceId)) {
      return null;
    }
    return _password;
  }

  DateTime? authenticatedAtFor(String? deviceId) {
    if (!isSessionActiveFor(deviceId)) {
      return null;
    }
    return _authenticatedAt;
  }

  void openSession({
    required String deviceId,
    required String password,
  }) {
    _deviceId = deviceId;
    _password = password;
    _authenticatedAt = DateTime.now();
  }

  void clearSession() {
    _deviceId = null;
    _password = null;
    _authenticatedAt = null;
  }
}

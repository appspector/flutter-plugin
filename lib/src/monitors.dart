enum SupportedPlatform { android, ios }

/// Class which contains description of monitor
class Monitor {
  /// Monitor identifier
  final String id;

  /// List of platforms which support this monitor
  final List<SupportedPlatform> platforms;

  const Monitor._androidMonitor(this.id)
      : platforms = const [SupportedPlatform.android];

  const Monitor._iosMonitor(this.id)
      : platforms = const [SupportedPlatform.ios];

  const Monitor._commonMonitor(this.id)
      : platforms = const [SupportedPlatform.android, SupportedPlatform.ios];
}

/// Identifiers for supported monitors
class Monitors {
  Monitors._();

  static const http = const Monitor._commonMonitor("http");
  static const logs = const Monitor._commonMonitor("logs");
  static const fileSystem = const Monitor._commonMonitor("file-system");
  static const screenshot = const Monitor._commonMonitor("screenshot");
  static const environment = const Monitor._commonMonitor("environment");
  static const location = const Monitor._commonMonitor("location");
  static const performance = const Monitor._commonMonitor("performance");
  static const sqLite = const Monitor._commonMonitor("sqlite");
  static const sharedPreferences =
      const Monitor._androidMonitor("shared-preferences");
  static const analytics = const Monitor._iosMonitor("analytics");
  static const notification = const Monitor._iosMonitor("notification-center");
  static const userDefaults = const Monitor._iosMonitor("user-defaults");
  static const coreData = const Monitor._iosMonitor("ios-core-data");

  static List<Monitor> all() => [
        http,
        logs,
        screenshot,
        environment,
        location,
        performance,
        sqLite,
        fileSystem,
        analytics,
        notification,
        userDefaults,
        coreData,
        sharedPreferences
      ];
}

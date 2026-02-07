import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../core/core.dart';

class Environments {
  Environments._();

  static String? param(String param) {
    return FirebaseRemoteConfig.instance.getString(
      "${FlavorConfig.appFlavor.toUpperCase()}_$param",
    );
  }

  static Future<void> loadEnv() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 5),
        minimumFetchInterval: Duration(seconds: 10),
      ),
    );
    remoteConfig.setDefaults({'DEV_API_URL': ''});
    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      await remoteConfig.activate();
    }
  }
}

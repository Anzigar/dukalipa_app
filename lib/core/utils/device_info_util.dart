import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfoUtil {
  static const String _deviceIdKey = 'device_id';
  static const Uuid _uuid = Uuid();

  static Future<Map<String, String>> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceId = await _getOrCreateDeviceId();
    
    return {
      'device_id': deviceId,
      'device_name': await _getDeviceName(),
      'platform': Platform.operatingSystem,
      'app_version': packageInfo.version,
      'os_version': Platform.operatingSystemVersion,
    };
  }

  static Future<String> _getOrCreateDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = _uuid.v4();
        await prefs.setString(_deviceIdKey, deviceId);
      }
      return deviceId;
    } catch (e) {
      return _uuid.v4();
    }
  }

  static Future<String> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        return 'Android Device';
      } else if (Platform.isIOS) {
        return 'iOS Device';
      } else if (Platform.isMacOS) {
        return 'macOS Device';
      } else if (Platform.isWindows) {
        return 'Windows Device';
      } else if (Platform.isLinux) {
        return 'Linux Device';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }
}
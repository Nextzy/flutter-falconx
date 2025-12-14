import 'package:flutter_faltool/lib.dart';

class DeviceIdGenerator {
  static const String _deviceIdKey = 'device_id_key';
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Generates or retrieves a persistent device ID
  static Future<String> getDeviceId() async {
    // Try to get cached device ID first
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);

    if (deviceId != null) {
      return deviceId;
    }

    // Generate new device ID if none exists
    deviceId = await _generateDeviceId();
    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  static Future<String> _generateDeviceId() async {
    final deviceData = StringBuffer();

    try {
      if (PlatformChecker.isAndroid) {
        final udid = await FlutterUdid.udid;
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData.writeAll([
          udid,
          androidInfo.id, // Android ID
          androidInfo.brand, // Device brand
          androidInfo.model, // Device model
          androidInfo.device, // Device name
          androidInfo.product, // Product name
          androidInfo.hardware, // Hardware name
          androidInfo.display, // Display info
        ]);
      } else if (PlatformChecker.isIos) {
        final udid = await FlutterUdid.udid;
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData.writeAll([
          udid,
          iosInfo.identifierForVendor ?? '', // Vendor ID
          iosInfo.model, // Device model
          iosInfo.name, // Device name
          iosInfo.systemName, // OS name
          iosInfo.systemVersion, // OS version
          iosInfo.localizedModel, // Localized model
          iosInfo.utsname.machine, // Machine type
        ]);
      } else if (PlatformChecker.isMacOs) {
        final udid = await FlutterUdid.udid;
        final macOsInfo = await _deviceInfo.macOsInfo;
        deviceData.writeAll([
          udid,
          macOsInfo.computerName, // Computer name
          macOsInfo.hostName, // Host name
          macOsInfo.arch, // Architecture
          macOsInfo.model, // Model
          macOsInfo.kernelVersion, // Kernel version
          macOsInfo.osRelease, // OS release
        ]);
      } else if (PlatformChecker.isWindows) {
        final udid = await FlutterUdid.udid;
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceData.writeAll([
          udid,
          windowsInfo.computerName, // Computer name
          windowsInfo.numberOfCores.toString(), // CPU cores
          windowsInfo.systemMemoryInMegabytes.toString(), // RAM
          windowsInfo.userName, // User name
          windowsInfo.majorVersion.toString(), // Windows major version
          windowsInfo.minorVersion.toString(), // Windows minor version
        ]);
      } else if (PlatformChecker.isLinux) {
        final udid = await FlutterUdid.udid;
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceData.writeAll([
          udid,
          linuxInfo.id, // Linux ID
          linuxInfo.name, // Linux name
          linuxInfo.version, // Linux version
          linuxInfo.machineId ?? '', // Machine ID
          linuxInfo.prettyName, // Pretty name
        ]);
      } else if (PlatformChecker.isWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceData.writeAll([
          webInfo.userAgent ?? '', // User agent
          webInfo.browserName.name, // Browser name
          webInfo.platform ?? '', // Platform
          webInfo.language ?? '', // Language
          webInfo.vendor ?? '', // Vendor
          webInfo.hardwareConcurrency?.toString() ?? '', // CPU cores
          webInfo.deviceMemory?.toString() ?? '', // Device memory
        ]);
      } else {
        // Fallback for other platforms
        final now = DateTime.now();
        deviceData.writeAll([
          now.millisecondsSinceEpoch.toString(),
          now.timeZoneName,
          Platform.operatingSystem,
          Platform.localHostname,
        ]);
      }
    } catch (e) {
      // Fallback if device info fails
      final now = DateTime.now();
      deviceData.writeAll([
        now.millisecondsSinceEpoch.toString(),
        now.timeZoneName,
        Platform.operatingSystem,
        Platform.localHostname,
      ]);
    }

    // Add some common system properties for additional uniqueness
    deviceData.writeAll([
      Platform.operatingSystem,
      Platform.operatingSystemVersion,
      Platform.localHostname,
      DateTime.now().timeZoneName,
    ]);

    // Generate SHA-256 hash of the device data
    final bytes = utf8.encode(deviceData.toString());
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateService {
  static bool _dialogShown = false;

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final int currentVersion = int.tryParse(packageInfo.buildNumber) ?? 0;
      final doc = await FirebaseFirestore.instance
          .collection('AppSettings')
          .doc('version')
          .get();

      if (!doc.exists) return;

      final data = doc.data() ?? {};
      final int minVersion = _parseVersion(data['minVersion']);
      final int latestVersion = _parseVersion(data['latestVersion']);
      final String message = data['updateMessage'] ?? 'يوجد تحديث جديد متاح';

      if (_dialogShown) return;

      if (currentVersion < minVersion) {
        _dialogShown = true;
        _showForceDialog(context, message);
      } else if (currentVersion < latestVersion) {
        _dialogShown = true;
        _showOptionalDialog(context, message);
      }
    } catch (_) {}
  }

  static int _parseVersion(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static void _showForceDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('تحديث إجباري'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: _openStore,
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  static void _showOptionalDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تحديث متاح'),
        content: Text(message),
        actions: [
          ElevatedButton(onPressed: _openStore, child: const Text('تحديث')),
        ],
      ),
    );
  }

  static Future<void> _openStore() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

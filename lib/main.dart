import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MoneyManagerApp(),
    ),
  );
}

/// Request notification permission on Android 13+.
Future<void> requestNotificationPermission() async {
  if (!Platform.isAndroid) return;
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

/// MethodChannel to communicate with native SmsBroadcastReceiver.
const _smsChannel = MethodChannel('com.moneymanager/sms');

/// Read pending SMS stored by the native BroadcastReceiver while app was closed.
Future<List<Map<String, String>>> getPendingSmsFromNative() async {
  if (!Platform.isAndroid) return [];
  try {
    final result = await _smsChannel.invokeMethod('getPendingSms');
    if (result == null) return [];
    return (result as List).map((item) {
      final m = Map<String, dynamic>.from(item as Map);
      return {
        'sender': m['sender']?.toString() ?? '',
        'body': m['body']?.toString() ?? '',
        'timestamp': m['timestamp']?.toString() ?? '',
      };
    }).toList();
  } on PlatformException {
    return [];
  }
}

/// Clear pending SMS after processing.
Future<void> clearPendingSmsNative() async {
  if (!Platform.isAndroid) return;
  try {
    await _smsChannel.invokeMethod('clearPendingSms');
  } on PlatformException {
    // ignore
  }
}

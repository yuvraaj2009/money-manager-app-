import 'dart:io';

import 'package:flutter/material.dart';
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
/// Called once after first frame from app.dart via addPostFrameCallback.
Future<void> requestNotificationPermission() async {
  if (!Platform.isAndroid) return;
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

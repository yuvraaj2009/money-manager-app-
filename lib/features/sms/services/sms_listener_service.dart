import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:another_telephony/telephony.dart';

import '../../../data/remote/sms_api.dart';

/// Bank sender ID keywords to filter SMS
const _bankKeywords = [
  'SBI', 'HDFC', 'ICICI', 'AXIS', 'KOTAK', 'PNB', 'BOB', 'CANARA', 'UNION', 'IDBI',
];

/// Background SMS handler — must be a top-level function for telephony package
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) {
  // Background handling is limited; foreground listener does the real work
  debugPrint('[SMS] Background message from: ${message.address}');
}

class SmsListenerService {
  final Telephony _telephony = Telephony.instance;
  final SmsApi _smsApi;
  final FlutterSecureStorage _storage;

  static const _prefKey = 'sms_auto_tracking';

  SmsListenerService(this._smsApi, [FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  /// Check if SMS auto-tracking is enabled in preferences
  Future<bool> isEnabled() async {
    final value = await _storage.read(key: _prefKey);
    return value == 'true';
  }

  /// Save SMS tracking preference
  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _prefKey, value: enabled.toString());
  }

  /// Start listening for incoming SMS
  void startListening() {
    _telephony.listenIncomingSms(
      onNewMessage: _onSmsReceived,
      onBackgroundMessage: backgroundMessageHandler,
      listenInBackground: false,
    );
    debugPrint('[SMS] Listener started');
  }

  /// Stop listening (called when toggled off)
  void stopListening() {
    // telephony package doesn't expose a stop method;
    // toggling off just prevents processing in _onSmsReceived
    debugPrint('[SMS] Listener stopped');
  }

  /// Filter and process incoming SMS
  Future<void> _onSmsReceived(SmsMessage message) async {
    final sender = message.address?.toUpperCase() ?? '';
    final body = message.body ?? '';

    // Check if this is from a bank
    final isBank = _bankKeywords.any((kw) => sender.contains(kw));
    if (!isBank || body.isEmpty) return;

    debugPrint('[SMS] Bank SMS detected from: $sender');

    // Check if tracking is still enabled
    final enabled = await isEnabled();
    if (!enabled) return;

    try {
      final result = await _smsApi.parseSms(body);
      final parsed = result['transaction'];
      if (parsed != null) {
        final amount = parsed['amount'] ?? '';
        final merchant = parsed['description'] ?? parsed['merchant'] ?? 'Unknown';
        debugPrint('[SMS] Parsed: Rs$amount at $merchant');
        // Notification would be shown here via flutter_local_notifications
        // For now we log — notification integration is a follow-up
      }
    } catch (e) {
      debugPrint('[SMS] Parse failed: $e');
    }
  }
}

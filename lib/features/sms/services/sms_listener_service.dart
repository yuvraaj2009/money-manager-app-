import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:another_telephony/telephony.dart';

import '../../../data/remote/sms_api.dart';

/// Bank sender ID keywords to filter SMS
const _bankKeywords = [
  'SBI', 'HDFC', 'ICICI', 'AXIS', 'KOTAK', 'PNB', 'PNBSMS', 'BOB', 'BOBONE',
  'BOBCARD', 'CANARA', 'UNION', 'IDBI',
];

/// Background SMS handler — must be a top-level function for telephony package
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) {
  debugPrint('SMS_LISTENER: Background handler triggered from: ${message.address}');
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
    debugPrint('SMS_LISTENER: isEnabled check = $value');
    return value == 'true';
  }

  /// Save SMS tracking preference
  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _prefKey, value: enabled.toString());
    debugPrint('SMS_LISTENER: setEnabled = $enabled');
  }

  /// Start listening for incoming SMS
  void startListening() {
    _telephony.listenIncomingSms(
      onNewMessage: _onSmsReceived,
      onBackgroundMessage: backgroundMessageHandler,
      listenInBackground: false,
    );
    debugPrint('SMS_LISTENER: Listener STARTED');
  }

  /// Stop listening (called when toggled off)
  void stopListening() {
    debugPrint('SMS_LISTENER: Listener STOPPED');
  }

  /// Filter and process incoming SMS
  Future<void> _onSmsReceived(SmsMessage message) async {
    final sender = message.address?.toUpperCase() ?? '';
    final body = message.body ?? '';

    debugPrint('SMS_LISTENER: telephony listener triggered');
    debugPrint('SMS_LISTENER: sender = $sender');
    debugPrint('SMS_LISTENER: body = ${body.length > 100 ? body.substring(0, 100) : body}');

    // Check if this is from a bank
    final isBank = _bankKeywords.any((kw) {
      final matches = sender.contains(kw);
      if (matches) debugPrint('SMS_LISTENER: MATCHED keyword "$kw" in sender "$sender"');
      return matches;
    });

    debugPrint('SMS_LISTENER: is bank SMS = $isBank');

    if (!isBank || body.isEmpty) {
      debugPrint('SMS_LISTENER: SKIPPING (isBank=$isBank, bodyEmpty=${body.isEmpty})');
      return;
    }

    // Check if tracking is still enabled
    final enabled = await isEnabled();
    if (!enabled) {
      debugPrint('SMS_LISTENER: tracking disabled, skipping');
      return;
    }

    try {
      debugPrint('SMS_LISTENER: sending to API POST /sms/parse...');
      debugPrint('SMS_LISTENER: request body = {sms_body: "${body.length > 80 ? body.substring(0, 80) : body}...", sender: "$sender"}');
      final result = await _smsApi.parseSms(
        body,
        sender: message.address ?? '',
      );
      debugPrint('SMS_LISTENER: API response = $result');

      final parsed = result['transaction'];
      if (parsed != null) {
        final amount = parsed['amount'] ?? '';
        final merchant = parsed['description'] ?? parsed['merchant'] ?? 'Unknown';
        debugPrint('SMS_LISTENER: Parsed OK: Rs$amount at $merchant');
      } else {
        debugPrint('SMS_LISTENER: API returned no transaction (not parsed or duplicate)');
      }
    } catch (e) {
      debugPrint('SMS_LISTENER: Parse FAILED: $e');
    }
  }
}

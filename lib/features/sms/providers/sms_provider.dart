import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_provider.dart';
import '../services/sms_listener_service.dart';

final smsListenerProvider = Provider<SmsListenerService>((ref) {
  return SmsListenerService(ref.watch(smsApiProvider));
});

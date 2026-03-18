class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String verify = '/auth/verify';
  static const String me = '/auth/me';

  // Transactions
  static const String transactions = '/transactions';
  static const String transactionSummary = '/transactions/summary';

  // Categories
  static const String categories = '/categories';

  // Accounts
  static const String accounts = '/accounts';

  // SMS
  static const String smsParse = '/sms/parse';
  static const String smsBatch = '/sms/batch';
  static const String smsPending = '/sms/pending';
  static String smsConfirm(String id) => '/sms/confirm/$id';
  static String smsReject(String id) => '/sms/reject/$id';

  // Reports
  static String monthlyReport(int year, int month) =>
      '/reports/monthly/$year/$month';
  static const String categoryBreakdown = '/reports/category-breakdown';
  static const String trends = '/reports/trends';
  static const String exportCsv = '/reports/export/csv';

  // Debug
  static const String health = '/debug/health';
}

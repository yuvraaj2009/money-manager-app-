class SmsTransaction {
  final String id;
  final double amount;
  final String type; // 'expense' or 'income'
  final String? merchant;
  final String? bank;
  final String? accountSuffix;
  final String? suggestedCategory;
  final String? suggestedCategoryId;
  final double confidence;
  final String smsBody;
  final DateTime date;
  final DateTime createdAt;

  SmsTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.merchant,
    this.bank,
    this.accountSuffix,
    this.suggestedCategory,
    this.suggestedCategoryId,
    required this.confidence,
    required this.smsBody,
    required this.date,
    required this.createdAt,
  });

  factory SmsTransaction.fromJson(Map<String, dynamic> json) {
    return SmsTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      merchant: json['merchant'] as String?,
      bank: json['bank'] as String?,
      accountSuffix: json['account_suffix'] as String?,
      suggestedCategory: json['suggested_category'] as String?,
      suggestedCategoryId: json['suggested_category_id'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      smsBody: json['sms_body'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

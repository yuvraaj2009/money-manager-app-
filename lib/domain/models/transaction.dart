class Transaction {
  final String id;
  final double amount;
  final String type; // 'expense' or 'income'
  final String? description;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String accountId;
  final String? accountName;
  final String source; // 'manual', 'sms'
  final String? smsHash;
  final bool isConfirmed;
  final String? paymentMethod;
  final DateTime date;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.accountId,
    this.accountName,
    required this.source,
    this.smsHash,
    required this.isConfirmed,
    this.paymentMethod,
    required this.date,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final account = json['account'] as Map<String, dynamic>?;

    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String? ?? category?['id'] as String? ?? '',
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
      accountId: json['account_id'] as String? ?? account?['id'] as String? ?? '',
      accountName: account?['name'] as String?,
      source: json['source'] as String? ?? 'manual',
      smsHash: json['sms_hash'] as String?,
      isConfirmed: json['is_confirmed'] as bool? ?? true,
      paymentMethod: json['payment_method'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'type': type,
        'description': description,
        'category_id': categoryId,
        'account_id': accountId,
        'source': source,
        'payment_method': paymentMethod,
        'date': date.toIso8601String(),
      };
}

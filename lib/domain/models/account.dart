class Account {
  final String id;
  final String name;
  final String type; // 'cash', 'bank', 'wallet', 'credit_card'
  final double balance;
  final String? bankIdentifier;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.bankIdentifier,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num).toDouble(),
      bankIdentifier: json['bank_identifier'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'balance': balance,
        'bank_identifier': bankIdentifier,
      };
}

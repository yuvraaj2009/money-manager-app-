class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;
  final List<CategoryBreakdown> categoryBreakdown;

  TransactionSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
    required this.categoryBreakdown,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transaction_count'] as int? ?? 0,
      categoryBreakdown: (json['category_breakdown'] as List<dynamic>?)
              ?.map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final String categoryColor;
  final double amount;
  final double percentage;

  CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? 'Other',
      categoryColor: json['category_color'] as String? ?? '#73739E',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

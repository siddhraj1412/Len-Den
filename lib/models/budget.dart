class Budget {
  final double amount;
  final DateTime month;

  Budget({
    required this.amount,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'month': month.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      amount: json['amount'].toDouble(),
      month: DateTime.parse(json['month']),
    );
  }
}

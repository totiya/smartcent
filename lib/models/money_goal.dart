class MoneyGoal {
  final String name;
  final double targetAmount;
  double currentAmount;

  MoneyGoal({
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
    };
  }

  factory MoneyGoal.fromMap(Map<String, dynamic> map) {
    return MoneyGoal(
      name: map['name'] as String,
      targetAmount: map['targetAmount'] as double,
      currentAmount: map['currentAmount'] as double,
    );
  }

  double get progress => currentAmount / targetAmount;
  
  bool get isCompleted => currentAmount >= targetAmount;
  
  void addAmount(double amount) {
    if (amount > 0) {
      currentAmount += amount;
    }
  }
} 
import 'achievement.dart';
import 'money_goal.dart';

class Child {
  final String id;
  final String name;
  final double monthlyBudget;
  final double currentSpent;
  final List<SavingsGoal> savingsGoals;

  Child({
    required this.id,
    required this.name,
    required this.monthlyBudget,
    this.currentSpent = 0.0,
    List<SavingsGoal>? savingsGoals,
  }) : savingsGoals = savingsGoals ?? [];

  double get remainingBudget => monthlyBudget - currentSpent;

  Child copyWith({
    String? id,
    String? name,
    double? monthlyBudget,
    double? currentSpent,
    List<SavingsGoal>? savingsGoals,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currentSpent: currentSpent ?? this.currentSpent,
      savingsGoals: savingsGoals ?? this.savingsGoals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthlyBudget': monthlyBudget,
      'currentSpent': currentSpent,
      'savingsGoals': savingsGoals.map((goal) => goal.toJson()).toList(),
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      monthlyBudget: json['monthlyBudget'] as double,
      currentSpent: json['currentSpent'] as double,
      savingsGoals: (json['savingsGoals'] as List)
          .map((goal) => SavingsGoal.fromJson(goal as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
  });

  double get progress => currentAmount / targetAmount;

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: json['targetAmount'] as double,
      currentAmount: json['currentAmount'] as double,
      targetDate: DateTime.parse(json['targetDate'] as String),
    );
  }
} 
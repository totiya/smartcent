import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/child.dart';

class ChildrenProvider with ChangeNotifier {
  final List<Child> _children = [];
  final _uuid = const Uuid();

  List<Child> get children => List.unmodifiable(_children);

  void addChild(String name, double monthlyBudget) {
    final child = Child(
      id: _uuid.v4(),
      name: name,
      monthlyBudget: monthlyBudget,
    );
    _children.add(child);
    notifyListeners();
  }

  void updateChild(Child child) {
    final index = _children.indexWhere((c) => c.id == child.id);
    if (index != -1) {
      _children[index] = child;
      notifyListeners();
    }
  }

  void deleteChild(String id) {
    _children.removeWhere((child) => child.id == id);
    notifyListeners();
  }

  void addSavingsGoal(String childId, String name, double targetAmount, DateTime targetDate) {
    final index = _children.indexWhere((c) => c.id == childId);
    if (index != -1) {
      final child = _children[index];
      final goal = SavingsGoal(
        id: _uuid.v4(),
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
      );
      final updatedChild = child.copyWith(
        savingsGoals: [...child.savingsGoals, goal],
      );
      _children[index] = updatedChild;
      notifyListeners();
    }
  }

  void updateSavingsGoal(String childId, SavingsGoal goal) {
    final index = _children.indexWhere((c) => c.id == childId);
    if (index != -1) {
      final child = _children[index];
      final goalIndex = child.savingsGoals.indexWhere((g) => g.id == goal.id);
      if (goalIndex != -1) {
        final updatedGoals = List<SavingsGoal>.from(child.savingsGoals);
        updatedGoals[goalIndex] = goal;
        final updatedChild = child.copyWith(savingsGoals: updatedGoals);
        _children[index] = updatedChild;
        notifyListeners();
      }
    }
  }

  void deleteSavingsGoal(String childId, String goalId) {
    final index = _children.indexWhere((c) => c.id == childId);
    if (index != -1) {
      final child = _children[index];
      final updatedGoals = child.savingsGoals.where((g) => g.id != goalId).toList();
      final updatedChild = child.copyWith(savingsGoals: updatedGoals);
      _children[index] = updatedChild;
      notifyListeners();
    }
  }

  void updateSpending(String childId, double amount) {
    final index = _children.indexWhere((c) => c.id == childId);
    if (index != -1) {
      final child = _children[index];
      final updatedChild = child.copyWith(
        currentSpent: child.currentSpent + amount,
      );
      _children[index] = updatedChild;
      notifyListeners();
    }
  }
} 
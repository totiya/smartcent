import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'receipt.dart';  // Updated import for Receipt class

class BudgetProvider extends ChangeNotifier {
  static const String _budgetsKey = 'saved_budgets';
  Map<String, double> _budgets = {
    'Car': 500.0,
    'Daily Shop': 800.0,
    'Gas': 200.0,
    'Other': 300.0,
    'Restaurant': 400.0,
    'Entertainment': 200.0,
  };

  BudgetProvider() {
    _loadBudgets();
  }

  Map<String, double> get budgets => _budgets;

  Future<void> _loadBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getString(_budgetsKey);
      if (budgetsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(budgetsJson);
        _budgets = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading budgets: $e');
      // Keep default budgets if there's an error
    }
  }

  Future<void> setBudget(String category, double amount) async {
    try {
      _budgets[category] = amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_budgetsKey, jsonEncode(_budgets));
      notifyListeners();
    } catch (e) {
      print('Error saving budget: $e');
    }
  }

  double getBudget(String category) => _budgets[category] ?? 0.0;

  double getTotalBudget() {
    return _budgets.values.fold(0.0, (sum, amount) => sum + amount);
  }

  double getCategorySpent(String category, List<Receipt> receipts) {
    return receipts
        .where((r) => r.storeCategory == category)
        .fold(0.0, (sum, r) => sum + r.totalAmount);
  }

  double getRemainingBudget(String category, List<Receipt> receipts) {
    return getBudget(category) - getCategorySpent(category, receipts);
  }

  double getTotalSpent(List<Receipt> receipts) {
    return receipts.fold(0.0, (sum, r) => sum + r.totalAmount);
  }

  // Get the current month's total budget
  double get budget {
    return getTotalBudget();
  }
} 
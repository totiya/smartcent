import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../constants.dart';

class BudgetProvider with ChangeNotifier {
  Map<String, double> _budgets = {};
  final String _budgetsKey = 'monthlyBudgets';

  BudgetProvider() {
    _loadBudgets();
  }

  String _getBudgetKey(String category, DateTime monthYear) {
    final formatter = DateFormat('yyyy-MM');
    return '${formatter.format(monthYear)}_${category}';
  }

  MapEntry<String, String>? _parseBudgetKey(String key) {
    final parts = key.split('_');
    if (parts.length < 2) return null;
    final category = parts.sublist(1).join('_');
    return MapEntry(parts[0], category);
  }

  Future<void> _loadBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? budgetsJson = prefs.getString(_budgetsKey);

      if (budgetsJson != null && budgetsJson.isNotEmpty) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(budgetsJson);
          _budgets = decoded.map((key, value) => MapEntry(key, value.toDouble()));
        } catch (e) {
          print('Error decoding budgets: $e');
          _budgets = {};
        }
      } else {
        _budgets = {};
      }
    } catch (e) {
      print('Error loading budgets: $e');
      _budgets = {};
    }
    notifyListeners();
  }

  Future<void> _saveBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(_budgets);
      await prefs.setString(_budgetsKey, jsonString);
    } catch (e) {
      print('Error saving budgets: $e');
    }
  }

  double getBudget(String category, DateTime monthYear) {
    final key = _getBudgetKey(category, monthYear);
    return _budgets[key] ?? 0.0;
  }

  Future<void> setBudget(String category, DateTime monthYear, double amount) async {
    if (amount < 0) amount = 0.0;
    final key = _getBudgetKey(category, monthYear);
    _budgets[key] = amount;
    await _saveBudgets();
    notifyListeners();
  }

  Map<String, double> getMonthBudgets(DateTime monthYear) {
    final monthBudgets = <String, double>{};
    final monthYearString = DateFormat('yyyy-MM').format(monthYear);
    _budgets.forEach((key, value) {
      final parsedKey = _parseBudgetKey(key);
      if (parsedKey != null && parsedKey.key == monthYearString) {
        monthBudgets[parsedKey.value] = value;
      }
    });
    for (var category in kCategories) {
      monthBudgets.putIfAbsent(category, () => 0.0);
    }
    return monthBudgets;
  }

  double getTotalSpent(List<Receipt> receipts) {
    if (receipts.isEmpty) return 0.0;
    return receipts.fold(0.0, (sum, receipt) => sum + receipt.totalAmount);
  }

  double getTotalBudget(DateTime monthYear) {
    double total = 0.0;
    final monthYearString = DateFormat('yyyy-MM').format(monthYear);
    _budgets.forEach((key, value) {
      final parsedKey = _parseBudgetKey(key);
      if (parsedKey != null && parsedKey.key == monthYearString) {
        total += value;
      }
    });
    return total;
  }

  double getRemainingBudget(List<Receipt> receipts, DateTime monthYear) {
    final total = getTotalBudget(monthYear);
    final spent = getTotalSpent(receipts);
    return total - spent;
  }

  double getCategorySpent(String category, List<Receipt> receipts) {
    if (receipts.isEmpty) return 0.0;
    return receipts
        .where((receipt) => receipt.storeCategory == category)
        .fold(0.0, (sum, receipt) => sum + receipt.totalAmount);
  }
} 
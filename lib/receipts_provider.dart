import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'receipt.dart'; // Updated import for Receipt class

class ReceiptsProvider extends ChangeNotifier {
  static const String _receiptsKey = 'saved_receipts';
  List<Receipt> _receipts = [];

  List<Receipt> get receipts => _receipts;

  ReceiptsProvider() {
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final receiptsJson = prefs.getStringList(_receiptsKey) ?? [];
      _receipts = receiptsJson
          .map((json) => Receipt.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading receipts: $e');
      // Initialize with empty list if there's an error
      _receipts = [];
    }
  }

  Future<void> _saveReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final receiptsJson = _receipts
          .map((receipt) => jsonEncode(receipt.toJson()))
          .toList();
      await prefs.setStringList(_receiptsKey, receiptsJson);
    } catch (e) {
      print('Error saving receipts: $e');
    }
  }

  void setReceipts(List<Receipt> newReceipts) {
    _receipts = newReceipts;
    _saveReceipts();
    notifyListeners();
  }

  void addReceipt(Receipt receipt) {
    _receipts.insert(0, receipt);
    _saveReceipts();
    notifyListeners();
  }

  void updateReceipt(int index, Receipt updated) {
    if (index >= 0 && index < _receipts.length) {
      _receipts[index] = updated;
      _saveReceipts();
      notifyListeners();
    }
  }

  void deleteReceipt(int index) {
    if (index >= 0 && index < _receipts.length) {
      _receipts.removeAt(index);
      _saveReceipts();
      notifyListeners();
    }
  }

  void removeReceipt(Receipt receipt) {
    _receipts.remove(receipt);
    _saveReceipts();
    notifyListeners();
  }

  bool barcodeExists(String? barcode) {
    if (barcode == null) return false;
    return _receipts.any((receipt) => receipt.barcode == barcode);
  }

  void clearReceipts() {
    _receipts.clear();
    _saveReceipts();
    notifyListeners();
  }
}
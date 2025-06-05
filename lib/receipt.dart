import 'package:flutter/material.dart';

class Receipt {
  final double totalAmount;
  final String storeCategory;
  final DateTime? timestamp;
  final String? barcode;
  final String? storeName;
  final DateTime? date;

  Receipt({
    required this.totalAmount,
    required this.storeCategory,
    this.timestamp,
    this.barcode,
    this.storeName,
    this.date,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      storeCategory: json['storeCategory'] ?? 'Unrecognized',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      barcode: json['barcode'],
      storeName: json['storeName'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'storeCategory': storeCategory,
      'timestamp': timestamp?.toIso8601String(),
      'barcode': barcode,
      'storeName': storeName,
      'date': date?.toIso8601String(),
    };
  }
} 
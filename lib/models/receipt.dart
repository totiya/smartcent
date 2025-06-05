import 'package:uuid/uuid.dart';

class Receipt {
  final String id;
  final String storeName;
  final String storeCategory;
  final double totalAmount;
  final DateTime date;
  final String? imagePath;
  final List<ReceiptItem> items;

  Receipt({
    String? id,
    required this.storeName,
    required this.storeCategory,
    required this.totalAmount,
    required this.date,
    this.imagePath,
    List<ReceiptItem>? items,
  })  : id = id ?? const Uuid().v4(),
        items = items ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'storeCategory': storeCategory,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      storeName: json['storeName'] as String,
      storeCategory: json['storeCategory'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      imagePath: json['imagePath'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class ReceiptItem {
  final String name;
  final double price;
  final int quantity;

  ReceiptItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
} 
import 'package:flutter/material.dart';
import '../receipt.dart';

class TransactionListItem extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.receipt,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(receipt.storeCategory),
          child: Icon(
            _getCategoryIcon(receipt.storeCategory),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          receipt.storeCategory,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _formatDate(receipt.timestamp ?? DateTime.now()),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${receipt.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 16,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
      case 'groceries':
        return Colors.green;
      case 'transportation':
      case 'transport':
        return Colors.blue;
      case 'auto':
      case 'automotive':
        return Colors.red;
      case 'dining':
      case 'restaurant':
      case 'food':
        return Colors.orange;
      case 'entertainment':
      case 'leisure':
        return Colors.purple;
      case 'personal':
      case 'shopping':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
      case 'groceries':
        return Icons.shopping_cart;
      case 'transportation':
      case 'transport':
        return Icons.directions_bus;
      case 'auto':
      case 'automotive':
        return Icons.car_repair;
      case 'dining':
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'entertainment':
      case 'leisure':
        return Icons.movie;
      case 'personal':
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
} 
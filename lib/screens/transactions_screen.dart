import '../widgets/transaction_list_item.dart';
import 'package:provider/provider.dart';
import '../receipts_provider.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Income', 'Expense'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: Consumer<ReceiptsProvider>(
              builder: (context, receiptsProvider, child) {
                final receipts = receiptsProvider.receipts;
                
                if (receipts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start by scanning your first receipt!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: receipts.length,
                  itemBuilder: (context, index) {
                    final receipt = receipts[receipts.length - 1 - index]; // Show newest first
                    return TransactionListItem(
                      receipt: receipt,
                      onTap: () {
                        // TODO: Navigate to receipt details
                      },
                      onDelete: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: const Text('Are you sure you want to delete this transaction?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  receiptsProvider.removeReceipt(receipt);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add transaction
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/transaction_list_item.dart';
import 'package:provider/provider.dart';
import '../receipts_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Consumer<ReceiptsProvider>(
        builder: (context, receiptsProvider, child) {
          final receipts = receiptsProvider.receipts;
          final totalSpent = receipts.fold<double>(0, (sum, receipt) => sum + receipt.totalAmount);
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BudgetSummaryCard(
                totalBudget: 5000,
                totalSpent: totalSpent,
                period: 'This Month',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all transactions
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (receipts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.receipt, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 18,
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
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: receipts.length > 5 ? 5 : receipts.length,
                  itemBuilder: (context, index) {
                    final receipt = receipts[receipts.length - 1 - index]; // Show newest first
                    return TransactionListItem(
                      receipt: receipt,
                      onTap: () {
                        // TODO: Navigate to receipt details
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show add transaction dialog
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 
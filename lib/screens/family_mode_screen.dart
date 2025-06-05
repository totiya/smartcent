import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'kids_mode_screen.dart';

class FamilyModeScreen extends StatelessWidget {
  const FamilyModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Mode'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Family Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Children'),
            const SizedBox(height: 16),
            _buildChildList(),
            const SizedBox(height: 32),
            _buildSectionTitle('Parent Controls'),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              'Add Child',
              'Add a new child to the family',
              Icons.person_add,
              () {
                // TODO: Implement add child functionality
                _showAddChildDialog(context);
              },
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              'Set Budgets',
              'Manage monthly budgets for children',
              Icons.account_balance_wallet,
              () {
                // TODO: Implement budget management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget management coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildControlCard(
              context,
              'View Reports',
              'Check spending and savings reports',
              Icons.bar_chart,
              () {
                // TODO: Implement reports view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reports coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChildList() {
    // TODO: Replace with actual child data
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2, // Example count
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('Child ${index + 1}'),
            subtitle: const Text('Monthly Budget: \$100.00'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit child functionality
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KidsModeScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildControlCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Child'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Child Name',
                hintText: 'Enter child\'s name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Monthly Budget',
                hintText: 'Enter monthly budget amount',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add child logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Child added successfully!'),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
} 
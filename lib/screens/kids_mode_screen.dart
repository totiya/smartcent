import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class KidsModeScreen extends StatefulWidget {
  const KidsModeScreen({Key? key}) : super(key: key);

  @override
  _KidsModeScreenState createState() => _KidsModeScreenState();
}

class _KidsModeScreenState extends State<KidsModeScreen> {
  DateTime _selectedMonth = DateTime.now();
  Child? _selectedChild;
  bool _isLoading = false;

  // Sample children data (in real app, this would come from database/API)
  List<Child> _children = [
    Child(
      id: '1', 
      name: 'Emma', 
      avatar: '👧',
      monthlyAllowance: 100.0,
      currentSpent: 45.50,
      goals: [
        Goal(name: 'New Tablet', target: 200.0, current: 80.0, emoji: '📱'),
        Goal(name: 'Bike', target: 150.0, current: 120.0, emoji: '🚲'),
      ],
      transactions: [
        Transaction(date: DateTime.now().subtract(Duration(days: 2)), amount: 15.50, description: 'Lunch', category: 'Food'),
        Transaction(date: DateTime.now().subtract(Duration(days: 5)), amount: 30.00, description: 'Movie tickets', category: 'Entertainment'),
      ]
    ),
    Child(
      id: '2', 
      name: 'Alex', 
      avatar: '👦',
      monthlyAllowance: 80.0,
      currentSpent: 25.75,
      goals: [
        Goal(name: 'Video Game', target: 60.0, current: 35.0, emoji: '🎮'),
        Goal(name: 'Skateboard', target: 120.0, current: 40.0, emoji: '🛹'),
      ],
      transactions: [
        Transaction(date: DateTime.now().subtract(Duration(days: 1)), amount: 12.25, description: 'School supplies', category: 'Education'),
        Transaction(date: DateTime.now().subtract(Duration(days: 3)), amount: 13.50, description: 'Snacks', category: 'Food'),
      ]
    ),
  ];

  void _showChildSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Child to Monitor'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _children.length,
            itemBuilder: (context, index) {
              final child = _children[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple[100],
                  child: Text(child.avatar, style: TextStyle(fontSize: 20)),
                ),
                title: Text(child.name),
                subtitle: Text('Allowance: \$${child.monthlyAllowance.toStringAsFixed(2)}'),
                onTap: () {
                  setState(() {
                    _selectedChild = child;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddChildDialog();
            },
            child: Text('Add New Child'),
          ),
        ],
      ),
    );
  }

  void _showAddChildDialog() {
    final nameController = TextEditingController();
    final allowanceController = TextEditingController();
    String selectedAvatar = '👶';
    final avatars = ['👧', '👦', '👶', '🧒', '👨‍🦱', '👩‍🦱'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add New Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Child Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: allowanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monthly Allowance',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text('Choose Avatar:'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: avatars.map((avatar) => GestureDetector(
                  onTap: () => setDialogState(() => selectedAvatar = avatar),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedAvatar == avatar ? Colors.purple : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(avatar, style: TextStyle(fontSize: 24)),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && allowanceController.text.isNotEmpty) {
                  final newChild = Child(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    avatar: selectedAvatar,
                    monthlyAllowance: double.tryParse(allowanceController.text) ?? 0.0,
                    currentSpent: 0.0,
                    goals: [],
                    transactions: [],
                  );
                  setState(() {
                    _children.add(newChild);
                    _selectedChild = newChild;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${newChild.name} added successfully!')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Month'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              return ListTile(
                title: Text(DateFormat('MMMM yyyy').format(DateTime(_selectedMonth.year, month))),
                onTap: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, month);
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _editAllowance() {
    if (_selectedChild == null) return;
    
    final controller = TextEditingController(text: _selectedChild!.monthlyAllowance.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${_selectedChild!.name}\'s Allowance'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Monthly Allowance',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAllowance = double.tryParse(controller.text) ?? 0.0;
              setState(() {
                _selectedChild!.monthlyAllowance = newAllowance;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Allowance updated to \$${newAllowance.toStringAsFixed(2)}')),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to sync data from child's device
    await Future.delayed(Duration(seconds: 2));

    // In real app, this would fetch actual data from the child's device/app
    if (_selectedChild != null) {
      setState(() {
        // Simulate updated data
        _selectedChild!.currentSpent += 5.0; // Example: new spending
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data synced from ${_selectedChild!.name}\'s device')),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parental Control - Kids Monitoring'),
        backgroundColor: Colors.indigo[600],
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showMonthPicker,
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: _syncData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[50]!, Colors.white],
          ),
        ),
        child: _selectedChild == null ? _buildChildSelection() : _buildChildDashboard(),
      ),
    );
  }

  Widget _buildChildSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: Colors.indigo[300]),
          SizedBox(height: 24),
          Text(
            'Select a child to monitor',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
          ),
          SizedBox(height: 16),
          Text(
            'View spending, set allowances, and track goals',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showChildSelector,
            icon: Icon(Icons.person_search),
            label: Text('Choose Child'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildDashboard() {
    final child = _selectedChild!;
    final remaining = child.monthlyAllowance - child.currentSpent;
    final spentPercentage = child.currentSpent / child.monthlyAllowance;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Header
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.indigo[100],
                    child: Text(child.avatar, style: TextStyle(fontSize: 32)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              child.name,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.indigo[600]),
                              onPressed: _editAllowance,
                            ),
                          ],
                        ),
                        Text(
                          'Viewing: ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Row(
                          children: [
                            Icon(Icons.sync, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Last sync: ${DateFormat('MMM dd, HH:mm').format(DateTime.now())}',
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.change_circle, color: Colors.indigo[600]),
                    onPressed: _showChildSelector,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Spending Overview with Pie Chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Spending Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      // Pie Chart
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.red[400],
                                  value: child.currentSpent,
                                  title: 'Spent\n\$${child.currentSpent.toStringAsFixed(2)}',
                                  radius: 60,
                                  titleStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.green[400],
                                  value: remaining.clamp(0, double.infinity),
                                  title: 'Remaining\n\$${remaining.clamp(0, double.infinity).toStringAsFixed(2)}',
                                  radius: 60,
                                  titleStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      // Stats
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow('Monthly Allowance', '\$${child.monthlyAllowance.toStringAsFixed(2)}', Colors.blue),
                            SizedBox(height: 12),
                            _buildStatRow('Amount Spent', '\$${child.currentSpent.toStringAsFixed(2)}', Colors.red),
                            SizedBox(height: 12),
                            _buildStatRow('Remaining', '\$${remaining.toStringAsFixed(2)}', remaining >= 0 ? Colors.green : Colors.red),
                            SizedBox(height: 12),
                            _buildStatRow('Spent Percentage', '${(spentPercentage * 100).toInt()}%', 
                              spentPercentage > 0.8 ? Colors.red : spentPercentage > 0.6 ? Colors.orange : Colors.green),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Recent Transactions
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  if (child.transactions.isEmpty)
                    Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ...child.transactions.map((transaction) => Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${transaction.category} • ${DateFormat('MMM dd').format(transaction.date)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Savings Goals
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Savings Goals',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  if (child.goals.isEmpty)
                    Center(
                      child: Text(
                        'No goals set yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ...child.goals.map((goal) {
                      final progress = goal.current / goal.target;
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(goal.emoji, style: TextStyle(fontSize: 20)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    goal.name,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '\$${goal.current.toStringAsFixed(2)} / \$${goal.target.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class Child {
  final String id;
  final String name;
  final String avatar;
  double monthlyAllowance;
  double currentSpent;
  List<Goal> goals;
  List<Transaction> transactions;

  Child({
    required this.id,
    required this.name,
    required this.avatar,
    required this.monthlyAllowance,
    required this.currentSpent,
    required this.goals,
    required this.transactions,
  });
}

class Goal {
  String name;
  double target;
  double current;
  String emoji;

  Goal({
    required this.name,
    required this.target,
    required this.current,
    required this.emoji,
  });
}

class Transaction {
  DateTime date;
  double amount;
  String description;
  String category;

  Transaction({
    required this.date,
    required this.amount,
    required this.description,
    required this.category,
  });
} 
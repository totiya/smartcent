// File: main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'receipts_provider.dart';
import 'budget_provider.dart';
import 'dart:io' show Platform;
import 'dart:math' show cos, sin, max;
import 'screens/settings_screen.dart';
import 'constants.dart';
import 'screens/password_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_of_service_screen.dart';
// import 'screens/first_time_setup_screen.dart'; // Removed - class is defined in main.dart

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }
}

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ReceiptsProvider()),
      ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: BudgetSnapApp(),
  ),
);

class BudgetSnapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'SmartCent',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.indigo[700],
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[900]),
          bodyMedium: TextStyle(color: Colors.grey[800]),
          titleLarge: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.indigo[900],
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[100]),
          bodyMedium: TextStyle(color: Colors.grey[200]),
          titleLarge: TextStyle(color: Colors.grey[100], fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[800],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: DeviceFrame(
        child: PasswordCheck(
          child: FirstTimeSetupCheck(
          child: SelectionScreen(
            onModeSelected: (mode) {
              // This is now handled directly in the SelectionScreen
            },
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceFrame extends StatelessWidget {
  final Widget child;

  const DeviceFrame({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 390, // iPhone 14 width
          height: 844, // iPhone 14 height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              children: [
                // Device Frame
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 12,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                // Notch
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned.fill(
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final totalMonthBudget = budgetProvider.getTotalBudget(DateTime.now());

    final List<Widget> _pages = [
      OCRReader(),
      MonthlySummary(totalMonthBudget: totalMonthBudget),
      MonthlyComparison(totalMonthBudget: totalMonthBudget),
      _buildBudgetSettings(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('SmartCent'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Receipts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSettings() {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final receiptsProvider = Provider.of<ReceiptsProvider>(context);
    final currentMonth = DateTime.now();
    final monthReceipts = receiptsProvider.receipts.where((r) =>
      r.timestamp != null &&
      r.timestamp!.month == currentMonth.month &&
      r.timestamp!.year == currentMonth.year
    ).toList();

    final totalMonthBudget = budgetProvider.getTotalBudget(currentMonth);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selection Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showMonthPicker(context),
              icon: Icon(Icons.calendar_today),
              label: Text(
                "Setting Budgets for: ${DateFormat('MMMM yyyy').format(currentMonth)}",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: Size(200, 50),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Budget Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Budget:", style: TextStyle(fontSize: 18)),
                      Text("\$${totalMonthBudget.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Spent:", style: TextStyle(fontSize: 18)),
                      Text("\$${budgetProvider.getTotalSpent(monthReceipts).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Remaining:", style: TextStyle(fontSize: 18)),
                      Text("\$${budgetProvider.getRemainingBudget(monthReceipts, currentMonth).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                          color: budgetProvider.getRemainingBudget(monthReceipts, currentMonth) >= 0 ? Colors.teal[700] : Colors.red[700])),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Category Budget Inputs
          Text(
            "Set Category Budgets",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...kCategories.map((category) {
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(
                        text: budgetProvider.getBudget(category, currentMonth).toStringAsFixed(2),
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                        hintText: 'Enter budget amount',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          SizedBox(height: 20),

          // Save Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement save functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget settings saved!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: Size(200, 50),
              ),
              child: Text('Save Budgets'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
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
                title: Text(DateFormat('MMMM').format(DateTime(DateTime.now().year, month))),
                onTap: () {
                  // TODO: Implement month selection
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class PasswordCheck extends StatefulWidget {
  final Widget child;

  const PasswordCheck({Key? key, required this.child}) : super(key: key);

  @override
  _PasswordCheckState createState() => _PasswordCheckState();
}

class _PasswordCheckState extends State<PasswordCheck> {
  bool _isPasswordVerified = false;
  bool _needsPasswordCheck = false;

  @override
  void initState() {
    super.initState();
    _checkPasswordRequirement();
  }

  Future<void> _checkPasswordRequirement() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password');
    final passwordProtection = prefs.getBool('password_protection') ?? false;
    
    setState(() {
      // Show password screen if either:
      // 1. No password exists (first time setup)
      // 2. Password protection is enabled and password exists
      _needsPasswordCheck = (savedPassword == null || savedPassword.isEmpty) || passwordProtection;
    });
  }

  void _onPasswordVerified() {
    setState(() {
      _isPasswordVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_needsPasswordCheck && !_isPasswordVerified) {
      return PasswordScreen(onSuccess: _onPasswordVerified);
    }
    return widget.child;
  }
}

class SelectionScreen extends StatefulWidget {
  final Function(String) onModeSelected;

  const SelectionScreen({Key? key, required this.onModeSelected}) : super(key: key);

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> with WidgetsBindingObserver {
  bool _hasChildren = true;
  bool _isLoading = true;
  String _userName = '';
  bool _isFirstLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserPreferences();
    }
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasChildren = prefs.getBool('has_children') ?? true;
      _userName = prefs.getString('user_name') ?? '';
      _isFirstLogin = prefs.getBool('is_first_login') ?? true;
      _isLoading = false;
    });
    
    // If this is the first login, mark it as completed for next time
    if (_isFirstLogin && _userName.isNotEmpty) {
      await prefs.setBool('is_first_login', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
    return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Top section with logo and text - Fixed height
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome Illustration
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/welcome_illustration.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Simple placeholder instead of custom logo
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    size: 40,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Welcome text section
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title
                            Text(
                              _userName.isNotEmpty 
                                ? (_isFirstLogin 
                                    ? 'Welcome to SmartCent, $_userName!' 
                                    : 'Welcome back to SmartCent, $_userName!')
                                : 'Welcome to SmartCent',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            
                            // Subtitle
                            Text(
                              _hasChildren 
                                ? 'Manage your family\'s money smartly' 
                                : 'Take control of your finances',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Mode Selection Cards - Flexible space
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeCard(
                        context,
                        _hasChildren ? 'Family Mode' : 'Budgeting Home',
                        _hasChildren 
                          ? 'Manage family expenses and investments'
                          : 'Track your personal finances and budget',
                        _hasChildren ? Icons.family_restroom : Icons.account_balance_wallet,
                        () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceFrame(
                                child: FamilyMode(),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_hasChildren) ...[
                        SizedBox(height: 16),
                        _buildModeCard(
                          context,
                          'Kids Mode',
                          'Track kids\' savings and financial education',
                          Icons.school,
                          () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeviceFrame(
                                  child: ChildSelectionScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Bottom padding for better mobile experience
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FamilyMode extends StatefulWidget {
  @override
  _FamilyModeState createState() => _FamilyModeState();
}

class _FamilyModeState extends State<FamilyMode> {
  int _selectedIndex = 0;
  DateTime _selectedMonth = DateTime.now();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _showMonthlyReport = true;
  bool _hasChildren = true; // Add this to track children preference

  // Add missing properties
  double _monthSpent = 0.0;
  Map<String, double> _categoryTotals = {};
  List<String> _nonZeroCategories = [];
  double _remainingMonthBudget = 0.0;

  // Add getters
  double get monthSpent => _monthSpent;
  Map<String, double> get categoryTotals => _categoryTotals;
  List<String> get nonZeroCategories => _nonZeroCategories;
  double get remainingMonthBudget => _remainingMonthBudget;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSettings();
    _updateBudgetData();
  }

  void _updateBudgetData() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final receiptsProvider = Provider.of<ReceiptsProvider>(context, listen: false);
    
    // Calculate category totals
    _categoryTotals = {};
    for (var category in kCategories) {
      _categoryTotals[category] = 0.0;
    }

    // Sum up receipts for the current month
    for (var receipt in receiptsProvider.receipts) {
      if (receipt.timestamp != null && 
          receipt.timestamp!.year == _selectedMonth.year && 
          receipt.timestamp!.month == _selectedMonth.month) {
        _categoryTotals[receipt.storeCategory] = 
            (_categoryTotals[receipt.storeCategory] ?? 0.0) + receipt.totalAmount;
      }
    }

    // Calculate total spent
    _monthSpent = _categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    // Get non-zero categories
    _nonZeroCategories = _categoryTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();

    // Calculate remaining budget
    double totalBudget = 0.0;
    for (var category in kCategories) {
      totalBudget += budgetProvider.getBudget(category, _selectedMonth);
    }
    _remainingMonthBudget = totalBudget - _monthSpent;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _hasChildren = prefs.getBool('has_children') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('New passwords do not match')),
                );
                return;
              }
              // Here you would typically verify the current password and save the new one
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('password', newPasswordController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password updated successfully')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _initializeControllers() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    for (var category in kCategories) {
      _controllers[category] = TextEditingController(
        text: budgetProvider.getBudget(category, _selectedMonth).toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _showMonthPicker(BuildContext context) {
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
                title: Text(DateFormat('MMMM').format(DateTime(_selectedMonth.year, month))),
                onTap: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, month);
                    _initializeControllers(); // Update controllers for new month
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

  Future<void> _saveBudgets() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      for (var category in kCategories) {
        final amount = double.tryParse(_controllers[category]!.text) ?? 0.0;
        await budgetProvider.setBudget(category, _selectedMonth, amount);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budgets for ${DateFormat('MMMM yyyy').format(_selectedMonth)} updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving budgets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasChildren ? 'Family Mode' : 'Budgeting Home'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DeviceFrame(
                child: SelectionScreen(
                  onModeSelected: (mode) {
                    // Handle mode selection if needed
                  },
                ),
              )),
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildReport(),
          _buildBudgetSettings(),
          _buildReceipts(),
          _buildSettings(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 3 ? FloatingActionButton.extended(
        heroTag: "family_mode_fab", // Add unique hero tag
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OCRReader(isFromFamilyMode: true)),
          );
        },
        icon: Icon(Icons.add_chart, color: Colors.white),
        label: Text('Add Transaction', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Receipts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final receiptsProvider = Provider.of<ReceiptsProvider>(context);
    final currentMonth = DateTime.now();
    final monthReceipts = receiptsProvider.receipts.where((r) =>
      r.timestamp != null &&
      r.timestamp!.month == currentMonth.month &&
      r.timestamp!.year == currentMonth.year
    ).toList();

    final totalSpent = budgetProvider.getTotalSpent(monthReceipts);
    final totalBudget = budgetProvider.getTotalBudget(currentMonth);
    final remaining = totalBudget - totalSpent;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Overview Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Budget', '\$${totalBudget.toStringAsFixed(2)}', Colors.blue),
                      _buildStatColumn('Spent', '\$${totalSpent.toStringAsFixed(2)}', Colors.orange),
                      _buildStatColumn('Remaining', '\$${remaining.toStringAsFixed(2)}', 
                        remaining >= 0 ? Colors.green : Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Category Breakdown
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ...kCategories.map((category) {
            final spent = budgetProvider.getCategorySpent(category, monthReceipts);
            final budget = budgetProvider.getBudget(category, currentMonth);
            final remaining = budget - spent;
            final percent = budget > 0 ? (spent / budget).clamp(0, 1).toDouble() : 0.0;

            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$${spent.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: remaining < 0 ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent < 0.7 ? Colors.green :
                        percent < 1.0 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          SizedBox(height: 20),

          // Recent Transactions
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          if (monthReceipts.isEmpty)
            Center(
              child: Text(
                'No recent transactions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...monthReceipts.take(5).map((receipt) => Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kCategoryColors[receipt.storeCategory]?.withOpacity(0.2),
                  child: Icon(
                    _getCategoryIcon(receipt.storeCategory),
                    color: kCategoryColors[receipt.storeCategory],
                  ),
                ),
                title: Text(
                  receipt.storeCategory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  receipt.timestamp != null
                      ? DateFormat.yMMMd().format(receipt.timestamp!)
                      : 'No date',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  '\$${receipt.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildReport() {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final totalMonthBudget = budgetProvider.getTotalBudget(_selectedMonth);
    
    return Column(
      children: [
        // Segmented Control for Report Type
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showMonthlyReport = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showMonthlyReport ? Colors.teal : Colors.grey[300],
                    foregroundColor: _showMonthlyReport ? Colors.white : Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Monthly Report'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showMonthlyReport = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_showMonthlyReport ? Colors.teal : Colors.grey[300],
                    foregroundColor: !_showMonthlyReport ? Colors.white : Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Yearly Analysis'),
                ),
              ),
            ],
          ),
        ),
        // Report Content
        Expanded(
          child: _showMonthlyReport 
            ? MonthlySummary(totalMonthBudget: totalMonthBudget)
            : MonthlyComparison(totalMonthBudget: totalMonthBudget),
        ),
      ],
    );
  }

  Widget _buildBudgetSettings() {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final receiptsProvider = Provider.of<ReceiptsProvider>(context);
    final monthReceipts = receiptsProvider.receipts.where((r) =>
      r.timestamp != null &&
      r.timestamp!.month == _selectedMonth.month &&
      r.timestamp!.year == _selectedMonth.year
    ).toList();

    final totalMonthBudget = budgetProvider.getTotalBudget(_selectedMonth);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selection Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showMonthPicker(context),
              icon: Icon(Icons.calendar_today),
              label: Text(
                "Setting Budgets for: ${DateFormat('MMMM yyyy').format(_selectedMonth)}",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: Size(200, 50),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Budget Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Budget:", style: TextStyle(fontSize: 18)),
                      Text("\$${totalMonthBudget.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Spent:", style: TextStyle(fontSize: 18)),
                      Text("\$${budgetProvider.getTotalSpent(monthReceipts).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Remaining:", style: TextStyle(fontSize: 18)),
                      Text("\$${budgetProvider.getRemainingBudget(monthReceipts, _selectedMonth).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                          color: remainingMonthBudget >= 0 ? Colors.teal[700] : Colors.red[700])),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Category Budget Inputs
          Text(
            "Set Category Budgets",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...kCategories.map((category) {
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _controllers[category],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                        hintText: 'Enter budget amount',
                        // Clear the initial value when focused
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      onTap: () {
                        // Clear the text when tapped if it's 0.00
                        if (_controllers[category]?.text == '0.00') {
                          _controllers[category]?.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          SizedBox(height: 20),

          // Save Button
          Center(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveBudgets,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: Size(200, 50),
              ),
              child: _isSaving
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Save Budgets'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceipts() {
    return OCRReader(isFromFamilyMode: true);
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          // Password Settings
          Card(
            child: ListTile(
              leading: Icon(Icons.security),
              title: Text('Change Password'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _showChangePasswordDialog,
            ),
          ),
          SizedBox(height: 16),

          // Dark Mode Settings
          Card(
            child: SwitchListTile(
              secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: Text('Dark Mode'),
              subtitle: Text('Toggle dark/light theme'),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                _saveSettings();
              },
            ),
          ),
          SizedBox(height: 16),

          // Notification Settings
          Card(
            child: SwitchListTile(
              secondary: Icon(_notificationsEnabled ? Icons.notifications_active : Icons.notifications_off),
              title: Text('Notifications'),
              subtitle: Text('Enable/disable app notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
          ),
          SizedBox(height: 16),

          // App Info
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Version'),
                    trailing: Text('1.0.0'),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: Text('Terms of Service'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip),
                    title: Text('Privacy Policy'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.shopping_basket;
      case 'Transport':
        return Icons.directions_car;
      case 'Dining':
        return Icons.restaurant;
      case 'Auto':
        return Icons.build;
      case 'Leisure':
        return Icons.movie;
      case 'Personal':
        return Icons.person;
      case 'Investment':
        return Icons.trending_up;
      case 'Savings':
        return Icons.account_balance;
      case 'Education':
        return Icons.school;
      case 'Healthcare':
        return Icons.health_and_safety;
      default:
        return Icons.receipt;
    }
  }
}

class Child {
  final String name;
  final double savings;
  final List<MoneyGoal> goals;
  final List<Achievement> achievements;
  final int streak;

  Child({
    required this.name,
    this.savings = 0.0,
    List<MoneyGoal>? goals,
    List<Achievement>? achievements,
    this.streak = 0,
  }) : 
    this.goals = goals ?? [
    MoneyGoal(
      name: 'New Toy',
      target: 50.0,
      current: 0.0,
      icon: Icons.toys,
      color: Colors.blue,
    ),
    MoneyGoal(
      name: 'Video Game',
      target: 100.0,
      current: 0.0,
      icon: Icons.sports_esports,
      color: Colors.purple,
    ),
    ],
    this.achievements = achievements ?? [
    Achievement(
      title: 'First Save',
      description: 'Saved your first dollar!',
      icon: Icons.star,
      color: Colors.amber,
      isUnlocked: true,
    ),
    Achievement(
      title: 'Goal Setter',
      description: 'Set your first goal!',
      icon: Icons.flag,
      color: Colors.green,
      isUnlocked: true,
    ),
    Achievement(
      title: 'Saving Streak',
      description: 'Saved for 7 days!',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      isUnlocked: false,
    ),
  ];
}

class ChildSelectionScreen extends StatefulWidget {
  @override
  _ChildSelectionScreenState createState() => _ChildSelectionScreenState();
}

class _ChildSelectionScreenState extends State<ChildSelectionScreen> {
  List<Child> _children = [];
  final _nameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final childrenJson = prefs.getString('children');
    if (childrenJson != null) {
      final List<dynamic> decoded = jsonDecode(childrenJson);
      setState(() {
        _children = decoded.map((json) => Child(
          name: json['name'],
          savings: json['savings']?.toDouble() ?? 0.0,
          streak: json['streak'] ?? 0,
        )).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final childrenJson = jsonEncode(_children.map((child) => {
      'name': child.name,
      'savings': child.savings,
      'streak': child.streak,
    }).toList());
    await prefs.setString('children', childrenJson);
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Child'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter child\'s name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                setState(() {
                  _children.add(Child(name: _nameController.text));
                });
                _saveChildren();
                _nameController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Child added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Kids Mode'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DeviceFrame(
                child: SelectionScreen(
                  onModeSelected: (mode) {},
                ),
              )),
            );
          },
        ),
        ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _children.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.child_care,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No children added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddChildDialog,
                    icon: Icon(Icons.add),
                    label: Text('Add Child'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
            padding: EdgeInsets.all(16),
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceFrame(
                            child: KidsMode(selectedChild: child),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.indigo[100],
                            child: Text(
                              child.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.indigo[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ),
                        SizedBox(width: 16),
                          Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  child.name,
                              style: TextStyle(
                                    fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                                SizedBox(height: 4),
                            Text(
                                  'Savings: \$${child.savings.toStringAsFixed(2)}',
                              style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Saving Streak: ${child.streak} days',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "child_selection_fab", // Add unique hero tag
        onPressed: _showAddChildDialog,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Child', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class KidsMode extends StatefulWidget {
  final Child selectedChild;

  const KidsMode({Key? key, required this.selectedChild}) : super(key: key);

  @override
  _KidsModeState createState() => _KidsModeState();
}

class _KidsModeState extends State<KidsMode> {
  late Child _child;
  final _amountController = TextEditingController();
  int _selectedIndex = 0; // For bottom navigation

  // Monypocket state variables
  DateTime _selectedMonth = DateTime(2025, 3, 1); // March 2025
  double _moneyPocketAmount = 0.0;
  double _spentAmount = 0.0;
  
  // Monypocket data storage (date-based) - now stores goal-based savings
  Map<String, Map<String, double>> _monypocketData = {};

  @override
  void initState() {
    super.initState();
    _child = widget.selectedChild;
    _loadMonypocketData();
    _loadGoals();
  }

  // Load Monypocket data from SharedPreferences
  Future<void> _loadMonypocketData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString('monypocket_${_child.name}');
    if (dataJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(dataJson);
      setState(() {
        _monypocketData = decoded.map((key, value) =>
          MapEntry(key, Map<String, double>.from(value)));
      });
    }
    _updateCurrentMonthData();
  }

  // Save Monypocket data to SharedPreferences
  Future<void> _saveMonypocketData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = jsonEncode(_monypocketData);
    await prefs.setString('monypocket_${_child.name}', dataJson);
  }

  // Update current month data from saved data
  void _updateCurrentMonthData() {
    final monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    final monthData = _monypocketData[monthKey];
    if (monthData != null) {
      setState(() {
        _moneyPocketAmount = monthData['amount'] ?? 0.0;
        _spentAmount = monthData['spent'] ?? 0.0;
      });
    } else {
      // Initialize with 0.00 for new months
      setState(() {
        _moneyPocketAmount = 0.0;
        _spentAmount = 0.0;
      });
    }
  }

  // Save current month data including goal-based savings
  Future<void> _saveCurrentMonthData() async {
    final monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    final monthData = <String, double>{
      'amount': _moneyPocketAmount,
      'spent': _spentAmount,
    };

    // Add savings for each goal
    for (var goal in _child.goals) {
      final goalKey = 'goal_${goal.name}';
      monthData[goalKey] = _getGoalSavings(goal.name);
    }

    _monypocketData[monthKey] = monthData;
    await _saveMonypocketData();
  }

  // Get savings amount for a specific goal
  double _getGoalSavings(String goalName) {
    final monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    final monthData = _monypocketData[monthKey];
    if (monthData != null) {
      return monthData['goal_$goalName'] ?? 0.0;
    }
    return 0.0;
  }

  // Set savings amount for a specific goal
  Future<void> _setGoalSavings(String goalName, double amount) async {
    final monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    if (_monypocketData[monthKey] == null) {
      _monypocketData[monthKey] = {
        'amount': _moneyPocketAmount,
        'spent': _spentAmount,
      };
    }
    _monypocketData[monthKey]!['goal_$goalName'] = amount;
    await _saveMonypocketData();
  }

  // Load goals from SharedPreferences
  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString('goals_${_child.name}');
    if (goalsJson != null) {
      final List<dynamic> decoded = jsonDecode(goalsJson);
      final goals = decoded.map((json) => MoneyGoal(
        name: json['name'],
        target: json['target'].toDouble(),
        current: json['current'].toDouble(),
        icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
        color: Color(json['colorValue']),
      )).toList();
      setState(() {
        _child = Child(
          name: _child.name,
          savings: _child.savings,
          goals: goals,
          achievements: _child.achievements,
          streak: _child.streak,
        );
      });
    }
  }

  // Save goals to SharedPreferences
  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = jsonEncode(_child.goals.map((goal) => {
      'name': goal.name,
      'target': goal.target,
      'current': goal.current,
      'iconCode': goal.icon.codePoint,
      'colorValue': goal.color.value,
    }).toList());
    await prefs.setString('goals_${_child.name}', goalsJson);
  }

  Future<void> _addMoney() async {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      setState(() {
        _child = Child(
          name: _child.name,
          savings: _child.savings + amount,
          goals: _child.goals,
          achievements: _child.achievements,
          streak: _child.streak + 1,
        );
      });
      
      // Save updated child data
      final prefs = await SharedPreferences.getInstance();
      final childrenJson = prefs.getString('children');
      if (childrenJson != null) {
        final List<dynamic> decoded = jsonDecode(childrenJson);
        final updatedChildren = decoded.map((json) {
          if (json['name'] == _child.name) {
            return {
              'name': _child.name,
              'savings': _child.savings,
              'streak': _child.streak,
            };
          }
          return json;
        }).toList();
        await prefs.setString('children', jsonEncode(updatedChildren));
      }

      _amountController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddGoalDialog() {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    IconData selectedIcon = Icons.star;
    Color selectedColor = Colors.blue;

    final availableIcons = [
      Icons.toys, Icons.sports_esports, Icons.directions_bike,
      Icons.book, Icons.music_note, Icons.palette,
      Icons.sports_soccer, Icons.computer, Icons.phone_android,
      Icons.headphones, Icons.camera_alt, Icons.shopping_bag,
    ];

    final availableColors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.red, Colors.teal, Colors.amber, Colors.pink,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Text('Choose Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableIcons.map((icon) => GestureDetector(
                    onTap: () => setDialogState(() => selectedIcon = icon),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon ? selectedColor.withOpacity(0.3) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: selectedIcon == icon ? selectedColor : Colors.grey),
                    ),
                  )).toList(),
                ),
                SizedBox(height: 16),
                Text('Choose Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableColors.map((color) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color ? Border.all(color: Colors.black, width: 2) : null,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text);
                
                if (name.isNotEmpty && target != null && target > 0) {
                  final newGoal = MoneyGoal(
                    name: name,
                    target: target,
                    current: 0.0,
                    icon: selectedIcon,
                    color: selectedColor,
                  );
                  
                  setState(() {
                    _child = Child(
                      name: _child.name,
                      savings: _child.savings,
                      goals: [..._child.goals, newGoal],
                      achievements: _child.achievements,
                      streak: _child.streak,
                    );
                  });
                  
                  _saveGoals();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Goal "$name" added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveGoalDialog(int goalIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Goal'),
        content: Text('Are you sure you want to remove "${_child.goals[goalIndex].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final goals = List<MoneyGoal>.from(_child.goals);
                goals.removeAt(goalIndex);
                _child = Child(
                  name: _child.name,
                  savings: _child.savings,
                  goals: goals,
                  achievements: _child.achievements,
                  streak: _child.streak,
                );
              });
              
              _saveGoals();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Goal removed successfully!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showMonthSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Month for Money Pocket'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final now = DateTime.now();
              final monthDate = DateTime(now.year, month, 1);
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      month.toString(),
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    DateFormat('MMMM yyyy').format(monthDate),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Set monthly savings goal'),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.purple),
                  onTap: () {
                    Navigator.pop(context);
                    _showMoneyPocketGoalDialog('Monthly', DateFormat('MMMM yyyy').format(monthDate));
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showWeekSelection(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Week for Money Pocket'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 8, // Show next 8 weeks
            itemBuilder: (context, index) {
              final weekStart = startOfWeek.add(Duration(days: index * 7));
              final weekEnd = weekStart.add(Duration(days: 6));
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      'W${index + 1}',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Set weekly savings goal'),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.purple),
                  onTap: () {
                    Navigator.pop(context);
                    _showMoneyPocketGoalDialog('Weekly', '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}');
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMoneyPocketGoalDialog(String period, String timeRange) {
    final goalController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set $period Money Pocket Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Period: $timeRange',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.purple[700],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$',
                labelText: '$period Savings Goal',
                hintText: 'Enter amount to save',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.purple[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      period == 'Monthly' 
                        ? 'Tip: Try saving a small amount each day!'
                        : 'Tip: Break your goal into daily amounts!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[600],
                      ),
                    ),
                  ),
                ],
              ),
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
              final goal = double.tryParse(goalController.text);
              if (goal != null && goal > 0) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$period goal of \$${goal.toStringAsFixed(2)} set for $timeRange!'),
                    backgroundColor: Colors.purple,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text('Set Goal'),
          ),
        ],
      ),
    );
  }

  // New Monypocket methods for parental control
  void _showMonthPickerForMonypocket(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Month for Monypocket'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final now = DateTime.now();
              final monthDate = DateTime(now.year, month, 1);
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal[100],
                    child: Text(
                      month.toString(),
                      style: TextStyle(
                        color: Colors.teal[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    DateFormat('MMMM yyyy').format(monthDate),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('View or set money pocket for this month'),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedMonth = monthDate;
                    });
                    _updateCurrentMonthData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing ${DateFormat('MMMM yyyy').format(monthDate)}'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSetMonypocketDialog(BuildContext context) {
    final amountController = TextEditingController(
      text: _moneyPocketAmount > 0 ? _moneyPocketAmount.toStringAsFixed(2) : ''
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Monypocket Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Setting for: ${_child.name}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.teal[700],
              ),
            ),
            Text(
              'Month: ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$',
                labelText: 'Money Pocket Amount',
                hintText: 'Enter amount for this month',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                ),
              ),
              onTap: () {
                // Clear the field if it's showing 0.00
                if (amountController.text == '0.00') {
                  amountController.clear();
                }
              },
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.teal[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This sets the total money pocket for the selected month.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal[600],
                      ),
                    ),
                  ),
                ],
              ),
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
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount >= 0) {
                setState(() {
                  _moneyPocketAmount = amount;
                });
                _saveCurrentMonthData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Monypocket set to \$${amount.toStringAsFixed(2)} for ${_child.name}'),
                    backgroundColor: Colors.teal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text('Set Amount'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_child.name}\'s Money Journey'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DeviceFrame(
                child: ChildSelectionScreen(),
              )),
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMainView(),
          KidsReportScreen(childName: _child.name, monypocketData: _monypocketData),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade50, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goals Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_child.name}\'s Goals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddGoalDialog,
                  icon: Icon(Icons.add_circle_outline, color: Colors.indigo),
                  label: Text('Add Goal', style: TextStyle(color: Colors.indigo)),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_child.goals.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.flag, size: 60, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No goals yet! Add your first goal.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ..._child.goals.asMap().entries.map((entry) {
                final index = entry.key;
                final goal = entry.value;
                return _buildGoalCard(goal, index);
              }).toList(),
            SizedBox(height: 24),

            // Monypocket (Parental Control) Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monypocket',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _showMonthPickerForMonypocket(context),
                          icon: Icon(Icons.calendar_month, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Money Pocket Amount
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Money Pocket:',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            '\$${_moneyPocketAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    // Spent Amount
                    GestureDetector(
                      onTap: () => _showEditSpentDialog(context),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent:',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Row(
                              children: [
                                Text(
                                  '\$${_spentAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.edit, color: Colors.white70, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Savings Breakdown - Dynamic based on actual goals
                    if (_child.goals.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showEditSavingsDialog(context),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Show savings for each goal
                              ..._child.goals.map((goal) {
                                final savings = _getGoalSavings(goal.name);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(goal.icon, color: Colors.white70, size: 16),
                                          SizedBox(width: 8),
                                          Text(
                                            'Saved for ${goal.name}:',
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '\$${savings.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              if (_child.goals.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white70, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tap to edit savings',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.white70, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Add goals to track savings',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showSetMonypocketDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Set Monypocket Amount'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(MoneyGoal goal, int index) {
    final progress = goal.current / goal.target;
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(goal.icon, color: goal.color),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${goal.current.toStringAsFixed(2)} of \$${goal.target.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showRemoveGoalDialog(index),
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSpentDialog(BuildContext context) {
    final spentController = TextEditingController(
      text: _spentAmount > 0 ? _spentAmount.toStringAsFixed(2) : ''
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Spent Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_child.name} - ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: spentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$',
                labelText: 'Amount Spent',
                hintText: 'Enter amount spent this month',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              onTap: () {
                // Clear the field if it's showing 0.00
                if (spentController.text == '0.00') {
                  spentController.clear();
                }
              },
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
              final amount = double.tryParse(spentController.text);
              if (amount != null && amount >= 0) {
                setState(() {
                  _spentAmount = amount;
                });
                _saveCurrentMonthData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Spent amount updated to \$${amount.toStringAsFixed(2)}'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditSavingsDialog(BuildContext context) {
    if (_child.goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add some goals first to track savings for them'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final controllers = <String, TextEditingController>{};

    // Create controllers for each goal
    for (var goal in _child.goals) {
      final savings = _getGoalSavings(goal.name);
      controllers[goal.name] = TextEditingController(
        text: savings > 0 ? savings.toStringAsFixed(2) : ''
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Savings for Goals'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_child.name} - ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
              SizedBox(height: 16),
              ..._child.goals.map((goal) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(goal.icon, color: goal.color, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Saved for ${goal.name}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: goal.color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: controllers[goal.name],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: 'Enter amount saved for ${goal.name}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: goal.color, width: 2),
                          ),
                        ),
                        onTap: () {
                          // Clear the field if it's showing 0.00
                          if (controllers[goal.name]?.text == '0.00') {
                            controllers[goal.name]?.clear();
                          }
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool hasError = false;

              // Validate and save all goal savings
              for (var goal in _child.goals) {
                final amount = double.tryParse(controllers[goal.name]?.text ?? '') ?? 0.0;
                if (amount < 0) {
                  hasError = true;
                  break;
                }
                await _setGoalSavings(goal.name, amount);
              }

              if (!hasError) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Savings updated successfully'),
                    backgroundColor: Colors.purple,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                setState(() {}); // Refresh UI
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter valid amounts'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class MoneyGoal {
  final String name;
  final double target;
  final double current;
  final IconData icon;
  final Color color;

  MoneyGoal({
    required this.name,
    required this.target,
    required this.current,
    required this.icon,
    required this.color,
  });
}

class Receipt {
  final double totalAmount;
  final String storeCategory;
  final DateTime? timestamp;
  final String? barcode;

  Receipt({
    required this.totalAmount,
    required this.storeCategory,
    this.timestamp,
    this.barcode,
  });

  Map<String, dynamic> toJson() => {
    'totalAmount': totalAmount,
    'storeCategory': storeCategory,
    'timestamp': timestamp?.toIso8601String(),
    'barcode': barcode,
  };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    totalAmount: json['totalAmount'],
    storeCategory: json['storeCategory'],
    timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    barcode: json['barcode'],
  );
}

class OCRReader extends StatefulWidget {
  final bool isFromFamilyMode;

  OCRReader({Key? key, this.isFromFamilyMode = false}) : super(key: key);
  @override
  OCRReaderState createState() => OCRReaderState();
}

class OCRReaderState extends State<OCRReader> {
  final picker = ImagePicker();
  List<XFile> images = [];
  bool _isProcessing = false;
  String? _errorMessage;
  static const String _apiKey = 'AIzaSyBSREhZpDAkqLk1Zurl0VrvNkt1ELnFQQ4';

  @override
  void initState() {
    super.initState();
    // No need to load receipts here; handled by Provider
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    scanReceipt();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.folder),
                  title: Text('Choose from Files'),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImageFromFiles();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImageFromGallery() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (picked != null) {
        setState(() {
          images.add(picked);
          _errorMessage = null;
        });
        await processImages();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error accessing gallery: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  Future<void> pickImageFromFiles() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (picked != null) {
        setState(() {
          images.add(picked);
          _errorMessage = null;
        });
        await processImages();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error accessing files: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  Future<void> scanReceipt() async {
    try {
      setState(() {
        _isProcessing = false;
        _errorMessage = null;
      });
      
      images.clear();
      bool addMore = true;
      while (addMore) {
        final picked = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 80,
        );
        
        if (picked == null) {
          setState(() {
            _errorMessage = "No image was selected";
          });
          break;
        }

        setState(() {
          images.add(picked);
          _errorMessage = null;
        });

        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Add another image?'),
            content: Text('Do you want to add another image or process now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Add More')
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Process')
              ),
            ],
          ),
        );
        addMore = confirm ?? false;
      }

      if (images.isNotEmpty) {
        await processImages();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error accessing camera: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!)),
      );
    }
  }

  DateTime? extractDate(String text) {
    print('Attempting to extract date from text: $text'); // Debug print

    // Define common date format patterns and their corresponding format strings
    final formats = <String, String> {
      // YYYY-MM-DD or YYYY/MM/DD (most specific)
      r'\d{4}[-/]\d{2}[-/]\d{2}': 'yyyy-MM-dd', // Use yyyy-MM-dd as the base, can handle / too with regex
      // Month DD, YYYY
      r'(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}': 'MMM d, yyyy',
      // MM/DD/YYYY
      r'\d{2}/\d{2}/\d{4}': 'MM/dd/yyyy',
      // MM-DD-YYYY
      r'\d{2}-\d{2}-\d{4}': 'MM-dd-yyyy',
      // DD/MM/YYYY
      r'\d{2}/\d{2}/\d{4}': 'dd/MM/yyyy', // Note: This might conflict with MM/DD/YYYY, order matters
      // DD-MM-YYYY
      r'\d{2}-\d{2}-\d{4}': 'dd-MM-yyyy', // Note: This might conflict with MM-DD-YYYY, order matters
      // MM/DD/YY or MM-DD/YY
      r'\d{2}[-/]\d{2}[-/]\d{2}': 'MM/dd/yy', // Use a single pattern for both / and - and handle ambiguity in parsing
    };

    // Iterate through patterns and try to parse
    for (var entry in formats.entries) {
      final pattern = entry.key;
      final formatString = entry.value;
      final regex = RegExp(pattern, caseSensitive: false);
      final matches = regex.allMatches(text).toList();

      if (matches.isNotEmpty) {
        for (var match in matches) {
          final dateStr = match.group(0)!;
          print('Found date string: $dateStr with pattern $pattern'); // Debug print
          try {
            DateTime? parsedDate;

            if (formatString == 'MM/dd/yy') { // Special handling for YY formats
              final parts = dateStr.split(RegExp('[-/]'));
              if (parts.length == 3) {
                final part1 = int.parse(parts[0]);
                final part2 = int.parse(parts[1]);
                final twoDigitYear = int.parse(parts[2]);
                final currentYear = DateTime.now().year;
                final prefix = (currentYear ~/ 100) * 100;

                // Determine full year (assuming within last 20 years or next 80)
                final year = (currentYear % 100 >= twoDigitYear && currentYear % 100 - twoDigitYear <= 20) 
                    ? prefix + twoDigitYear 
                    : (twoDigitYear - currentYear % 100 > 80 ? (prefix - 100) + twoDigitYear : prefix + twoDigitYear);

                // Handle MM/DD vs DD/MM ambiguity
                if (part1 > 12) { // part1 must be day (DD/MM/YY)
                  parsedDate = DateTime(year, part2, part1);
                } else if (part2 > 12) { // part2 must be day (MM/DD/YY)
                   parsedDate = DateTime(year, part1, part2);
                } else { // Both <= 12, assume MM/DD (common US format)
                   parsedDate = DateTime(year, part1, part2);
                }
              }
            } else { // Use DateFormat for less ambiguous formats
               parsedDate = DateFormat(formatString).parse(dateStr);
    }

            // Add a basic validation to prevent parsing unrelated numbers as dates (e.g., amounts)
            // Check if the parsed date is within a reasonable range (e.g., last 50 years and not in the future)
            final now = DateTime.now();
            final fiftyYearsAgo = now.subtract(Duration(days: 50 * 365));
            if (parsedDate != null && parsedDate.isAfter(fiftyYearsAgo) && parsedDate.isBefore(now.add(Duration(days: 1)))) {
               print('Successfully parsed date: $parsedDate using format $formatString'); // Debug print
               return parsedDate;
            } else {
              print('Parsed date $parsedDate is outside reasonable range or null'); // Debug print
            }

        } catch (e) {
            print('Error parsing date string \'$dateStr\' with format \'$formatString\': $e'); // Debug print
            // Continue to next match/pattern if parsing fails for this match
          }
        }
      }
    }

    print('No date found in text'); // Debug print
    return null;
  }

  Future<void> processImages() async {
    if (images.isEmpty) return;
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      String combinedText = '';
      String? detectedBarcode;

      for (var image in images) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        final response = await http.post(
          Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_apiKey'),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "requests": [
              {
                "image": {"content": base64Image},
                "features": [
                  {
                    "type": "TEXT_DETECTION",
                    "maxResults": 10
                  },
                  {
                     "type": "BARCODE_DETECTION"
                  }
                ]
              }
            ]
          }),
        );

        if (response.statusCode != 200) {
          print('API Response: \\${response.body}');
          throw Exception('Failed to process image: \\${response.statusCode} - \\${response.body}');
        }

        final body = jsonDecode(response.body);
        if (body["responses"] == null || body["responses"].isEmpty) {
          throw Exception('No response from API');
        }

        final text = body["responses"][0]["fullTextAnnotation"]?["text"] ?? "";
        if (text.isEmpty) {
          if (body["responses"][0]["barcodeAnnotations"] == null || body["responses"][0]["barcodeAnnotations"].isEmpty) {
          throw Exception('No text detected in image. Please try a clearer image.');
          }
        }
        combinedText += text + '\n';

        if (body["responses"][0]["barcodeAnnotations"] != null && body["responses"][0]["barcodeAnnotations"].isNotEmpty) {
           detectedBarcode = body["responses"][0]["barcodeAnnotations"][0]["rawData"];
           print('Detected Barcode: $detectedBarcode');
        }
      }

      if (detectedBarcode != null && Provider.of<ReceiptsProvider>(context, listen: false).barcodeExists(detectedBarcode)) {
         setState(() {
           _isProcessing = false;
         });
         await showDialog(
           context: context,
           builder: (context) => AlertDialog(
             title: Text('Duplicate Receipt'),
             content: Text('This receipt has already been scanned.'),
             actions: [
               TextButton(
                 onPressed: () => Navigator.pop(context),
                 child: Text('OK'),
               ),
             ],
           ),
         );
         return;
      }

      images.clear();
      final total = extractTotal(combinedText);
      if (total == null) {
        throw Exception('Could not extract total amount from receipt. Please try again with a clearer image.');
      }

      final category = categorizeByText(combinedText);
      final date = extractDate(combinedText);
      
      if (date == null) {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (selectedDate == null) {
          throw Exception('Please select a date for the receipt.');
        }

        final newReceipt = Receipt(
          totalAmount: total,
          storeCategory: category == 'Unrecognized' ? 'Unrecognized - Please add category manually' : category,
          timestamp: selectedDate,
          barcode: detectedBarcode,
        );

        Provider.of<ReceiptsProvider>(context, listen: false).addReceipt(newReceipt);

        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(category == 'Unrecognized' ?
              'Could not recognize the store category. Please add the category manually.' :
              'Successfully processed receipt: \$${total.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
      final newReceipt = Receipt(
        totalAmount: total,
        storeCategory: category == 'Unrecognized' ? 'Unrecognized - Please add category manually' : category,
        timestamp: date,
          barcode: detectedBarcode,
      );

      Provider.of<ReceiptsProvider>(context, listen: false).addReceipt(newReceipt);

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(category == 'Unrecognized' ?
            'Could not recognize the store category. Please add the category manually.' :
            'Successfully processed receipt: \$${total.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
      }
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double? extractTotal(String text) {
    // Try multiple patterns to find the total
    final patterns = [
      // Simple total pattern
      r'total\s*:?\s*\$?\s*(\d+\.\d{2})',
      // Amount pattern
      r'amount\s*:?\s*\$?\s*(\d+\.\d{2})',
      // Final total pattern
      r'final\s+total\s*:?\s*\$?\s*(\d+\.\d{2})',
      // Grand total pattern
      r'grand\s+total\s*:?\s*\$?\s*(\d+\.\d{2})',
      // Amount due pattern
      r'amount\s+due\s*:?\s*\$?\s*(\d+\.\d{2})',
      // Look for numbers that might be totals
      r'\$?\s*(\d+\.\d{2})\s*(?=total|amount|due|final|grand)?',
    ];

    print('Extracting total from text: $text'); // Debug print

    for (var pattern in patterns) {
      try {
        final matches = RegExp(pattern, caseSensitive: false, multiLine: true)
            .allMatches(text)
            .toList();
        
        if (matches.isNotEmpty) {
          // Get the last match as it's more likely to be the final total
          final match = matches.last;
          final value = double.tryParse(match.group(1)!);
          if (value != null && value > 0 && value < 10000) { // Reasonable range check
            print('Found total: $value'); // Debug print
            return value;
          }
        }
      } catch (e) {
        print('Error with pattern $pattern: $e');
        continue; // Skip to next pattern if this one fails
      }
    }
    
    print('No total found in text'); // Debug print
    return null;
  }

  String categorizeByText(String text) {
    final normalizedText = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    // Remove all non-alphanumeric characters for robust matching

    // Define category keywords with priority levels
    final Map<String, Map<String, List<String>>> categoryKeywords = {
      'Auto': {
        'high': ['carwash', 'car wash', 'repair', 'auto', 'mechanic', 'service', 'maintenance', 'oil', 'tire', 'automotive', 'vehicle', 'car service', 'auto repair', 'parts', 'accessories'],
        'medium': [],
        'low': []
      },
      'Grocery': {
        'high': ['walmart', 'costco', 'target', 'superstore', 'supermarket', 'grocery', 'save on foods', 'safeway', 'whole foods', 'wholefoods', 'whole-foods', 'whole foods market', 'wholefoods market', 'whole-foods market', 'trader joe', 'aldi', 'loblaws', 'metro', 'food basics', 'freshco', 'no frills'],
        'medium': ['dollarama', 'dollar tree', 'shoppers drug mart', 'pharmacy', 'drug store', 'essentials', 'household', 'cleaning', 'personal care', 'bakery', 'bread', 'pastry', 'bakehouse', 'bake shop', 'baked goods'],
        'low': ['market', 'mart'] // Removed generic 'store' and 'shop' to avoid coffee shop conflicts
      },
      'Transportation': {
        'high': ['petro', 'gas', 'shell', 'chevron', 'exxon', 'mobil', 'bp', 'fuel', 'diesel', 'esso', 'sunoco', 'ultramar', 'uber', 'lyft', 'taxi'],
        'medium': ['transportation', 'transit', 'bus', 'train', 'subway', 'ride share', 'parking', 'toll', 'fare', 'ticket'],
        'low': []
      },
      'Personal': {
        'high': ['beauty', 'sephora', 'ulta', 'cosmetics', 'makeup', 'skincare', 'hair', 'salon', 'spa', 'clothes', 'clothing', 'apparel', 'fashion', 'winners'],
        'medium': ['brand', 'brands', 'retail', 'department', 'personal', 'health', 'medical', 'dental', 'vision', 'insurance', 'subscription', 'membership'],
        'low': ['gift', 'donation', 'charity']
      },
      'Dining': {
        'high': ['coffee shop', 'coffee house', 'coffeehouse', 'cafe', 'café', 'starbucks', 'tim hortons', 'timhortons', 'dunkin', 'dunkin donuts', 'second cup', 'restaurant', 'pizza', 'burger', 'diner', 'fastfood', 'fast food', 'mcdonalds', 'subway', 'bar', 'pub', 'grill', 'bistro', 'eatery', 'brewery'],
        'medium': ['coffee', 'espresso', 'latte', 'cappuccino', 'dining', 'food service', 'takeout', 'delivery', 'catering', 'dessert', 'ice cream'],
        'low': []
      },
      'Entertainment': {
        'high': ['movie', 'theater', 'cinema', 'concert', 'show', 'entertainment', 'amusement', 'arcade', 'bowling', 'museum', 'zoo', 'aquarium'],
        'medium': ['ticket', 'event', 'park', 'festival', 'exhibit', 'sports', 'fitness', 'gym', 'recreation', 'hobby', 'craft', 'game', 'book', 'magazine'],
        'low': ['subscription', 'streaming', 'music', 'art']
      },
    };

    // Calculate weighted scores for each category
    Map<String, double> scores = {};
    for (var category in categoryKeywords.keys) {
      scores[category] = 0.0;
      final keywords = categoryKeywords[category]!;
      
      // High priority keywords get 3x weight
      for (var keyword in keywords['high']!) {
        final normalizedKeyword = keyword.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (normalizedText.contains(normalizedKeyword)) {
          scores[category] = scores[category]! + 3.0;
        }
      }
      
      // Medium priority keywords get 2x weight
      for (var keyword in keywords['medium']!) {
        final normalizedKeyword = keyword.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (normalizedText.contains(normalizedKeyword)) {
          scores[category] = scores[category]! + 2.0;
        }
      }
      
      // Low priority keywords get 1x weight
      for (var keyword in keywords['low']!) {
        final normalizedKeyword = keyword.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (normalizedText.contains(normalizedKeyword)) {
          scores[category] = scores[category]! + 1.0;
        }
      }
    }

    // Find category with highest score
    String bestCategory = 'Unrecognized';
    double highestScore = 0.0;

    // Define priority order for tie-breaking (higher index = higher priority)
    final priorityOrder = ['Grocery', 'Transportation', 'Auto', 'Personal', 'Entertainment', 'Dining'];

    // Iterate through categories in priority order to find the best match
    for (var category in priorityOrder) {
      final score = scores[category] ?? 0.0;
      if (score > highestScore) {
        highestScore = score;
        bestCategory = category;
      } else if (score == highestScore && highestScore > 0) {
        // If scores are equal, prioritize based on the order in priorityOrder
        bestCategory = category;
      }
    }

    // Special handling for very low confidence matches
    if (highestScore <= 1.0) {
      // Check if this is a potential misclassification
      final hasMultipleMatches = scores.values.where((score) => score > 0).length > 1;
      if (hasMultipleMatches) {
        // If multiple categories matched with low confidence, mark as unrecognized
        return 'Unrecognized';
      }
    }

    if (highestScore == 0) {
      return 'Unrecognized';
    }

    return bestCategory;
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = [
      'Grocery', 'Transportation', 'Dining', 'Auto', 'Entertainment', 'Personal'
    ];
    final receipts = Provider.of<ReceiptsProvider>(context).receipts;
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Receipts'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.isFromFamilyMode) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DeviceFrame(child: FamilyMode())),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: ListView(
      padding: EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _showImageSourceDialog,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                ),
                icon: Icon(Icons.add_a_photo),
                label: Text(
                    _isProcessing ? "Processing..." : "Scan Another Receipt",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        if (receipts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteAllConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.delete_forever, color: Colors.white),
              label: Text(
                "Delete All Receipts",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        if (_isProcessing)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Processing receipt...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (receipts.isEmpty && !_isProcessing && _errorMessage == null)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(
                    'assets/images/welcome_illustration.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Simple placeholder instead of custom logo
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 40,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Ready to start tracking?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Snap your first receipt to begin your smart money journey!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ...receipts.asMap().entries.map((entry) {
          final index = entry.key;
          final r = entry.value;
          final isUnrecognized = r.storeCategory.startsWith('Unrecognized');
          return Card(
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Category: \\${isUnrecognized ? 'Unrecognized' : r.storeCategory}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(r.storeCategory),
                      ),
                    ),
                  ),
                  if (isUnrecognized)
                    TextButton.icon(
                      icon: Icon(Icons.category, color: Colors.blue),
                      label: Text("Choose Category", style: TextStyle(color: Colors.blue)),
                      onPressed: () => _showCategoryPickerDialog(index, availableCategories),
                    ),
                ],
              ),
              subtitle: Text(
                r.timestamp != null 
                  ? DateFormat.yMMMd().format(r.timestamp!)
                  : "No date",
                style: TextStyle(
                  color: r.timestamp == null ? Colors.grey : null,
                  fontStyle: r.timestamp == null ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "\$${r.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(index),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
      ),
      floatingActionButton: widget.isFromFamilyMode ? FloatingActionButton.extended(
        heroTag: "ocr_reader_fab", // Add unique hero tag
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DeviceFrame(child: FamilyMode())),
          );
        },
        icon: Icon(Icons.check, color: Colors.white),
        label: Text('Done', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ) : null,
    );
  }

  Future<void> _showDeleteAllConfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete All Receipts'),
          content: Text('Are you sure you want to delete all receipts? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<ReceiptsProvider>(context, listen: false).clearReceipts();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All receipts deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Receipt'),
          content: Text('Are you sure you want to delete this receipt?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<ReceiptsProvider>(context, listen: false).deleteReceipt(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Receipt deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCategoryPickerDialog(int index, List<String> categories) async {
    String? selectedCategory;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Category'),
          content: DropdownButton<String>(
            value: selectedCategory,
            hint: Text('Select a category'),
            isExpanded: true,
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (value) {
              selectedCategory = value;
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
    if (selectedCategory != null) {
      final provider = Provider.of<ReceiptsProvider>(context, listen: false);
      final receipts = provider.receipts;
      final updatedReceipt = Receipt(
        totalAmount: receipts[index].totalAmount,
        storeCategory: selectedCategory!,
        timestamp: receipts[index].timestamp,
      );
      provider.updateReceipt(index, updatedReceipt);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category updated!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Grocery':
        return Colors.green;
      case 'Transportation':
        return Colors.blue;
      case 'Dining':
        return Colors.orange;
      case 'Auto':
        return Colors.red;
      case 'Entertainment':
        return Colors.purple;
      case 'Personal':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

class MonthlySummary extends StatefulWidget {
  final double totalMonthBudget;

  const MonthlySummary({Key? key, required this.totalMonthBudget}) : super(key: key);

  @override
  _MonthlySummaryState createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<MonthlySummary> {
  DateTime _selectedMonth = DateTime.now();

  List<int> _getAvailableYears(ReceiptsProvider receiptsProvider) {
    Set<int> years = {};
    // Add years from receipts
    for (var receipt in receiptsProvider.receipts) {
      if (receipt.timestamp != null) {
        years.add(receipt.timestamp!.year);
      }
    }
    // Include the current year even if no data exists
    years.add(DateTime.now().year);
    return years.toList()..sort((a, b) => b.compareTo(a)); // Sort descending
  }

  void _showYearPicker(BuildContext context) {
    final receiptsProvider = Provider.of<ReceiptsProvider>(context, listen: false);
    final years = _getAvailableYears(receiptsProvider);

    if (years.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data found to view reports')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Year'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return ListTile(
                title: Text(year.toString()),
                onTap: () {
                  Navigator.pop(context);
                  _showMonthPicker(context, year);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context, int year) {
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
                title: Text(DateFormat('MMMM').format(DateTime(year, month))),
                onTap: () {
                  setState(() {
                    _selectedMonth = DateTime(year, month);
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

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final receiptsProvider = Provider.of<ReceiptsProvider>(context);
    final monthReceipts = receiptsProvider.receipts.where((r) =>
      r.timestamp != null &&
      r.timestamp!.month == _selectedMonth.month &&
      r.timestamp!.year == _selectedMonth.year
    ).toList();

    final totalSpent = budgetProvider.getTotalSpent(monthReceipts);
    final totalBudget = budgetProvider.getTotalBudget(_selectedMonth);
    final remaining = totalBudget - totalSpent;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selection Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showYearPicker(context),
              icon: Icon(Icons.calendar_today),
              label: Text(
                "Viewing: ${DateFormat('MMMM yyyy').format(_selectedMonth)}",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: Size(200, 50),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Monthly Overview Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Budget', '\$${totalBudget.toStringAsFixed(2)}', Colors.blue),
                      _buildStatColumn('Spent', '\$${totalSpent.toStringAsFixed(2)}', Colors.orange),
                      _buildStatColumn('Remaining', '\$${remaining.toStringAsFixed(2)}', 
                        remaining >= 0 ? Colors.green : Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Category Breakdown
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ...kCategories.map((category) {
            final spent = budgetProvider.getCategorySpent(category, monthReceipts);
            final budget = budgetProvider.getBudget(category, _selectedMonth);
            final remaining = budget - spent;
            final percent = budget > 0 ? (spent / budget).clamp(0, 1).toDouble() : 0.0;

            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$${spent.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: remaining < 0 ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent < 0.7 ? Colors.green :
                        percent < 1.0 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class MonthlyComparison extends StatefulWidget {
  final double totalMonthBudget;

  const MonthlyComparison({Key? key, required this.totalMonthBudget}) : super(key: key);

  @override
  _MonthlyComparisonState createState() => _MonthlyComparisonState();
}

class _MonthlyComparisonState extends State<MonthlyComparison> {
  int? _selectedYear;
  String? _selectedCategory;

  // Get unique years from receipts and budgets
  List<int> _getAvailableYears(ReceiptsProvider receiptsProvider, BudgetProvider budgetProvider) {
    Set<int> years = {};
    // Add years from receipts
    for (var receipt in receiptsProvider.receipts) {
      if (receipt.timestamp != null) {
        years.add(receipt.timestamp!.year);
      }
    }
    // Add years from saved budgets keys
     budgetProvider.getMonthBudgets(DateTime.now()).keys.forEach((key) { // Use dummy date for getMonthBudgets to get all keys
        final parts = key.split('-');
        if(parts.length == 2) {
            try {
                years.add(int.parse(parts[0]));
            } catch (e) {
                // Handle parsing error if necessary
            }
        }
    });
    // Include the current year even if no data exists
    years.add(DateTime.now().year);


    return years.toList()..sort((a, b) => b.compareTo(a)); // Sort descending
  }

  void _showYearPicker(BuildContext context) {
    final receiptsProvider = Provider.of<ReceiptsProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final years = _getAvailableYears(receiptsProvider, budgetProvider);

    if (years.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data found to compare months')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Year'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return ListTile(
                title: Text(year.toString()),
                onTap: () {
                  setState(() {
                    _selectedYear = year;
                    _selectedCategory = null; // Reset category when year changes
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

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final receiptsProvider = Provider.of<ReceiptsProvider>(context);
    final allReceipts = receiptsProvider.receipts;

    // Filter receipts for the selected year
    final yearReceipts = _selectedYear != null
        ? allReceipts.where((r) => r.timestamp != null && r.timestamp!.year == _selectedYear).toList()
        : <Receipt>[]; // Explicitly type the empty list

    // Calculate monthly spent and budget for the selected year
    final Map<int, double> monthlySpent = {};
    final Map<int, double> monthlyBudget = {};
    final Map<int, Map<String, double>> monthlyCategorySpent = {};

    if (_selectedYear != null) {
      for (int i = 1; i <= 12; i++) {
        final monthDateTime = DateTime(_selectedYear!, i, 1);
        // Ensure monthReceipts is correctly typed as List<Receipt>
        final monthReceipts = yearReceipts.where((r) => r.timestamp!.month == i).toList().cast<Receipt>();

        monthlySpent[i] = budgetProvider.getTotalSpent(monthReceipts);
        monthlyBudget[i] = budgetProvider.getTotalBudget(monthDateTime);

        monthlyCategorySpent[i] = {};
        for (var category in kCategories) {
           monthlyCategorySpent[i]![category] = budgetProvider.getCategorySpent(category, monthReceipts);
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year Selection Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showYearPicker(context),
              icon: Icon(Icons.calendar_today),
              label: Text(
                _selectedYear != null
                  ? "Viewing Year: $_selectedYear"
                  : "Select Year to Compare Months",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: Size(200, 50),
              ),
            ),
          ),
          SizedBox(height: 20),

          if (_selectedYear != null) ...[
            // Yearly Summary Card (based on filtered receipts for the year)
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Yearly Summary for $_selectedYear",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text("Total Budget (Annualized):", style: TextStyle(fontSize: 18)),
                         // This will be the sum of monthly budgets for the selected year
                         Text(
                           "\$${monthlyBudget.values.fold(0.0, (sum, amount) => sum + amount).toStringAsFixed(2)}",
                           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                         ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Spent:", style: TextStyle(fontSize: 18)),
                        Text(
                          "\$${budgetProvider.getTotalSpent(yearReceipts).toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Monthly Spending vs Budget Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Spending vs Budget",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          // Max Y should be highest of budget or spent, plus some padding
                          maxY: [
                            monthlyBudget.values.fold(0.0, (maxVal, v) => max(maxVal, v)),
                            monthlySpent.values.fold(0.0, (maxVal, v) => max(maxVal, v))
                          ].reduce(max) * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.teal,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                 String monthName = DateFormat('MMM').format(DateTime(_selectedYear!, group.x + 1, 1));
                                if (rodIndex == 0) { // Budget bar
                                   return BarTooltipItem(
                                      '$monthName Budget:\n\$${rod.toY.toStringAsFixed(2)}',
                                      TextStyle(color: Colors.white),
                                   );
                                } else { // Spent bar
                                   return BarTooltipItem(
                                      '$monthName Spent:\n\$${rod.toY.toStringAsFixed(2)}',
                                      TextStyle(color: Colors.white),
                                   );
                                }
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20, // Adjust if needed
                                getTitlesWidget: (value, meta) {
                                  const months = ['J', 'F', 'M', 'A', 'M', 'J',
                                               'J', 'A', 'S', 'O', 'N', 'D'];
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 4.0, // Adjust if needed
                                      child: Text(
                                        months[value.toInt()],
                                        style: TextStyle(fontSize: 10), // Adjust if needed
                                      ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                   // Only show integer multiples for clarity
                                   if (value % (meta.appliedInterval ?? 1.0) == 0) {
                                      return Text(
                                         '\$${value.toInt()}',
                                         style: TextStyle(fontSize: 10),
                                      );
                                   }
                                   return Container();
                                },
                                interval: (([
                                     monthlyBudget.values.fold(0.0, (maxVal, v) => max(maxVal, v)),
                                     monthlySpent.values.fold(0.0, (maxVal, v) => max(maxVal, v))
                                   ].reduce(max) * 1.2) / 5).clamp(1.0, double.infinity), // Auto interval, min 1
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: ([
                                     monthlyBudget.values.fold(0.0, (maxVal, v) => max(maxVal, v)),
                                     monthlySpent.values.fold(0.0, (maxVal, v) => max(maxVal, v))
                                   ].reduce(max) * 1.2 / 5).clamp(1.0, double.infinity),
                          ),
                          barGroups: List.generate(12, (index) {
                            final month = index + 1;
                            final spent = monthlySpent[month] ?? 0.0;
                            final budget = monthlyBudget[month] ?? 0.0;

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                 // Budget Bar (behind spent bar)
                                 BarChartRodData(
                                    toY: budget,
                                    color: Colors.teal.shade200, // Lighter color for budget
                                    width: 12,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                 ),
                                // Spent Bar
                                BarChartRodData(
                                  toY: spent,
                                  color: spent > budget ? Colors.redAccent : Colors.teal, // Red if over budget
                                  width: 12,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                                // barDistanceSpace: 0, // Removed incorrect parameter
                                // groupVertically: false, // Removed incorrect parameter
                            );
                          }),
                          groupsSpace: 12, // Space between month groups
                        ),
                      ),
                    ),
                     SizedBox(height: 16),
                     // Legend for Monthly Spending vs Budget chart
                     Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                             Container(width: 12, height: 12, color: Colors.teal),
                             SizedBox(width: 4),
                             Text('Spent (Within Budget)'),
                             SizedBox(width: 16),
                             Container(width: 12, height: 12, color: Colors.redAccent),
                             SizedBox(width: 4),
                             Text('Spent (Over Budget)'),
                              SizedBox(width: 16),
                             Container(width: 12, height: 12, color: Colors.teal.shade200),
                             SizedBox(width: 4),
                             Text('Budget'),
                         ],
                     ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Category Selection for detailed breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Category Analysis for $_selectedYear",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kCategories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: kCategoryColors[category]?.withOpacity(0.2),
                          checkmarkColor: kCategoryColors[category],
                          labelStyle: TextStyle(
                            color: isSelected ? kCategoryColors[category] : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Category Monthly Breakdown Chart (if category selected)
            if (_selectedCategory != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$_selectedCategory Spending vs Budget in $_selectedYear",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                             // Max Y should be highest of category budget or spent, plus some padding
                            maxY: [
                               budgetProvider.getBudget(_selectedCategory!, DateTime(_selectedYear!, 1, 1)), // Use a dummy date for the year to get the category budget
                                monthlyCategorySpent.values.map((monthData) => monthData[_selectedCategory] ?? 0.0).fold(0.0, (maxVal, v) => max(maxVal, v)),
                            ].reduce(max) * 1.2,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: kCategoryColors[_selectedCategory] ?? Colors.teal,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                   String monthName = DateFormat('MMM').format(DateTime(_selectedYear!, group.x + 1, 1));
                                   if (rodIndex == 0) { // Budget bar
                                      return BarTooltipItem(
                                         '$monthName Budget:\n\$${rod.toY.toStringAsFixed(2)}',
                                         TextStyle(color: Colors.white),
                                      );
                                   } else { // Spent bar
                                      return BarTooltipItem(
                                         '$monthName Spent:\n\$${rod.toY.toStringAsFixed(2)}',
                                         TextStyle(color: Colors.white),
                                      );
                                   }
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 20, // Adjust if needed
                                  getTitlesWidget: (value, meta) {
                                    const months = ['J', 'F', 'M', 'A', 'M', 'J',
                                                 'J', 'A', 'S', 'O', 'N', 'D'];
                                    return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 4.0, // Adjust if needed
                                        child: Text(
                                          months[value.toInt()],
                                          style: TextStyle(fontSize: 10), // Adjust if needed
                                        ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                     // Only show integer multiples for clarity
                                     if (value % (meta.appliedInterval ?? 1.0) == 0) {
                                        return Text(
                                           '\$${value.toInt()}',
                                           style: TextStyle(fontSize: 10),
                                        );
                                     }
                                     return Container();
                                  },
                                   interval: ([
                                        budgetProvider.getBudget(_selectedCategory!, DateTime(_selectedYear!, 1, 1)),
                                        monthlyCategorySpent.values.map((monthData) => monthData[_selectedCategory] ?? 0.0).fold(0.0, (maxVal, v) => max(maxVal, v)),
                                    ].reduce(max) * 1.2 / 5).clamp(1.0, double.infinity), // Auto interval, min 1
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                               horizontalInterval: ([
                                   budgetProvider.getBudget(_selectedCategory!, DateTime(_selectedYear!, 1, 1)),
                                   monthlyCategorySpent.values.map((monthData) => monthData[_selectedCategory] ?? 0.0).fold(0.0, (maxVal, v) => max(maxVal, v)),
                               ].reduce(max) * 1.2 / 5).clamp(1.0, double.infinity),
                            ),
                            barGroups: List.generate(12, (index) {
                              final month = index + 1;
                              final monthDateTime = DateTime(_selectedYear!, month, 1);
                              final spent = monthlyCategorySpent[month]?[_selectedCategory] ?? 0.0;
                              final budget = budgetProvider.getBudget(_selectedCategory!, monthDateTime);

                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                   // Budget Bar (behind spent bar)
                                   BarChartRodData(
                                      toY: budget,
                                      color: kCategoryColors[_selectedCategory]?.withOpacity(0.4) ?? Colors.teal.shade200, // Lighter color for budget
                                      width: 12,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                   ),
                                  // Spent Bar
                                  BarChartRodData(
                                    toY: spent,
                                    color: spent > budget ? Colors.redAccent : kCategoryColors[_selectedCategory], // Red if over budget
                                    width: 12,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ],
                                // barDistanceSpace: 0, // Removed incorrect parameter
                                // groupVertically: false, // Removed incorrect parameter
                              );
                            }),
                             groupsSpace: 12, // Space between month groups
                          ),
                        ),
                      ),
                       SizedBox(height: 16),
                        // Legend for Category Monthly Spending vs Budget chart
                       Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                               Container(width: 12, height: 12, color: kCategoryColors[_selectedCategory] ?? Colors.teal),
                               SizedBox(width: 4),
                               Text('Spent (Within Budget)'),
                               SizedBox(width: 16),
                               Container(width: 12, height: 12, color: Colors.redAccent),
                               SizedBox(width: 4),
                               Text('Spent (Over Budget)'),
                                SizedBox(width: 16),
                               Container(width: 12, height: 12, color: kCategoryColors[_selectedCategory]?.withOpacity(0.4) ?? Colors.teal.shade200),
                               SizedBox(width: 4),
                               Text('Budget'),
                           ],
                       ),
                    ],
                  ),
                ),
              ),
             SizedBox(height: 20),

             // Category Monthly Breakdown Table (if category selected)
            if (_selectedCategory != null)
               Card(
                  child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                              "$_selectedCategory Monthly Breakdown Table",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                           ),
                           SizedBox(height: 16),
                           SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                 columns: [
                                    DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Budget', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Spent', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold))),
                                 ],
                                 rows: List.generate(12, (index) {
                                    final month = index + 1;
                                    final monthDateTime = DateTime(_selectedYear!, month, 1);
                                    final spent = monthlyCategorySpent[month]?[_selectedCategory] ?? 0.0;
                                    final budget = budgetProvider.getBudget(_selectedCategory!, monthDateTime);
                                    final remaining = budget - spent;

                                    return DataRow(cells: [
                                       DataCell(Text(DateFormat('MMM').format(monthDateTime))),
                                       DataCell(Text("\$${budget.toStringAsFixed(2)}")),
                                       DataCell(Text("\$${spent.toStringAsFixed(2)}")),
                                       DataCell(Text("\$${remaining.toStringAsFixed(2)}",
                                          style: TextStyle(color: remaining < 0 ? Colors.red : null))),
                                    ]);
                                 }),
                              ),
                           ),
                        ],
                     ),
                  ),
               ),
             SizedBox(height: 20),

            // Overall Monthly Breakdown Table
            Card(
               child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text(
                           "Overall Monthly Breakdown Table",
                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: DataTable(
                              columns: [
                                 DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.bold))),
                                 DataColumn(label: Text('Total Budget', style: TextStyle(fontWeight: FontWeight.bold))),
                                 DataColumn(label: Text('Total Spent', style: TextStyle(fontWeight: FontWeight.bold))),
                                 DataColumn(label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: List.generate(12, (index) {
                                 final month = index + 1;
                                 final monthDateTime = DateTime(_selectedYear!, month, 1);
                                 // Use the monthlySpent calculated earlier, don't re-filter yearReceipts
                                 final spent = monthlySpent[month] ?? 0.0;
                                 final budget = monthlyBudget[month] ?? 0.0; // Use monthlyBudget
                                 final remaining = budget - spent;

                                 return DataRow(cells: [
                                    DataCell(Text(DateFormat('MMM').format(monthDateTime))),
                                    DataCell(Text("\$${budget.toStringAsFixed(2)}")),
                                    DataCell(Text("\$${spent.toStringAsFixed(2)}")),
                                    DataCell(Text("\$${remaining.toStringAsFixed(2)}",
                                       style: TextStyle(color: remaining < 0 ? Colors.red : null))),
                                 ]);
                              }),
                           ),
                        ),
                     ],
                  ),
               ),
            ),

          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Select a year to view monthly comparisons and breakdowns",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReceiptsProvider with ChangeNotifier {
  List<Receipt> _receipts = [];
  final String _receiptsKey = 'receipts';

  List<Receipt> get receipts => _receipts;

  ReceiptsProvider() {
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? receiptsString = prefs.getString(_receiptsKey);
      if (receiptsString != null) {
        final List<dynamic> receiptList = jsonDecode(receiptsString);
        _receipts = receiptList.map((json) => Receipt.fromJson(json as Map<String, dynamic>)).toList();
        // Filter out any receipts that might have failed to load correctly
        _receipts.removeWhere((receipt) => receipt.totalAmount == null || receipt.storeCategory == null);
      } else {
        _receipts = [];
      }
    } catch (e) {
      print('Error loading receipts: $e');
      _receipts = []; // Initialize with empty list on error
    }
    notifyListeners();
  }

  Future<void> _saveReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(_receipts.map((r) => r.toJson()).toList());
      await prefs.setString(_receiptsKey, jsonString);
    } catch (e) {
      print('Error saving receipts: $e');
      // Handle save error if necessary
    }
  }

  void addReceipt(Receipt receipt) {
    _receipts.insert(0, receipt);
    _saveReceipts();
    notifyListeners();
  }

  void deleteReceipt(int index) {
    if (index >= 0 && index < _receipts.length) {
      _receipts.removeAt(index);
      _saveReceipts();
      notifyListeners();
    }
  }

  void updateReceipt(int index, Receipt updatedReceipt) {
     if (index >= 0 && index < _receipts.length) {
      _receipts[index] = updatedReceipt;
      _saveReceipts();
      notifyListeners();
    }
  }

  void clearReceipts() {
    _receipts.clear();
    _saveReceipts();
    notifyListeners();
  }

  // New method to check if a barcode already exists
  bool barcodeExists(String barcode) {
    return _receipts.any((receipt) => receipt.barcode == barcode && receipt.barcode != null);
  }
}

class BudgetProvider with ChangeNotifier {
  // Store budgets with a composite key: "YYYY-MM_CategoryName"
  Map<String, double> _budgets = {};
  final String _budgetsKey = 'monthlyBudgets'; // Changed key name

  BudgetProvider() {
    _loadBudgets();
  }

  // Helper to create the storage key
  String _getBudgetKey(String category, DateTime monthYear) {
    final formatter = DateFormat('yyyy-MM');
    return '${formatter.format(monthYear)}_${category}';
  }

  // Helper to parse key components
  MapEntry<String, String>? _parseBudgetKey(String key) {
     final parts = key.split('_');
     if (parts.length < 2) return null;
     final category = parts.sublist(1).join('_'); // Re-join if category had underscores
     return MapEntry(parts[0], category); // Key is monthYear string, Value is category name
  }


  Future<void> _loadBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? budgetsJson = prefs.getString(_budgetsKey);
      print('Attempting to load monthly budgets. Found JSON: $budgetsJson');

      if (budgetsJson != null && budgetsJson.isNotEmpty) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(budgetsJson);
          // Ensure all values are doubles
          _budgets = decoded.map((key, value) => MapEntry(key, value.toDouble()));

          print('Loaded monthly budgets: $_budgets');
           if (_budgets.isNotEmpty) {
             print('Successfully loaded non-empty monthly budgets.');
          } else {
             print('Loaded monthly budgets map is empty.');
          }

        } catch (e) {
          print('Error decoding or mapping monthly budgets from JSON: $e');
          // Initialize with empty budgets on decoding error - don't overwrite potentially valid old data
          _budgets = {};
           // Consider if you want to clear corrupted data:
           // await prefs.remove(_budgetsKey); // Uncomment to clear corrupted data
        }
      } else {
        print('No saved monthly budgets found or saved data is empty. Initializing with empty budgets.');
        _budgets = {}; // Initialize with empty map if no data found or empty
      }
    } catch (e) {
      print('Generic error during monthly budget loading: $e'); // Catch any other errors
      // Initialize with empty budgets on generic error
      _budgets = {};
       // Consider if you want to clear corrupted data:
       // final prefs = await SharedPreferences.getInstance();
       // await prefs.remove(_budgetsKey); // Uncomment to clear corrupted data
    }
    notifyListeners();
  }

  Future<void> _saveBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(_budgets);
      await prefs.setString(_budgetsKey, jsonString);
      print('Saved monthly budgets: $jsonString');
    } catch (e) {
      print('Error saving monthly budgets: $e');
    }
  }

  // Get budget for a specific category and month/year
  double getBudget(String category, DateTime monthYear) {
    final key = _getBudgetKey(category, monthYear);
    final budget = _budgets[key] ?? 0.0;
    // print('Getting budget for $category in ${DateFormat('yyyy-MM').format(monthYear)}: $budget');
    return budget;
  }

  // Set budget for a specific category and month/year
  Future<void> setBudget(String category, DateTime monthYear, double amount) async {
    if (amount < 0) amount = 0.0; // Ensure no negative budgets
    final key = _getBudgetKey(category, monthYear);
    print('Setting budget for $category in ${DateFormat('yyyy-MM').format(monthYear)}: $amount');
    _budgets[key] = amount;
    await _saveBudgets();
    notifyListeners();
  }

   // Get budgets for all categories for a specific month/year
  Map<String, double> getMonthBudgets(DateTime monthYear) {
    final monthBudgets = <String, double>{};
     final monthYearString = DateFormat('yyyy-MM').format(monthYear);
     _budgets.forEach((key, value) {
        final parsedKey = _parseBudgetKey(key);
        if (parsedKey != null && parsedKey.key == monthYearString) {
           monthBudgets[parsedKey.value] = value;
        }
     });
     // Ensure all categories are present, even if budget is 0
     for (var category in kCategories) {
       monthBudgets.putIfAbsent(category, () => 0.0);
     }
     return monthBudgets;
  }


  // Get total spent for a list of receipts (already filtered by month/year)
  double getTotalSpent(List<Receipt> receipts) {
    if (receipts.isEmpty) return 0.0;
    final total = receipts.fold(0.0, (sum, receipt) => sum + (receipt.totalAmount));
    // print('Total spent for given receipts: $total');
    return total;
  }

  // Get total budget for a specific month/year
  double getTotalBudget(DateTime monthYear) {
    double total = 0.0;
    final monthYearString = DateFormat('yyyy-MM').format(monthYear);
     _budgets.forEach((key, value) {
        final parsedKey = _parseBudgetKey(key);
        if (parsedKey != null && parsedKey.key == monthYearString) {
           total += value;
        }
     });
    print('\nCalculating total budget for ${monthYearString}: $total\n');
    return total;
  }

  // Get remaining budget for a specific month/year based on provided receipts (already filtered)
  double getRemainingBudget(List<Receipt> receipts, DateTime monthYear) {
    final total = getTotalBudget(monthYear);
    final spent = getTotalSpent(receipts);
    final remaining = total - spent;
    print('Remaining budget for ${DateFormat('yyyy-MM').format(monthYear)}: $remaining (Total: $total, Spent: $spent)');
    return remaining;
  }

  // Get spent amount for a specific category from a list of receipts (already filtered by month/year)
  double getCategorySpent(String category, List<Receipt> receipts) {
    if (receipts.isEmpty) return 0.0;
    final spent = receipts
        .where((receipt) => receipt.storeCategory == category)
        .fold(0.0, (sum, receipt) => sum + (receipt.totalAmount));
    // print('Category spent for $category for given receipts: $spent');
    return spent;
  }
}

class PasswordScreen extends StatefulWidget {
  final Function onSuccess;

  const PasswordScreen({Key? key, required this.onSuccess}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isPasswordCorrect = true;
  bool _isLoading = false;
  bool _isFirstTime = false;
  bool _passwordsMatch = true;
  bool _isValidEmail = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkFirstTimeSetup();
  }

  Future<void> _checkFirstTimeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Temporarily force first-time setup for demonstration
    await prefs.remove('password');
    await prefs.remove('user_email');
    await prefs.remove('password_protection');
    await prefs.remove('completed_first_time_setup');
    await prefs.remove('user_name');
    await prefs.remove('has_children');
    await prefs.remove('is_first_login');
    
    final savedPassword = prefs.getString('password');
    final savedEmail = prefs.getString('user_email');
    
    setState(() {
      _isFirstTime = true; // Force first-time setup
    });
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handlePasswordSetup() async {
    setState(() {
      _errorMessage = '';
      _passwordsMatch = true;
      _isValidEmail = true;
    });

    // Validate email
    if (_emailController.text.isEmpty || !_isEmailValid(_emailController.text)) {
      setState(() {
        _isValidEmail = false;
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    // Validate password length
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordsMatch = false;
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('user_email', _emailController.text);
    await prefs.setBool('password_protection', true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account setup completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    widget.onSuccess();
  }

  Future<void> _handlePasswordLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password');
    
    if (_passwordController.text == savedPassword) {
      widget.onSuccess();
    } else {
      setState(() {
        _isPasswordCorrect = false;
        _errorMessage = 'Incorrect password';
      });
    }
  }

  Future<void> _handleForgotPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    
    if (savedEmail == null || savedEmail.isEmpty) {
      _showEmailInputDialog();
    } else {
      _showEmailConfirmationDialog(savedEmail);
    }
  }

  void _showEmailInputDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Reset Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the email address associated with your account:'),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty && _isEmailValid(emailController.text)) {
                Navigator.pop(context);
                await _sendPasswordResetEmail(emailController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid email address'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showEmailConfirmationDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.send, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Send Reset Link'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email, size: 48, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'We will send a password reset link to:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendPasswordResetEmail(email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate sending email with more realistic delay
      await Future.delayed(Duration(seconds: 3));

      // Save the email for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Email Sent!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mark_email_read, size: 48, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Password reset instructions have been sent to:',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Please check your email and follow the instructions to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reset link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isFirstTime ? Icons.lock_person : Icons.lock,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 32),
                  Text(
                    _isFirstTime ? 'Setup Your Account' : 'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_isFirstTime) ...[
                    SizedBox(height: 8),
                    Text(
                      'Create a password and provide your email for account recovery',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 32),
                  
                  // Email field (only for first time setup)
                  if (_isFirstTime) ...[
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email Address',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: !_isValidEmail ? 'Please enter a valid email' : null,
                        errorStyle: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: _isFirstTime ? 'Create Password (min 6 characters)' : 'Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      errorText: !_isPasswordCorrect ? 'Incorrect password' : null,
                      errorStyle: TextStyle(color: Colors.red[200]),
                    ),
                  ),
                  
                  // Confirm password field (only for first time setup)
                  if (_isFirstTime) ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: !_passwordsMatch ? 'Passwords do not match' : null,
                        errorStyle: TextStyle(color: Colors.red[200]),
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 16),
                  
                  // Error message
                  if (_errorMessage.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Forgot password (only for login)
                  if (!_isFirstTime) ...[
                    TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ] else ...[
                    SizedBox(height: 24),
                  ],
                  
                  // Main action button
                  if (_isLoading)
                    Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Sending reset email...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: _isFirstTime ? _handlePasswordSetup : _handlePasswordLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(200, 50),
                      ),
                      child: Text(
                        _isFirstTime ? 'Create Account' : 'Continue',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class KidsReportScreen extends StatefulWidget {
  final String childName;
  final Map<String, Map<String, double>> monypocketData;

  const KidsReportScreen({
    Key? key,
    required this.childName,
    required this.monypocketData,
  }) : super(key: key);

  @override
  _KidsReportScreenState createState() => _KidsReportScreenState();
}

class _KidsReportScreenState extends State<KidsReportScreen> {
  DateTime _selectedStartDate = DateTime(2025, 1, 1);
  DateTime _selectedEndDate = DateTime(2025, 12, 31);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade50, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '${widget.childName}\'s Money Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900,
              ),
            ),
            SizedBox(height: 24),

            // Date Range Selection
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From:', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _selectStartDate(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[100],
                                  foregroundColor: Colors.teal[800],
                                  minimumSize: Size(double.infinity, 40),
                                ),
                                child: Text(DateFormat('MMM yyyy').format(_selectedStartDate)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('To:', style: TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _selectEndDate(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[100],
                                  foregroundColor: Colors.teal[800],
                                  minimumSize: Size(double.infinity, 40),
                                ),
                                child: Text(DateFormat('MMM yyyy').format(_selectedEndDate)),
                              ),
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

            // Summary Cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Money Pocket', _getTotalMoneyPocket(), Colors.blue)),
                SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Total Spent', _getTotalSpent(), Colors.orange)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Saved', _getTotalSaved(), Colors.green)),
                SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Remaining', _getTotalRemaining(), Colors.purple)),
              ],
            ),
            SizedBox(height: 24),

            // Monthly Breakdown Chart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 250,
                      child: _buildMonthlyChart(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Detailed Monthly Table
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Monthly Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildDetailedTable(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Savings Breakdown
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Savings Categories Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildSavingsBreakdown(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          'No data available for selected date range',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(filteredData) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.teal,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final monthKey = filteredData.keys.elementAt(group.x);
              final month = DateFormat('MMM yyyy').format(DateTime.parse('$monthKey-01'));
              if (rodIndex == 0) {
                return BarTooltipItem(
                  '$month\nMoney Pocket: \$${rod.toY.toStringAsFixed(2)}',
                  TextStyle(color: Colors.white),
                );
              } else if (rodIndex == 1) {
                return BarTooltipItem(
                  '$month\nSpent: \$${rod.toY.toStringAsFixed(2)}',
                  TextStyle(color: Colors.white),
                );
              } else {
                return BarTooltipItem(
                  '$month\nSaved: \$${rod.toY.toStringAsFixed(2)}',
                  TextStyle(color: Colors.white),
                );
              }
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < filteredData.length) {
                  final monthKey = filteredData.keys.elementAt(value.toInt());
                  final date = DateTime.parse('$monthKey-01');
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4.0,
                    child: Text(
                      DateFormat('MMM').format(date),
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        barGroups: filteredData.entries.map((entry) {
          final index = filteredData.keys.toList().indexOf(entry.key);
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data['amount'] ?? 0.0,
                color: Colors.blue,
                width: 8,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: data['spent'] ?? 0.0,
                color: Colors.orange,
                width: 8,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: (data['bicycle'] ?? 0.0) + (data['toys'] ?? 0.0),
                color: Colors.green,
                width: 8,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
            groupVertically: false,
          );
        }).toList(),
        groupsSpace: 12,
      ),
    );
  }

  // Helper method to calculate total saved for a month from all goals
  double _getTotalSavedForMonth(Map<String, double> monthData) {
    double totalSaved = 0.0;
    monthData.forEach((key, value) {
      if (key.startsWith('goal_')) {
        totalSaved += value;
      }
    });
    return totalSaved;
  }

  Widget _buildDetailedTable() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          'No data available for selected date range',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Get all unique goal names across all months
    final allGoalNames = <String>{};
    filteredData.values.forEach((monthData) {
      monthData.keys.where((key) => key.startsWith('goal_')).forEach((key) {
        allGoalNames.add(key.substring(5)); // Remove 'goal_' prefix
      });
    });

    return DataTable(
      columns: [
        DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Money Pocket', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Spent', style: TextStyle(fontWeight: FontWeight.bold))),
        ...allGoalNames.map((goalName) =>
          DataColumn(label: Text('$goalName Savings', style: TextStyle(fontWeight: FontWeight.bold)))),
        DataColumn(label: Text('Total Saved', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: filteredData.entries.map((entry) {
        final monthKey = entry.key;
        final data = entry.value;
        final date = DateTime.parse('$monthKey-01');
        final amount = data['amount'] ?? 0.0;
        final spent = data['spent'] ?? 0.0;

        // Calculate savings for each goal
        final goalSavings = <String, double>{};
        double totalSaved = 0.0;

        for (var goalName in allGoalNames) {
          final savings = data['goal_$goalName'] ?? 0.0;
          goalSavings[goalName] = savings;
          totalSaved += savings;
        }

        final remaining = amount - spent - totalSaved;

        return DataRow(cells: [
          DataCell(Text(DateFormat('MMM yyyy').format(date))),
          DataCell(Text('\$${amount.toStringAsFixed(2)}')),
          DataCell(Text('\$${spent.toStringAsFixed(2)}')),
          ...allGoalNames.map((goalName) =>
            DataCell(Text('\$${goalSavings[goalName]?.toStringAsFixed(2) ?? '0.00'}'))),
          DataCell(Text('\$${totalSaved.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
          DataCell(Text('\$${remaining.toStringAsFixed(2)}',
            style: TextStyle(
              color: remaining >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold
            ))),
        ]);
      }).toList(),
    );
  }

  Widget _buildSavingsBreakdown() {
    final filtered = _getFilteredData();
    final goalSavings = <String, double>{};

    // Collect savings for all goals across all months
    filtered.values.forEach((monthData) {
      monthData.forEach((key, value) {
        if (key.startsWith('goal_')) {
          final goalName = key.substring(5); // Remove 'goal_' prefix
          goalSavings[goalName] = (goalSavings[goalName] ?? 0.0) + value;
        }
      });
    });

    if (goalSavings.isEmpty || goalSavings.values.every((v) => v == 0)) {
      return Center(
        child: Text(
          'No savings data for selected date range',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final colors = [Colors.blue, Colors.purple, Colors.green, Colors.orange, Colors.red, Colors.teal];

    return Column(
      children: [
        Container(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: goalSavings.entries.where((entry) => entry.value > 0).map((entry) {
                final index = goalSavings.keys.toList().indexOf(entry.key);
                final color = colors[index % colors.length];
                return PieChartSectionData(
                  value: entry.value,
                  title: '${entry.key}\n\$${entry.value.toStringAsFixed(2)}',
                  color: color,
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 0,
            ),
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: goalSavings.entries.where((entry) => entry.value > 0).map((entry) {
            final index = goalSavings.keys.toList().indexOf(entry.key);
            final color = colors[index % colors.length];
            return _buildLegendItem(entry.key, color, entry.value);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double amount) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '$label: \$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Map<String, Map<String, double>> _getFilteredData() {
    final filtered = <String, Map<String, double>>{};
    widget.monypocketData.forEach((key, value) {
      final date = DateTime.parse('$key-01');
      if (date.isAfter(_selectedStartDate.subtract(Duration(days: 1))) &&
          date.isBefore(_selectedEndDate.add(Duration(days: 32)))) {
        filtered[key] = value;
      }
    });
    return filtered;
  }

  double _getTotalMoneyPocket() {
    final filtered = _getFilteredData();
    return filtered.values.fold(0.0, (sum, data) => sum + (data['amount'] ?? 0.0));
  }

  double _getTotalSpent() {
    final filtered = _getFilteredData();
    return filtered.values.fold(0.0, (sum, data) => sum + (data['spent'] ?? 0.0));
  }

  double _getTotalSaved() {
    final filtered = _getFilteredData();
    double totalSaved = 0.0;
    
    filtered.values.forEach((monthData) {
      monthData.forEach((key, value) {
        if (key.startsWith('goal_')) {
          totalSaved += value;
        }
      });
    });
    
    return totalSaved;
  }

  double _getTotalRemaining() {
    return _getTotalMoneyPocket() - _getTotalSpent() - _getTotalSaved();
  }

  double _getMaxValue(Map<String, Map<String, double>> data) {
    double max = 0.0;
    data.values.forEach((monthData) {
      final amount = monthData['amount'] ?? 0.0;
      final spent = monthData['spent'] ?? 0.0;
      
      // Calculate total saved for all goals
      double saved = 0.0;
      monthData.forEach((key, value) {
        if (key.startsWith('goal_')) {
          saved += value;
        }
      });
      
      max = [max, amount, spent, saved].reduce((a, b) => a > b ? a : b);
    });
    return max;
  }
}

class FirstTimeSetupScreen extends StatefulWidget {
  final Function(bool) onSetupComplete;

  const FirstTimeSetupScreen({Key? key, required this.onSetupComplete}) : super(key: key);

  @override
  _FirstTimeSetupScreenState createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool? _hasChildren;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_hasChildren == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select if you have children'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save user name and children preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setBool('has_children', _hasChildren!);
    await prefs.setBool('is_first_login', true); // Mark this as first login
    
    widget.onSetupComplete(_hasChildren!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Top section with branding - Compact
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Brand Name
                      Text(
                        'SmartCent',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Smart Money Management',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Let\'s get you set up in just two steps!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Two cards in a column (vertically stacked)
                Expanded(
                  child: Column(
                    children: [
                      // Name Card
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          width: double.infinity,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Your Name',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Help us personalize your experience',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: _nameController,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your name',
                                      hintStyle: TextStyle(fontSize: 14),
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Children Card
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          width: double.infinity,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.family_restroom,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Family Setup',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Do you have children?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _hasChildren = true;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.check_circle,
                                            size: 20,
                                            color: _hasChildren == true ? Colors.white : Theme.of(context).primaryColor,
                                          ),
                                          label: Text(
                                            'Yes',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _hasChildren == true ? Colors.white : Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _hasChildren == true ? Colors.green.shade600 : Colors.grey.shade200,
                                            foregroundColor: _hasChildren == true ? Colors.white : Theme.of(context).primaryColor,
                                            elevation: _hasChildren == true ? 3 : 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _hasChildren = false;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.person,
                                            size: 20,
                                            color: _hasChildren == false ? Colors.white : Theme.of(context).primaryColor,
                                          ),
                                          label: Text(
                                            'No',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _hasChildren == false ? Colors.white : Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _hasChildren == false ? Colors.indigo.shade600 : Colors.grey.shade200,
                                            foregroundColor: _hasChildren == false ? Colors.white : Theme.of(context).primaryColor,
                                            elevation: _hasChildren == false ? 3 : 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom section with complete button
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _completeSetup,
                          icon: Icon(Icons.check, color: Colors.white),
                          label: Text(
                            'Complete Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'You can always change these settings later',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FirstTimeSetupCheck extends StatefulWidget {
  final Widget child;

  const FirstTimeSetupCheck({Key? key, required this.child}) : super(key: key);

  @override
  _FirstTimeSetupCheckState createState() => _FirstTimeSetupCheckState();
}

class _FirstTimeSetupCheckState extends State<FirstTimeSetupCheck> {
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeStatus();
  }

  Future<void> _checkFirstTimeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedSetup = prefs.getBool('completed_first_time_setup') ?? false;
    
    setState(() {
      _isFirstTime = !hasCompletedSetup;
      _isLoading = false;
    });
  }

  Future<void> _completeSetup(bool hasChildren) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completed_first_time_setup', true);
    await prefs.setBool('has_children', hasChildren);
    
    setState(() {
      _isFirstTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_isFirstTime) {
      return FirstTimeSetupScreen(onSetupComplete: _completeSetup);
    }
    
    return widget.child;
  }
}

class SmartCentLogo extends StatelessWidget {
  final double size;
  
  const SmartCentLogo({
    Key? key, 
    this.size = 50,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 32,
      height: size + 32,
      child: CustomPaint(
        painter: SmartCentLogoPainter(),
        size: Size(size + 32, size + 32),
      ),
    );
  }
}

class SmartCentLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    
    // Create gradient background
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF00E5B8), // Bright cyan/teal
          Color(0xFF00BCD4), // Medium teal
          Color(0xFF0097A7), // Deep teal
          Color(0xFF006064), // Dark teal
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Draw main circle with gradient
    canvas.drawCircle(center, radius, gradientPaint);
    
    // Draw outer white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
    
    // Draw dashed outer circle
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    _drawDashedCircle(canvas, center, radius - 8, dashPaint);
    
    // Draw circuit patterns
    _drawCircuitPattern(canvas, center, radius);
    
    // Draw central dollar sign
    _drawDollarSign(canvas, center, size.width * 0.35);
  }
  
  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashCount = 24;
    const dashLength = 8.0;
    const gapLength = 4.0;
    
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * 3.14159) / dashCount;
      final endAngle = startAngle + (dashLength / (radius * 2));
      
      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
      );
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawCircuitPattern(Canvas canvas, Offset center, double mainRadius) {
    final circuitPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final nodePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    // Draw 8 circuit lines radiating from center
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final innerRadius = mainRadius * 0.4;
      final middleRadius = mainRadius * 0.65;
      final outerRadius = mainRadius * 0.85;
      
      // Inner line
      final innerStart = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final innerEnd = Offset(
        center.dx + middleRadius * cos(angle),
        center.dy + middleRadius * sin(angle),
      );
      
      canvas.drawLine(innerStart, innerEnd, circuitPaint);
      
      // Outer line
      final outerStart = Offset(
        center.dx + middleRadius * cos(angle),
        center.dy + middleRadius * sin(angle),
      );
      final outerEnd = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
      
      canvas.drawLine(outerStart, outerEnd, circuitPaint);
      
      // Circuit nodes
      canvas.drawCircle(innerEnd, 3, nodePaint);
      canvas.drawCircle(outerEnd, 4, nodePaint);
      
      // Additional small connecting lines for circuit board effect
      if (i % 2 == 0) {
        final sideAngle1 = angle + 0.3;
        final sideAngle2 = angle - 0.3;
        
        final side1 = Offset(
          center.dx + (middleRadius + 8) * cos(sideAngle1),
          center.dy + (middleRadius + 8) * sin(sideAngle1),
        );
        final side2 = Offset(
          center.dx + (middleRadius + 8) * cos(sideAngle2),
          center.dy + (middleRadius + 8) * sin(sideAngle2),
        );
        
        canvas.drawLine(outerStart, side1, circuitPaint);
        canvas.drawLine(outerStart, side2, circuitPaint);
        canvas.drawCircle(side1, 2, nodePaint);
        canvas.drawCircle(side2, 2, nodePaint);
      }
    }
  }
  
  void _drawDollarSign(Canvas canvas, Offset center, double dollarSize) {
    final dollarPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = dollarSize * 0.12
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Draw dollar sign path
    final path = Path();
    final halfWidth = dollarSize * 0.25;
    final halfHeight = dollarSize * 0.4;
    
    // Top curve
    path.moveTo(center.dx + halfWidth, center.dy - halfHeight * 0.6);
    path.quadraticBezierTo(
      center.dx + halfWidth, center.dy - halfHeight,
      center.dx, center.dy - halfHeight,
    );
    path.quadraticBezierTo(
      center.dx - halfWidth, center.dy - halfHeight,
      center.dx - halfWidth, center.dy - halfHeight * 0.3,
    );
    
    // Middle section
    path.lineTo(center.dx + halfWidth * 0.7, center.dy);
    
    // Bottom curve
    path.quadraticBezierTo(
      center.dx + halfWidth, center.dy + halfHeight * 0.3,
      center.dx + halfWidth, center.dy + halfHeight,
    );
    path.quadraticBezierTo(
      center.dx + halfWidth, center.dy + halfHeight,
      center.dx, center.dy + halfHeight,
    );
    path.quadraticBezierTo(
      center.dx - halfWidth, center.dy + halfHeight,
      center.dx - halfWidth, center.dy + halfHeight * 0.6,
    );
    
    canvas.drawPath(path, dollarPaint);
    
    // Vertical line through dollar sign
    canvas.drawLine(
      Offset(center.dx, center.dy - halfHeight * 1.2),
      Offset(center.dx, center.dy + halfHeight * 1.2),
      dollarPaint,
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

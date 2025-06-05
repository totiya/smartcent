import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'test_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isPasswordProtected = false;
  bool _isNotificationsEnabled = false;
  bool _hasChildren = true;
  String? _password;

  @override
  void initState() {
    super.initState();
    print('SETTINGS SCREEN: initState called - Settings screen is loading');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _isPasswordProtected = prefs.getBool('password_protection') ?? false;
      _isNotificationsEnabled = prefs.getBool('notifications') ?? false;
      _hasChildren = prefs.getBool('has_children') ?? true;
      _password = prefs.getString('password');
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('password_protection', _isPasswordProtected);
    await prefs.setBool('notifications', _isNotificationsEnabled);
    await prefs.setBool('has_children', _hasChildren);
    if (_password != null) {
      await prefs.setString('password', _password!);
    }
  }

  Future<void> _showPasswordDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Enter Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _password = controller.text;
                _isPasswordProtected = true;
              });
              _saveSettings();
              Navigator.pop(context);
            },
            child: Text('Set'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChildrenSettingDialog(bool value) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(value ? 'Enable Kids Mode?' : 'Disable Kids Mode?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value 
              ? 'Great! Kids Mode will be enabled. You can start managing allowances and savings goals for your child.'
              : 'Kids Mode will be disabled and hidden from the home screen. You can focus on personal budgeting only.'
            ),
            SizedBox(height: 16),
            Text(
              'You will be taken to the home screen to see the updated interface.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _hasChildren = value;
              });
              await _saveSettings();
              Navigator.pop(context); // Close dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value 
                    ? 'Great! Kids Mode is now enabled. You can start managing allowances and savings goals for your child.'
                    : 'Kids Mode has been disabled. The home screen now focuses on personal budgeting.'
                  ),
                  backgroundColor: value ? Colors.green : Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              
              // Navigate back to home screen to show updated interface
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceFrame(
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
                ),
                (route) => false, // Remove all previous routes
              );
            },
            child: Text(value ? 'Enable' : 'Disable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Global Settings'),
            Text(
              'Affects both Family Mode & Kids Mode',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Test Navigation Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                print('BUTTON TEST: Navigation button pressed!');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestScreen(),
                  ),
                );
              },
              child: Text('TEST NAVIGATION BUTTON'),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                // Theme Settings
                _buildSection(
                  title: 'Appearance',
                  icon: Icons.palette,
                  children: [
                    SwitchListTile(
                      title: Text('Dark Mode'),
                      subtitle: Text('Switch between light and dark theme'),
                      secondary: Icon(Icons.dark_mode),
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                        _saveSettings();
                      },
                    ),
                  ],
                ),
                
                // User Profile Settings
                _buildSection(
                  title: 'User Profile',
                  icon: Icons.person,
                  children: [
                    ListTile(
                      leading: Icon(Icons.family_restroom),
                      title: Text('Do you have children?'),
                      subtitle: Text('Controls access to Kids Mode features'),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _hasChildren ? 'Yes' : 'No',
                          underline: SizedBox(), // Remove default underline
                          items: ['No', 'Yes'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    value == 'Yes' ? Icons.check_circle : Icons.cancel,
                                    color: value == 'Yes' ? Colors.green : Colors.grey,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              bool newHasChildren = newValue == 'Yes';
                              if (newHasChildren != _hasChildren) {
                                _showChildrenSettingDialog(newHasChildren);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Security Settings
                _buildSection(
                  title: 'Security',
                  icon: Icons.security,
                  children: [
                    SwitchListTile(
                      title: Text('Password Protection'),
                      subtitle: Text('Require password to open app'),
                      secondary: Icon(Icons.lock),
                      value: _isPasswordProtected,
                      onChanged: (value) {
                        if (value && _password == null) {
                          _showPasswordDialog();
                        } else {
                          setState(() {
                            _isPasswordProtected = value;
                          });
                          _saveSettings();
                        }
                      },
                    ),
                    if (_isPasswordProtected)
                      ListTile(
                        leading: Icon(Icons.password),
                        title: Text('Change Password'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: _showPasswordDialog,
                      ),
                  ],
                ),

                // Notification Settings
                _buildSection(
                  title: 'Notifications',
                  icon: Icons.notifications,
                  children: [
                    SwitchListTile(
                      title: Text('Enable Notifications'),
                      subtitle: Text('Receive alerts and reminders'),
                      secondary: Icon(Icons.notifications_active),
                      value: _isNotificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isNotificationsEnabled = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),

                // About Section
                _buildSection(
                  title: 'About',
                  icon: Icons.info,
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('App Version'),
                      trailing: Text('1.0.0'),
                    ),
                    ListTile(
                      leading: Icon(Icons.bug_report),
                      title: Text('Test Navigation'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        print('Test navigation tapped!');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TestScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text('Terms of Service'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        print('Terms of Service tapped!');
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsOfServiceScreen(),
                            ),
                          );
                          print('Terms of Service navigation completed');
                        } catch (e) {
                          print('Error navigating to Terms of Service: $e');
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.privacy_tip),
                      title: Text('Privacy Policy'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        print('Privacy Policy tapped!');
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                          print('Privacy Policy navigation completed');
                        } catch (e) {
                          print('Error navigating to Privacy Policy: $e');
                        }
                      },
                    ),
                  ],
                ),
                _buildSettingItem(
                  'Family Mode',
                  'Toggle between personal and family budgeting',
                  Icons.family_restroom,
                  () => _showFamilyModeDialog(),
                ),
                _buildSettingItem(
                  'Reset App Setup',
                  'Clear all data and restart initial setup',
                  Icons.refresh,
                  () => _showResetDialog(),
                ),
                _buildSettingItem(
                  'Test First-Time Flow',
                  'Test the complete first-time user experience',
                  Icons.play_arrow,
                  () => _testFirstTimeFlow(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        ...children,
        Divider(),
      ],
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right),
      onTap: onPressed,
    );
  }

  Future<void> _showFamilyModeDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Family Mode'),
        content: Text('Do you have children and want to enable family budgeting features?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_children', true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Family Mode enabled!')),
              );
            },
            child: Text('Enable'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_children', false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Personal Mode enabled!')),
              );
            },
            child: Text('Disable'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset App Setup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will clear all your data and restart the initial setup process.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to continue?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
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
              // Clear all stored data
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // This clears everything
              
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('App data cleared! Restarting setup...'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Navigate back to initial setup
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceFrame(
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
                ),
                (route) => false, // Remove all previous routes
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _testFirstTimeFlow() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test First-Time Flow'),
        content: Text('This will clear all setup data and restart the app as if it\'s the first time running. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              
              // Clear all setup-related data
              await prefs.remove('password');
              await prefs.remove('user_email');
              await prefs.remove('user_name');
              await prefs.remove('completed_first_time_setup');
              await prefs.remove('has_children');
              await prefs.remove('password_protection');
              await prefs.remove('is_first_login');
              
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('App data cleared! Please restart the app to test first-time flow.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: Text('Clear & Test'),
          ),
        ],
      ),
    );
  }
} 
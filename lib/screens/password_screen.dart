import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';  // Import main.dart to access FamilyMode and KidsMode

class PasswordScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PasswordScreen({Key? key, required this.onSuccess}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isPasswordCorrect = true;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setSource(AssetSource('sounds/alarm.mp3'));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPassword = prefs.getString('password');
      
      if (savedPassword == null || savedPassword.isEmpty) {
        // First time setup - save the password
        await prefs.setString('password', _passwordController.text);
        await prefs.setBool('password_protection', true);
        widget.onSuccess();
      } else if (_passwordController.text == savedPassword) {
        widget.onSuccess();
      } else {
        setState(() {
          _isPasswordCorrect = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error verifying password';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showModeSelectionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Select Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.family_restroom),
              title: Text('Family Mode'),
              subtitle: Text('Manage family expenses and budgets'),
              onTap: () {
                Navigator.pop(context);
                widget.onSuccess();
                // Navigate to Family Mode
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyMode()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.child_care),
              title: Text('Kids Mode'),
              subtitle: Text('Track kids\' allowances and savings'),
              onTap: () {
                Navigator.pop(context);
                widget.onSuccess();
                // Navigate to Kids Mode
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DeviceFrame(
                    child: ChildSelectionScreen(),
                  )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final TextEditingController emailController = TextEditingController();
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Reset Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your email address to reset your password:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    errorText: errorMessage,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                
                if (email.isEmpty) {
                  setState(() {
                    errorMessage = 'Please enter your email';
                  });
                  return;
                }

                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                  setState(() {
                    errorMessage = 'Please enter a valid email';
                  });
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final savedEmail = prefs.getString('user_email');

                if (savedEmail == null) {
                  // If no email is set, set it now
                  await prefs.setString('user_email', email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email registered successfully. Please check your email for password reset instructions.')),
                  );
                  return;
                }

                if (email.toLowerCase() != savedEmail.toLowerCase()) {
                  setState(() {
                    errorMessage = 'Email not found';
                  });
                  return;
                }

                // Show success message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password reset instructions have been sent to your email')),
                );

                // Show new password dialog
                _showNewPasswordDialog();
              },
              child: Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNewPasswordDialog() async {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Set New Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                    errorText: errorMessage,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newPasswordController.text.isEmpty) {
                  setState(() {
                    errorMessage = 'New password cannot be empty';
                  });
                  return;
                }

                if (newPasswordController.text != confirmPasswordController.text) {
                  setState(() {
                    errorMessage = 'Passwords do not match';
                  });
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('password', newPasswordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password has been reset successfully')),
                );
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
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
                  // App Logo/Icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your password to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onSubmitted: (_) => _verifyPassword(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[100],
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // Unlock Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Text(
                              'Unlock',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Forgot Password Button
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
} 
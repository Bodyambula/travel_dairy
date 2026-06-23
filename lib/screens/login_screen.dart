import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/AuthWidget.dart';
import '../utils/AppStrings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseAnalytics? analytics;

  const LoginScreen({super.key, this.auth, this.analytics});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final FirebaseAuth _auth;
  late final FirebaseAnalytics _analytics;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? FirebaseAuth.instance;
    _analytics = widget.analytics ?? FirebaseAnalytics.instance;
  }

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppStrings strings) {
    if (value == null || value.isEmpty) {
      return strings.errorEmailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return strings.errorEmailInvalid;
    }

    return null;
  }

  String? _validatePassword(String? value, AppStrings strings) {
    if (value == null || value.isEmpty) {
      return strings.errorPasswordRequired;
    }

    if (value.length < 6) {
      return strings.errorPasswordTooShort;
    }

    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('APP_LOG: _signIn() started');
      final strings = AppStrings.of(context, listen: false);
      
      print('APP_LOG: Attempting to sign in with email: ${_emailController.text.trim()}');
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        print('APP_LOG: signInWithEmailAndPassword timed out after 15s');
        throw FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Connection timed out',
        );
      });

      print('APP_LOG: Sign in successful. Logging analytics...');
      try {
        _analytics.logLogin(loginMethod: 'email_password');
        _analytics.setUserId(id: _auth.currentUser?.uid);
      } catch (analyticsError) {
        print('APP_LOG: Analytics error (non-fatal): $analyticsError');
      }

      if (mounted) {
        print('APP_LOG: Navigating to /home');
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      print('APP_LOG: FirebaseAuthException: ${e.code} - ${e.message}');
      final strings = AppStrings.of(context, listen: false); // Get strings again in catch if needed
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = strings.errorUserNotFound;
          break;
        case 'wrong-password':
          errorMessage = strings.errorWrongPassword;
          break;
        case 'invalid-email':
          errorMessage = strings.errorInvalidEmail;
          break;
        case 'user-disabled':
          errorMessage = strings.errorUserDisabled;
          break;
        case 'too-many-requests':
          errorMessage = strings.errorTooManyRequests;
          break;
        case 'network-request-failed':
          errorMessage = strings.errorNetworkFailed;
          break;
        default:
          errorMessage = '${strings.errorLoginGeneric} ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('APP_LOG: Unexpected error during sign in: $e');
      final strings = AppStrings.of(context, listen: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorUnexpected} $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      print('APP_LOG: _signIn() finally block');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final strings = AppStrings.of(context, listen: false);

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.passwordResetEmailRequired),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.passwordResetSent),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = strings.errorUserNotFound;
      } else if (e.code == 'invalid-email') {
        errorMessage = strings.errorInvalidEmail;
      } else {
        errorMessage = '${strings.errorUnexpected} ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AuthHeader(
            title: strings.loginTitle,
            subtitle: strings.loginSubtitle,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.emailLabel,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => _validateEmail(val, strings),
                      decoration: InputDecoration(
                        hintText: strings.emailHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      strings.passwordLabel,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (val) => _validatePassword(val, strings),
                      decoration: InputDecoration(
                        hintText: strings.passwordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: Text(
                          strings.forgotPassword,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(strings.loginButton),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          strings.noAccount,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pushNamed(context, '/registration');
                                },
                          child: Text(
                            strings.registerLink,
                            style: const TextStyle(
                              color: Color(0xFF1A56DB),
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}


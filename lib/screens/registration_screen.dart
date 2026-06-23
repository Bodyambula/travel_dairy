import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/AuthWidget.dart';
import '../utils/AppStrings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class RegistrationScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseAnalytics? analytics;

  const RegistrationScreen({
    super.key,
    this.auth,
    this.analytics,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
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
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, AppStrings strings) {
    if (value == null || value.isEmpty) {
      return strings.errorNameRequired;
    }

    if (value.length < 2) {
      return strings.errorNameTooShort;
    }

    if (value.contains(RegExp(r'[0-9]'))) {
      return strings.errorNameWithNumbers;
    }

    return null;
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

    if (!value.contains(RegExp(r'[0-9]'))) {
      return strings.errorPasswordNoDigit;
    }

    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return strings.errorPasswordNoLetter;
    }

    return null;
  }

  String? _validateConfirmPassword(String? value, AppStrings strings) {
    if (value == null || value.isEmpty) {
      return strings.errorConfirmPasswordRequired;
    }

    if (value != _passwordController.text) {
      return strings.errorPasswordMismatch;
    }

    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('APP_LOG: _signUp() started');
      final strings = AppStrings.of(context, listen: false);
      
      print('APP_LOG: Attempting to create user with email: ${_emailController.text.trim()}');
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ).timeout(const Duration(seconds: 15), onTimeout: () {
            print('APP_LOG: createUserWithEmailAndPassword timed out after 15s');
            throw FirebaseAuthException(
              code: 'network-request-failed',
              message: 'Registration timed out',
            );
          });

      print('APP_LOG: Registration successful. Updating profile...');
      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      print('APP_LOG: Profile updated. Sending verification email...');
      userCredential.user?.sendEmailVerification();

      print('APP_LOG: Logging analytics...');
      try {
        _analytics.logSignUp(
          signUpMethod: 'email_password',
        );
      } catch (analyticsError) {
        print('APP_LOG: Analytics error (non-fatal): $analyticsError');
      }

      if (mounted) {
        print('APP_LOG: Showing success SnackBar and navigating');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.registrationSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      print('APP_LOG: FirebaseAuthException during sign up: ${e.code} - ${e.message}');
      final strings = AppStrings.of(context, listen: false);
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = strings.errorEmailInUse;
          break;
        case 'invalid-email':
          errorMessage = strings.errorInvalidEmail;
          break;
        case 'operation-not-allowed':
          errorMessage = strings.errorOperationNotAllowed;
          break;
        case 'weak-password':
          errorMessage = strings.errorWeakPassword;
          break;
        case 'network-request-failed':
          errorMessage = strings.errorNetworkFailed;
          break;
        default:
          errorMessage = '${strings.errorRegistrationGeneric} ${e.message}';
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
      print('APP_LOG: Unexpected error during sign up: $e');
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
      print('APP_LOG: _signUp() finally block');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
            title: strings.registrationTitle,
            subtitle: strings.registrationSubtitle,
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
                      strings.nameLabel,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      validator: (val) => _validateName(val, strings),
                      decoration: InputDecoration(
                        hintText: strings.nameHint,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

                    Text(
                      strings.confirmPasswordLabel,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: (val) => _validateConfirmPassword(val, strings),
                      decoration: InputDecoration(
                        hintText: strings.passwordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(strings.registerButton),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          strings.haveAccount,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Text(
                            strings.loginLink,
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


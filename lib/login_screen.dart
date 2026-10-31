import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _busy = false; // true while waiting for Firebase
  bool _isSignUp = false; // false = Log in mode, true = Create account mode
  bool _hidePassword = true; // eye icon: hide or show the password
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _error = null;
      _confirm.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (_isSignUp) {
        await auth.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _password.text);
        await addSampleCourses();
      } else {
        await auth.signInWithEmailAndPassword(
            email: _email.text.trim(), password: _password.text);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _message(e.code));
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Log in instead.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Wrong email or password.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong ($code).';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo circle
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: sageDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_month,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 16),
                  const Text('My Week',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: sageDark)),
                  const SizedBox(height: 4),
                  Text(
                    _isSignUp
                        ? 'Create your account'
                        : 'Welcome back, log in to see your week',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // White card with the form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 4)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: pageBg,
                            ),
                            validator: (v) {
                              final email = (v ?? '').trim();
                              if (email.isEmpty) return 'Enter your email';
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(email)) {
                                return 'Enter a valid email, like aline@gmail.com';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: pageBg,
                              suffixIcon: IconButton(
                                icon: Icon(_hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword),
                              ),
                            ),
                            validator: (v) => (v ?? '').length < 6
                                ? 'At least 6 characters'
                                : null,
                          ),

                          // Confirm box: only shown when creating an account
                          if (_isSignUp) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirm,
                              obscureText: _hidePassword,
                              decoration: const InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon: Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: pageBg,
                              ),
                              validator: (v) => v != _password.text
                                  ? 'Passwords do not match'
                                  : null,
                            ),
                          ],

                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text(_error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w600)),
                            ),
                          const SizedBox(height: 20),

                          FilledButton(
                            onPressed: _busy ? null : _submit,
                            child: _busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: Colors.white),
                                  )
                                : Text(_isSignUp ? 'Create account' : 'Log in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Switch between the two modes
                  TextButton(
                    onPressed: _busy ? null : _toggleMode,
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Log in'
                          : "Don't have an account? Create one",
                      style: const TextStyle(color: sageDark),
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

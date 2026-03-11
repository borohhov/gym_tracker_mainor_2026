import 'package:flutter/material.dart';
import 'package:gym_tracker/controllers/auth_provider.dart';
import 'package:gym_tracker/controllers/exercise_log_provider.dart';
import 'package:provider/provider.dart';

class AuthSheet extends StatefulWidget {
  const AuthSheet({super.key});

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final logProvider = context.read<ExerciseLogProvider>();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        await authProvider.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await authProvider.register(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      final user = authProvider.currentUser;
      if (user != null) {
        await logProvider.useAuthenticatedMode(user.uid);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.mapFirebaseAuthError(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter email';
    if (!email.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return 'Enter password';
    if (password.length < 6) return 'Minimum 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLoginMode ? 'Sign in' : 'Create account',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(_isLoginMode ? 'Sign in' : 'Register'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: Text(
                  _isLoginMode
                      ? 'No account? Register'
                      : 'Already have an account? Sign in',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
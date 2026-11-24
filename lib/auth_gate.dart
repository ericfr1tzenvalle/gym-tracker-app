import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_shell.dart';
import 'widgets/app_logo.dart';
import 'widgets/glass_surface.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        return user == null
            ? const LoginPage()
            : AppShell(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creating = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_loading || !_form.currentState!.validate()) return;
    final creating = _creating;
    final email = _email.text.trim();
    final password = _password.text;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (creating) {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error.code) {
          'invalid-email' => 'Enter a valid email address.',
          'email-already-in-use' =>
            'This email already has an account. Sign in instead.',
          'weak-password' => 'Choose a stronger password.',
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' => 'Invalid email or password.',
          'network-request-failed' =>
            'Check your internet connection and try again.',
          'too-many-requests' => 'Too many attempts. Try again later.',
          'operation-not-allowed' =>
            'Email and password authentication is unavailable.',
          _ =>
            creating ? 'Could not create your account.' : 'Could not sign in.',
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchMode() {
    final email = _email.text;
    _form.currentState?.reset();
    _email.text = email;
    _password.clear();
    setState(() {
      _creating = !_creating;
      _error = null;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = _creating ? 'Create Account' : 'Sign In';
    return Scaffold(
      appBar: GlassAppBar(title: const AppLogo()),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              children: [
                GlassSurface(
                  radius: 22,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AutofillGroup(
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              action,
                              style: const TextStyle(
                                fontFamily: 'MatchaMint',
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _email,
                              enabled: !_loading,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) => (value ?? '').trim().isEmpty
                                  ? 'Enter your email address.'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              enabled: !_loading,
                              obscureText: true,
                              autofillHints: [
                                _creating
                                    ? AutofillHints.newPassword
                                    : AutofillHints.password,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) {
                                if ((value ?? '').isEmpty) {
                                  return 'Enter your password.';
                                }
                                if (_creating && value!.length < 6) {
                                  return 'Use at least 6 characters.';
                                }
                                return null;
                              },
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: _loading ? null : _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: _loading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(action),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loading ? null : _switchMode,
                  child: Text(
                    _creating
                        ? 'Already have an account? Sign In'
                        : 'New to LilGym? Create Account',
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

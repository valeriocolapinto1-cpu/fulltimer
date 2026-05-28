import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Email sign-up / sign-in dialog for Supabase Auth
class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});
  @override State<AuthDialog> createState() => _AuthState();
}

class _AuthState extends State<AuthDialog> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _signUp = false;
  bool _loading = false;
  String? _error;

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_signUp) {
        await SupabaseService().signUp(_email.text.trim(), _pass.text);
      } else {
        await SupabaseService().signIn(_email.text.trim(), _pass.text);
      }
      if (mounted) Navigator.pop(context, true);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_signUp ? 'Crea account' : 'Accedi',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pass,
            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: th.colorScheme.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_signUp ? 'Registrati' : 'Accedi'),
          )),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() { _signUp = !_signUp; _error = null; }),
            child: Text(_signUp ? 'Hai già un account? Accedi' : 'Non hai un account? Registrati'),
          ),
        ]),
      ),
    );
  }
}

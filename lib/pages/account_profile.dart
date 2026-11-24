import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/account_database.dart';

class AccountProfile {
  const AccountProfile(
    this.username,
    this.weight,
    this.height,
    this.goal,
    this.portrait,
  );
  final String username;
  final double weight;
  final double height;
  final int goal;
  final int portrait;

  static Future<AccountProfile?> load(AccountDatabase store) async {
    final row = (await store.rows('profiles')).firstOrNull;
    if (row == null) return null;
    return AccountProfile(
      row['username'] as String,
      (row['weight'] as num).toDouble(),
      (row['height'] as num).toDouble(),
      row['goal'] as int,
      row['portrait'] as int,
    );
  }

  Future<void> save(AccountDatabase store) => store.db.rawInsert(
    'INSERT OR REPLACE INTO profiles (uid, username, weight, height, goal, portrait) VALUES (?, ?, ?, ?, ?, ?)',
    [store.uid, username, weight, height, goal, portrait],
  );

  AccountProfile withPortrait(int index) =>
      AccountProfile(username, weight, height, goal, index);
}

class ProfilePortrait extends StatelessWidget {
  const ProfilePortrait(this.index, {super.key, this.radius = 28});
  final int index;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'lib/assets/portraits/portrait-$index.jpg',
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) =>
          CircleAvatar(radius: radius, child: const Icon(Icons.person)),
    ),
  );
}

class PortraitChoices extends StatelessWidget {
  const PortraitChoices({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: List.generate(
      4,
      (index) => Semantics(
        selected: index == selected,
        button: true,
        label: 'Retrato ${index + 1}',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onSelect(index),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: index == selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ProfilePortrait(index),
          ),
        ),
      ),
    ),
  );
}

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key, required this.onSave});
  final Future<void> Function(AccountProfile) onSave;

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _goal = TextEditingController(text: '3');
  int _portrait = 0;
  bool _saving = false;

  double? _number(String? text) =>
      double.tryParse((text ?? '').trim().replaceAll(',', '.'));

  @override
  void dispose() {
    for (final controller in [_name, _weight, _height, _goal]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        AccountProfile(
          _name.text.trim(),
          _number(_weight.text)!,
          _number(_height.text)!,
          int.parse(_goal.text.trim()),
          _portrait,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar o perfil.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _measurement(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        validator: (text) {
          final number = _number(text);
          return number == null || !number.isFinite || number <= 0
              ? 'Informe um valor maior que zero.'
              : null;
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Monte seu perfil')),
    body: SafeArea(
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome de usuário'),
              validator: (text) => (text ?? '').trim().isEmpty
                  ? 'Informe seu nome de usuário.'
                  : null,
            ),
            _measurement(_weight, 'Peso (kg)'),
            _measurement(_height, 'Altura (cm)'),
            TextFormField(
              controller: _goal,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Meta de treinos por semana',
              ),
              validator: (text) => (int.tryParse((text ?? '').trim()) ?? 0) <= 0
                  ? 'Informe um número inteiro positivo.'
                  : null,
            ),
            const SizedBox(height: 20),
            const Text('Escolha seu retrato'),
            PortraitChoices(
              selected: _portrait,
              onSelect: (index) => setState(() => _portrait = index),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Salvando…' : 'Continuar'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({
    super.key,
    required this.profile,
    required this.onSave,
  });
  final AccountProfile profile;
  final Future<void> Function(AccountProfile) onSave;

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  bool _busy = false;

  Future<void> _run(Future<String?> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    String? message;
    try {
      message = await action();
    } on FirebaseAuthException catch (error) {
      message = switch (error.code) {
        'invalid-email' => 'Informe um e-mail válido.',
        'wrong-password' || 'invalid-credential' => 'Senha atual incorreta.',
        'weak-password' => 'Escolha uma senha mais forte.',
        'email-already-in-use' => 'Este e-mail já está em uso.',
        'network-request-failed' => 'Conecte-se à internet e tente novamente.',
        _ => 'Não foi possível atualizar a conta.',
      };
    } catch (_) {
      message = 'Não foi possível concluir a ação.';
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    }
  }

  Future<void> _changeCredential({required bool email}) => _run(() async {
    final user = FirebaseAuth.instance.currentUser;
    final currentEmail = user?.email;
    if (user == null || currentEmail == null) {
      return 'Entre novamente para atualizar sua conta.';
    }
    var currentPassword = '';
    var newValue = '';
    final form = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(email ? 'Trocar e-mail' : 'Trocar senha'),
        scrollable: true,
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha atual'),
                onChanged: (value) => currentPassword = value,
                validator: (value) =>
                    (value ?? '').isEmpty ? 'Informe sua senha atual.' : null,
              ),
              TextFormField(
                obscureText: !email,
                keyboardType: email
                    ? TextInputType.emailAddress
                    : TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: email ? 'Novo e-mail' : 'Nova senha',
                ),
                onChanged: (value) => newValue = value,
                validator: (value) => email
                    ? ((value ?? '').trim().contains('@')
                          ? null
                          : 'Informe um e-mail válido.')
                    : ((value ?? '').length >= 6
                          ? null
                          : 'Use pelo menos 6 caracteres.'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return null;
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: currentEmail,
        password: currentPassword,
      ),
    );
    if (email) {
      await user.verifyBeforeUpdateEmail(newValue.trim());
      return 'Abra o link enviado ao novo e-mail para confirmar a troca.';
    }
    await user.updatePassword(newValue);
    return 'Senha atualizada.';
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
    children: [
      Center(child: ProfilePortrait(widget.profile.portrait, radius: 52)),
      const SizedBox(height: 12),
      Center(
        child: Text(
          widget.profile.username,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: const Text('Trocar retrato'),
        enabled: !_busy,
        onTap: () => _run(() async {
          final index = await showDialog<int>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Escolha seu retrato'),
              content: PortraitChoices(
                selected: widget.profile.portrait,
                onSelect: (index) => Navigator.pop(context, index),
              ),
            ),
          );
          if (mounted && index != null) {
            await widget.onSave(widget.profile.withPortrait(index));
          }
          return null;
        }),
      ),
      ListTile(
        leading: const Icon(Icons.email_outlined),
        title: const Text('Trocar e-mail'),
        enabled: !_busy,
        onTap: () => _changeCredential(email: true),
      ),
      ListTile(
        leading: const Icon(Icons.lock_outline),
        title: const Text('Trocar senha'),
        enabled: !_busy,
        onTap: () => _changeCredential(email: false),
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        enabled: !_busy,
        onTap: () => _run(() async {
          await FirebaseAuth.instance.signOut();
          return null;
        }),
      ),
    ],
  );
}

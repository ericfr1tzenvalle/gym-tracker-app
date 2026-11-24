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
}

class ProfilePortrait extends StatelessWidget {
  const ProfilePortrait(this.index, {super.key, this.radius = 28});
  final int index;
  final double radius;

  static const count = 8;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'lib/assets/portraits/portrait-$index.jpg',
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) =>
          CircleAvatar(radius: radius, child: const Icon(Icons.person)),
    );
    return ClipOval(child: image);
  }
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
      ProfilePortrait.count,
      (index) => Semantics(
        selected: index == selected,
        button: true,
        label: 'Portrait ${index + 1}',
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
          const SnackBar(content: Text('Could not save the profile.')),
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
              ? 'Enter a number greater than zero.'
              : null;
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Set Up Your Profile')),
    body: SafeArea(
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (text) =>
                  (text ?? '').trim().isEmpty ? 'Enter a username.' : null,
            ),
            _measurement(_weight, 'Weight (kg)'),
            _measurement(_height, 'Height (cm)'),
            TextFormField(
              controller: _goal,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weekly workout goal',
              ),
              validator: (text) => (int.tryParse((text ?? '').trim()) ?? 0) <= 0
                  ? 'Enter a positive whole number.'
                  : null,
            ),
            const SizedBox(height: 20),
            const Text('Choose your portrait'),
            PortraitChoices(
              selected: _portrait,
              onSelect: (index) => setState(() => _portrait = index),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Continue'),
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
        'invalid-email' => 'Enter a valid email address.',
        'wrong-password' ||
        'invalid-credential' => 'Incorrect current password.',
        'weak-password' => 'Choose a stronger password.',
        'email-already-in-use' => 'This email address is already in use.',
        'network-request-failed' => 'Connect to the internet and try again.',
        _ => 'Could not update the account.',
      };
    } catch (_) {
      message = 'Could not complete the action.';
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
      return 'Sign in again to update your account.';
    }
    var currentPassword = '';
    var newValue = '';
    final form = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(email ? 'Change Email' : 'Change Password'),
        scrollable: true,
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
                onChanged: (value) => currentPassword = value,
                validator: (value) => (value ?? '').isEmpty
                    ? 'Enter your current password.'
                    : null,
              ),
              TextFormField(
                obscureText: !email,
                keyboardType: email
                    ? TextInputType.emailAddress
                    : TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: email ? 'New email' : 'New password',
                ),
                onChanged: (value) => newValue = value,
                validator: (value) => email
                    ? ((value ?? '').trim().contains('@')
                          ? null
                          : 'Enter a valid email address.')
                    : ((value ?? '').length >= 6
                          ? null
                          : 'Use at least 6 characters.'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Confirm'),
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
      return 'Open the link sent to your new email address to confirm the change.';
    }
    await user.updatePassword(newValue);
    return 'Current passwordizada.';
  });

  Future<void> _editMeasurements() => _run(() async {
    final profile = widget.profile;
    var weight = profile.weight;
    var height = profile.height;
    final form = GlobalKey<FormState>();
    Widget field(String label, double initial, ValueChanged<double> save) =>
        TextFormField(
          initialValue: initial.toString(),
          decoration: InputDecoration(labelText: label),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (text) {
            final value = double.tryParse(
              (text ?? '').trim().replaceAll(',', '.'),
            );
            return value == null || !value.isFinite || value <= 0
                ? 'Enter a number greater than zero.'
                : null;
          },
          onSaved: (text) =>
              save(double.parse(text!.trim().replaceAll(',', '.'))),
        );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Measurements'),
        scrollable: true,
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field('Weight (kg)', weight, (value) => weight = value),
              field('Height (cm)', height, (value) => height = value),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              form.currentState!.save();
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return null;
    await widget.onSave(
      AccountProfile(
        profile.username,
        weight,
        height,
        profile.goal,
        profile.portrait,
      ),
    );
    return 'Measurements updated.';
  });

  Future<void> _changePortrait() => _run(() async {
    final profile = widget.profile;
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Portrait'),
        scrollable: true,
        content: PortraitChoices(
          selected: profile.portrait,
          onSelect: (index) => Navigator.pop(context, index),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (!mounted || selected == null || selected == profile.portrait) {
      return null;
    }
    await widget.onSave(
      AccountProfile(
        profile.username,
        profile.weight,
        profile.height,
        profile.goal,
        selected,
      ),
    );
    return 'Portrait updated.';
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
    children: [
      Center(child: ProfilePortrait(widget.profile.portrait, radius: 52)),
      const SizedBox(height: 12),
      Text(
        widget.profile.username,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: const Text('Change Portrait'),
        enabled: !_busy,
        onTap: _changePortrait,
      ),
      ListTile(
        leading: const Icon(Icons.straighten),
        title: const Text('Edit Measurements'),
        enabled: !_busy,
        onTap: _editMeasurements,
      ),
      ListTile(
        leading: const Icon(Icons.email_outlined),
        title: const Text('Change Email'),
        enabled: !_busy,
        onTap: () => _changeCredential(email: true),
      ),
      ListTile(
        leading: const Icon(Icons.lock_outline),
        title: const Text('Change Password'),
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

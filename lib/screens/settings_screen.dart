import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notification_helper.dart';
import '../theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final (enabled, h, m) = await NotifHelper.prefs();
    setState(() {
      _enabled = enabled;
      _time = TimeOfDay(hour: h, minute: m);
    });
    if (enabled) _ctrl.forward();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) {
      setState(() => _time = t);
      await NotifHelper.scheduleDaily(t.hour, t.minute);
    }
  }

  Future<void> _toggleNotif(bool value) async {
    setState(() => _enabled = value);
    if (value) {
      _ctrl.forward();
      await NotifHelper.scheduleDaily(_time.hour, _time.minute);
    } else {
      _ctrl.reverse();
      await NotifHelper.disable();
    }
  }

  String _themeLabel(BuildContext ctx) {
    final mode = ctx.read<ThemeNotifier>().mode;
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      default:
        return 'Système';
    }
  }

  void _cycleTheme() {
    context.read<ThemeNotifier>().nextMode();
    setState(() {}); // rafraîchir le label
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: Hero(
          tag: 'settings',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile.adaptive(
              value: _enabled,
              title: const Text('Notification quotidienne'),
              onChanged: _toggleNotif,
            ),
            SizeTransition(
              sizeFactor:
                  CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
              axisAlignment: -1,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Heure'),
                    subtitle: Text(_time.format(context)),
                    onTap: _enabled ? _pickTime : null,
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Thème'),
              subtitle: Text(_themeLabel(context)),
              onTap: _cycleTheme,
            ),
          ],
        ),
      ),
    );
  }
}

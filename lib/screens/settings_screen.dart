import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notification_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

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
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (t != null) {
      setState(() => _time = t);
      await NotifHelper.scheduleDaily(t.hour, t.minute);
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    if (value) {
      await NotifHelper.scheduleDaily(_time.hour, _time.minute);
    } else {
      await NotifHelper.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SwitchListTile(
              value: _enabled,
              title: const Text('Notification quotidienne'),
              onChanged: _toggle,
            ),
            ListTile(
              title: const Text('Heure'),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.schedule),
              onTap: _enabled ? _pickTime : null,
            ),
          ],
        ),
      ),
    );
  }
}

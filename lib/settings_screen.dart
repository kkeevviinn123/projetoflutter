import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Português';

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        children: [
          SwitchListTile(
            title: const Text('Tema Escuro'),
            subtitle: const Text('Ativa o modo escuro para o aplicativo'),
            value: themeNotifier.isDarkMode,
            onChanged: (val) => themeNotifier.toggleTheme(val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notificações'),
            subtitle: const Text('Permitir notificações do app'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          const Divider(),
          ListTile(
            title: const Text('Idioma'),
            subtitle: Text('Selecionado: $_selectedLanguage'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'Português', child: Text('Português')),
                DropdownMenuItem(value: 'Inglês', child: Text('Inglês')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLanguage = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Idioma alterado para $val')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


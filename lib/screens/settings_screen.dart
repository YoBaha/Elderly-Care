import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);

    return Column(
      children: [
        AppBar(
          title: Text('Settings'),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Enable Dark Mode'),
                  value: settingsViewModel.isDarkMode,
                  onChanged: (value) {
                    settingsViewModel.toggleDarkMode();
                  },
                ),
                SwitchListTile(
                  title: Text('Enable Notifications'),
                  value: settingsViewModel.isNotificationsEnabled,
                  onChanged: (value) {
                    settingsViewModel.toggleNotifications();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

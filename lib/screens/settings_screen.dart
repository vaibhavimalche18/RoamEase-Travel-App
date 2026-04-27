import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // imports darkModeNotifier, localeNotifier, languageLocales

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  // Read current language name from the active locale
  String get _selectedLanguage => languageLocales.entries
      .firstWhere(
        (e) => e.value == localeNotifier.value,
        orElse: () => languageLocales.entries.first,
      )
      .key;

  // ── LOGOUT ────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.logout, color: Colors.red, size: 22),
          SizedBox(width: 10),
          Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  // ── LANGUAGE PICKER ───────────────────────────────────────────────
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Select Language',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...languageLocales.entries.map((entry) => ListTile(
                  leading: Icon(
                    Icons.check,
                    color: _selectedLanguage == entry.key
                        ? Colors.blue
                        : Colors.transparent,
                  ),
                  title: Text(entry.key),
                  onTap: () {
                    localeNotifier.value = entry.value;
                    setState(() {}); // refresh subtitle in this screen
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language set to ${entry.key}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text('Settings',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [

              _sectionHeader('Preferences'),

              _settingsTile(
                icon: Icons.notifications_outlined,
                iconColor: Colors.orange,
                title: 'Notifications',
                subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value
                            ? 'Notifications enabled'
                            : 'Notifications disabled'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),

              _settingsTile(
                icon: Icons.language_outlined,
                iconColor: Colors.blue,
                title: 'Language',
                subtitle: _selectedLanguage,
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: _showLanguagePicker,
              ),

              _settingsTile(
                icon: Icons.dark_mode_outlined,
                iconColor: Colors.indigo,
                title: 'Dark Mode',
                subtitle: isDark ? 'On' : 'Off',
                trailing: Switch(
                  value: isDark,
                  activeColor: Colors.indigo,
                  // Writing to notifier triggers MyApp to rebuild with new themeMode
                  onChanged: (value) => darkModeNotifier.value = value,
                ),
              ),

              const SizedBox(height: 16),

              _sectionHeader('Account'),

              _settingsTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: _logout,
                titleColor: Colors.red,
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  'RoamEase v1.0.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: titleColor ?? Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
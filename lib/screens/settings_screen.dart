import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/AppStrings.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  final FirebaseAuth? auth;

  const SettingsScreen({
    super.key,
    this.auth,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final FirebaseAuth _auth;
  static const Color primaryBlue = Color(0xFF1A3D8F);
  static const Color textWhite = Colors.white;
  static const Color dangerRed = Color(0xFFFF4B55);

  bool _pushNotifications = true;
  bool _syncEnabled = true;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? FirebaseAuth.instance;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _syncEnabled = prefs.getBool('sync_enabled') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _logout() async {
    final strings = AppStrings.of(context, listen: false);
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.errorLogout} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final currentLocale = Provider.of<LocaleProvider>(context).locale;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              strings.settingsTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.settingsSubtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          _buildSwitchTile(
            title: strings.settingsPushTitle, 
            subtitle: strings.settingsPushSubtitle, 
            value: _pushNotifications,
            onChanged: (val) {
              setState(() => _pushNotifications = val);
              _saveSetting('push_notifications', val);
            },
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          _buildSwitchTile(
            title: strings.settingsSyncTitle, 
            subtitle: strings.settingsSyncSubtitle, 
            value: _syncEnabled,
            onChanged: (val) {
              setState(() => _syncEnabled = val);
              _saveSetting('sync_enabled', val);
            },
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          _buildArrowTile(
            title: strings.settingsLangTitle, 
            subtitle: currentLocale.languageCode == 'en' ? 'English' : 'Українська',
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Українська'),
                          trailing: currentLocale.languageCode == 'uk' ? const Icon(Icons.check, color: Color(0xFF1A3D8F)) : null,
                          onTap: () {
                            Provider.of<LocaleProvider>(context, listen: false).setLocale('uk');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('English'),
                          trailing: currentLocale.languageCode == 'en' ? const Icon(Icons.check, color: Color(0xFF1A3D8F)) : null,
                          onTap: () {
                            Provider.of<LocaleProvider>(context, listen: false).setLocale('en');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          _buildArrowTile(
            title: strings.settingsExportTitle, 
            subtitle: strings.settingsExportSubtitle, 
            onTap: () {},
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                strings.settingsLogoutButton,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Transform.scale(
          scale: 1.2, 
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF1A3D8F), 
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildArrowTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward, 
            color: Color(0xFF7B9FE6), 
            size: 20,
          ),
        ],
      ),
    );
  }
}


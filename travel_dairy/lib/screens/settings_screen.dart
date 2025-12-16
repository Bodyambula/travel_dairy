import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/AppStrings.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryBlue = Color(0xFF1A3D8F);
  static const Color textWhite = Colors.white;
  static const Color dangerRed = Color(0xFFFF4B55);

  // Стан перемикачів
  bool _pushNotifications = true;
  bool _syncEnabled = true;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // Метод завантаження
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _syncEnabled = prefs.getBool('sync_enabled') ?? true;
    });
  }

  // Метод збереження
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Логіка виходу
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Використовуємо рядок помилки з AppStrings
          SnackBar(content: Text('${AppStrings.errorLogout} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              // Використовуємо константу
              AppStrings.settingsTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textWhite,
              ),
            ),
            SizedBox(height: 8),
            Text(
              // Використовуємо константу
              AppStrings.settingsSubtitle,
              style: TextStyle(
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
          // Push-нагадування
          _buildSwitchTile(
            title: AppStrings.settingsPushTitle, // Константа
            subtitle: AppStrings.settingsPushSubtitle, // Константа
            value: _pushNotifications,
            onChanged: (val) {
              setState(() => _pushNotifications = val);
              _saveSetting('push_notifications', val);
            },
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          // Синхронізація
          _buildSwitchTile(
            title: AppStrings.settingsSyncTitle, // Константа
            subtitle: AppStrings.settingsSyncSubtitle, // Константа
            value: _syncEnabled,
            onChanged: (val) {
              setState(() => _syncEnabled = val);
              _saveSetting('sync_enabled', val);
            },
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          // Мова інтерфейсу
          _buildArrowTile(
            title: AppStrings.settingsLangTitle, // Константа
            subtitle: AppStrings.settingsLangValue, // Константа
            onTap: () {},
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          // Експорт подорожей
          _buildArrowTile(
            title: AppStrings.settingsExportTitle, // Константа
            subtitle: AppStrings.settingsExportSubtitle, // Константа
            onTap: () {},
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

          const SizedBox(height: 16),

          // Кнопка Виходу
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
              child: const Text(
                // Використовуємо константу
                AppStrings.settingsLogoutButton,
                style: TextStyle(
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

  // Віджет для рядка з перемикачем (Switch)
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
        // Кастомний перемикач
        Transform.scale(
          scale: 1.2, // Трохи збільшуємо перемикач
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(
              0xFF1A3D8F,
            ), // Синій колір активного стану
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  // Віджет для рядка зі стрілкою
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
          // Маленька синя стрілочка, як на макеті
          const Icon(
            Icons.arrow_forward, // або Icons.east
            color: Color(0xFF7B9FE6), // Світло-синій колір стрілки
            size: 20,
          ),
        ],
      ),
    );
  }
}

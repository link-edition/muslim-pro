import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          'Sozlamalar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsGroup('Umumiy', [
            _SettingsTile(
              icon: Icons.language,
              title: 'Til',
              subtitle: 'O\'zbek',
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Bildirishnomalar',
              trailing: Switch(
                value: settings.notificationsEnabled,
                activeColor: AppColors.softGold,
                activeTrackColor: AppColors.emeraldMid,
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: AppColors.cardBg,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleNotifications(value);
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSettingsGroup('Haqida', [
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'Versiya',
              subtitle: '1.0.0',
            ),
            _SettingsTile(
              icon: Icons.group_outlined,
              title: 'Jamoamiz',
              subtitle: 'Antigravity',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.softGold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.emeraldLight.withOpacity( 0.1),
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.softGold, size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: trailing ?? (subtitle != null ? Text(
        subtitle!,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textMuted,
        ),
      ) : null),
    );
  }
}

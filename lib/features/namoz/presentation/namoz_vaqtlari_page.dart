import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/namoz/prayer_provider.dart';
import 'package:intl/intl.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';

class NamozVaqtlariPage extends ConsumerWidget {
  const NamozVaqtlariPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerProvider);
    final prayers = prayerState.prayerTimes?.prayers ?? [];
    final now = DateTime.now();
    String dateString;
    try {
      dateString = DateFormat('d-MMMM, yyyy', 'uz').format(now);
    } catch (e) {
      dateString = DateFormat('d-MM-yyyy').format(now);
    }
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
        ),
        title: Text(
          'Namoz vaqtlari',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showMethodSelection(context, ref),
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: prayerState.isLoading && prayerState.prayerTimes == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.softGold))
          : Column(
              children: [
                const SizedBox(height: 10),
                // Joylashuv va Sana qismi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: AppColors.softGold),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    settings.isAutoLocation ? 'Joriy joylashuv' : settings.cityName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  dateString,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showCitySearch(context, ref, settings),
                        icon: const Icon(Icons.edit_location_alt, size: 18),
                        label: const Text('O\'zgartirish'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.softGold,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                if (prayerState.error != null)
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                     child: Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.orange.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Row(
                         children: [
                           const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Text(
                               prayerState.error!,
                               style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: prayers.length,
                    itemBuilder: (context, index) {
                      final prayer = prayers[index];
                      final isNext = prayer.isNext;
                      final isEnabled = settings.enabledPrayers[prayer.name] ?? true;
                      final isQuyosh = prayer.name == 'Quyosh';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: isNext ? AppColors.emeraldMid : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isNext 
                              ? AppColors.softGold.withOpacity(0.5) 
                              : AppColors.emeraldLight.withOpacity(0.15),
                            width: isNext ? 1.5 : 1,
                          ),
                          boxShadow: isNext ? [
                            BoxShadow(
                              color: AppColors.emeraldMid.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ] : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getPrayerIcon(prayer.name),
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prayer.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isNext ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      prayer.nameArabic,
                                      style: GoogleFonts.amiri(
                                        fontSize: 14,
                                        color: isNext 
                                          ? Colors.white.withOpacity(0.8) 
                                          : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  prayer.formattedTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isNext ? AppColors.softGold : AppColors.textPrimary,
                                  ),
                                ),
                                if (!isQuyosh) ...[
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(settingsProvider.notifier).togglePrayerNotification(prayer.name, !isEnabled);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        isEnabled 
                                            ? Icons.notifications_active_rounded 
                                            : Icons.notifications_off_outlined,
                                        size: 28,
                                        color: isNext 
                                            ? (isEnabled ? AppColors.softGold : Colors.white.withOpacity(0.5))
                                            : (isEnabled ? AppColors.softGold : AppColors.textMuted),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showCitySearch(BuildContext context, WidgetRef ref, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CitySearchSheet(settings: settings),
    );
  }

  void _showMethodSelection(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _MethodSelectionSheet(),
    );
  }

  String _getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'bomdod': return '🌅';
      case 'quyosh': return '☀️';
      case 'peshin': return '🌞';
      case 'asr': return '🌤️';
      case 'shom': return '🌇';
      case 'xufton': return '🌙';
      default: return '🕌';
    }
  }
}

class _CitySearchSheet extends ConsumerStatefulWidget {
  final SettingsState settings;
  const _CitySearchSheet({required this.settings});

  @override
  ConsumerState<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends ConsumerState<_CitySearchSheet> {
  final List<Map<String, dynamic>> _cities = [
    {'name': 'Toshkent', 'lat': 41.2995, 'lng': 69.2401},
    {'name': 'Samarqand', 'lat': 39.6270, 'lng': 66.9750},
    {'name': 'Buxoro', 'lat': 39.7747, 'lng': 64.4286},
    {'name': 'Andijon', 'lat': 40.7821, 'lng': 72.3442},
    {'name': 'Namangan', 'lat': 40.9983, 'lng': 71.6726},
    {'name': 'Farg\'ona', 'lat': 40.3833, 'lng': 71.7833},
    {'name': 'Qarshi', 'lat': 38.8610, 'lng': 65.7847},
    {'name': 'Nukus', 'lat': 42.4533, 'lng': 59.6103},
    {'name': 'Urganch', 'lat': 41.5500, 'lng': 60.6333},
    {'name': 'Xiva', 'lat': 41.3783, 'lng': 60.3639},
    {'name': 'Termiz', 'lat': 37.2242, 'lng': 67.2783},
    {'name': 'Guliston', 'lat': 40.4897, 'lng': 68.7842},
    {'name': 'Jizzax', 'lat': 40.1158, 'lng': 67.8422},
    {'name': 'Navoiy', 'lat': 40.0844, 'lng': 65.3792},
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCities = _cities
        .where((city) =>
            city['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shaharni tanlash',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Shahar nomini yozing...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppColors.softGold),
              filled: true,
              fillColor: AppColors.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: () async {
              await ref.read(settingsProvider.notifier).setAutoLocation(true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('GPS orqali joylashuv yoqildi')),
              );
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location, color: AppColors.softGold, size: 20),
            ),
            title: Text(
              'Mening joylashuvim (GPS)',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.softGold,
              ),
            ),
            subtitle: Text(
              'Avtomatik aniqlash',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const Divider(height: 32, color: AppColors.emeraldLight),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                return ListTile(
                  onTap: () async {
                    await ref.read(settingsProvider.notifier).setCity(
                      name: city['name'],
                      lat: city['lat'],
                      lng: city['lng'],
                    );
                    Navigator.pop(context);
                  },
                  title: Text(
                    city['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodSelectionSheet extends ConsumerWidget {
  const _MethodSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hisoblash sozlamalari',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Hisoblash usuli'),
            const SizedBox(height: 12),
            _buildMethodChip(context, ref, settings, 'Uzbekistan', 'O\'zbekiston Musulmonlar idorasi'),
            _buildMethodChip(context, ref, settings, 'Muslim World League', 'Muslim World League'),
            _buildMethodChip(context, ref, settings, 'Egyptian', 'Egyptian General Authority'),
            _buildMethodChip(context, ref, settings, 'Umm Al-Qura', 'Umm Al-Qura (Makkah)'),
            _buildMethodChip(context, ref, settings, 'Karachi', 'University of Islamic Sciences, Karachi'),
            const SizedBox(height: 24),
            _buildSectionTitle('Mazhab (Asr vaqti uchun)'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMadhabButton(context, ref, settings, 'Hanafi', 'Hanafiy'),
                const SizedBox(width: 12),
                _buildMadhabButton(context, ref, settings, 'Shafi', 'Shofiiy / Boshqa'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.softGold,
      ),
    );
  }

  Widget _buildMethodChip(BuildContext context, WidgetRef ref, SettingsState settings, String value, String label) {
    final isSelected = settings.calculationMethod == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(settingsProvider.notifier).setCalculationMethod(value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.emeraldMid : AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.softGold : AppColors.emeraldLight.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 20,
                  color: isSelected ? AppColors.softGold : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMadhabButton(BuildContext context, WidgetRef ref, SettingsState settings, String value, String label) {
    final isSelected = settings.madhab == value;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(settingsProvider.notifier).setMadhab(value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.emeraldMid : AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.softGold : AppColors.emeraldLight.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: isSelected ? AppColors.softGold : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

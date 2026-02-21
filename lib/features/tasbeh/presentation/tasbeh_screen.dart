import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../tasbeh_provider.dart';
import '../data/zikr_model.dart';

/// Tasbeh (Zikr) asosiy sahifasi
class TasbehScreen extends ConsumerStatefulWidget {
  const TasbehScreen({super.key});

  @override
  ConsumerState<TasbehScreen> createState() => _TasbehScreenState();
}

class _TasbehScreenState extends ConsumerState<TasbehScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Tugma bosilganda
  Future<void> _onTap() async {
    final tasbehState = ref.read(tasbehProvider);
    final current = tasbehState.currentZikr;
    if (current == null) return;

    final newCount = current.count + 1;

    // Animatsiya
    await _animController.forward();
    await _animController.reverse();

    // Haptic feedback
    if (newCount % 33 == 0 || newCount % 66 == 0 || newCount % 99 == 0) {
      // Muhim bosqichda kuchliroq vibratsiya
      HapticFeedback.vibrate();
    } else {
      // Oddiy bosishda engil tebranish
      HapticFeedback.lightImpact();
    }

    // Sanoqni oshirish
    ref.read(tasbehProvider.notifier).increment();
  }

  @override
  Widget build(BuildContext context) {
    final tasbehState = ref.watch(tasbehProvider);
    final currentZikr = tasbehState.currentZikr;

    if (currentZikr == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Yuqori — Zikr tanlash
        _buildZikrSelector(context, tasbehState),

        // O'rta — Asosiy tasbeh tugmasi (RepaintBoundary bilan izolyatsiya)
        Expanded(
          child: RepaintBoundary(
            child: _buildMainCounter(context, currentZikr, tasbehState),
          ),
        ),

        // Pastki — Statistika va reset
        _buildBottomBar(context, currentZikr, tasbehState),
      ],
    );
  }

  /// Zikr tanlash paneli (gorizontal ro'yxat)
  Widget _buildZikrSelector(BuildContext context, TasbehState tasbehState) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tasbehState.zikrList.length,
        itemBuilder: (context, index) {
          final zikr = tasbehState.zikrList[index];
          final isSelected = index == tasbehState.selectedIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              selected: isSelected,
              onSelected: (_) {
                ref.read(tasbehProvider.notifier).selectZikr(index);
                HapticFeedback.selectionClick();
              },
              label: Text(zikr.name),
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.primaryGreen,
              ),
              backgroundColor: Colors.transparent,
              selectedColor: AppColors.primaryGreen,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              avatar: zikr.isCompleted && isSelected
                  ? const Icon(Icons.check_circle, color: Colors.white, size: 16)
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Asosiy tasbeh tugmasi va progress
  Widget _buildMainCounter(
    BuildContext context,
    ZikrModel currentZikr,
    TasbehState tasbehState,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.55;

    return GestureDetector(
      onTap: _onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Arabcha matn
          Text(
            currentZikr.arabic,
            style: GoogleFonts.amiri(
              fontSize: 28,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // O'zbekcha tarjima
          Text(
            currentZikr.translation,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Asosiy tugma — aylana progress bilan
          // AnimatedBuilder GPU darajasida optimize qilingan
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fon aylana (track)
                  SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                  // Progress aylana (Implicit animation)
                  SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: currentZikr.progress,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          color: currentZikr.isCompleted
                              ? AppColors.gold
                              : AppColors.primaryGreen,
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                  ),

                  // Ichki tugma
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: buttonSize - 32,
                    height: buttonSize - 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: currentZikr.isCompleted
                          ? AppColors.goldGradient
                          : AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (currentZikr.isCompleted
                                  ? AppColors.gold
                                  : AppColors.primaryGreen)
                              .withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sanoq raqami
                        Text(
                          '${currentZikr.count}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        // Limit
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '/ ${currentZikr.limit}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tugallangan belgisi
                  if (currentZikr.isCompleted)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bosish ko'rsatmasi
          Text(
            currentZikr.isCompleted
                ? '✨ Maqsadga yetdingiz!'
                : 'Bosing va zikr qiling',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: currentZikr.isCompleted
                  ? AppColors.gold
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
              fontWeight:
                  currentZikr.isCompleted ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Pastki panel — statistika va reset tugmalari
  Widget _buildBottomBar(
    BuildContext context,
    ZikrModel currentZikr,
    TasbehState tasbehState,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Jami sanoq
          _StatItem(
            icon: Icons.functions,
            label: 'Jami',
            value: '${tasbehState.totalCount}',
          ),

          // Qolgan
          _StatItem(
            icon: Icons.track_changes,
            label: 'Qolgan',
            value: '${currentZikr.remaining}',
            color: currentZikr.isCompleted ? AppColors.gold : null,
          ),

          // Sanoqni qaytarish
          _ActionButton(
            icon: Icons.refresh,
            label: 'Qaytarish',
            onTap: () => _showResetDialog(context),
          ),

          // Zikrlar menyusi
          _ActionButton(
            icon: Icons.list_alt,
            label: 'Zikrlar',
            onTap: () => _showZikrListSheet(context, tasbehState),
          ),
        ],
      ),
    );
  }

  /// Reset dialog
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sanoqni qaytarish',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Joriy zikr sanoqini nolga qaytarasizmi?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Bekor',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasbehProvider.notifier).resetCurrent();
              HapticFeedback.mediumImpact();
              Navigator.pop(ctx);
            },
            child: Text(
              'Joriy zikr',
              style: GoogleFonts.inter(color: Colors.orange),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tasbehProvider.notifier).resetAll();
              HapticFeedback.heavyImpact();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Barchasini',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Zikrlar ro'yxati bottom sheet
  void _showZikrListSheet(BuildContext context, TasbehState tasbehState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Sarlavha
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Text(
                      'Zikrlarni tanlang',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Ro'yxat
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tasbehState.zikrList.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (_, index) {
                    final zikr = tasbehState.zikrList[index];
                    final isSelected = index == tasbehState.selectedIndex;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      onTap: () {
                        ref.read(tasbehProvider.notifier).selectZikr(index);
                        HapticFeedback.selectionClick();
                        Navigator.pop(ctx);
                      },
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: zikr.isCompleted
                              ? Icon(
                                  Icons.check_circle,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.gold,
                                  size: 22,
                                )
                              : Text(
                                  '${zikr.count}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primaryGreen,
                                  ),
                                ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            zikr.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            zikr.arabic,
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            '${zikr.count} / ${zikr.limit}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: zikr.progress,
                                backgroundColor:
                                    AppColors.primaryGreen.withValues(alpha: 0.1),
                                color: zikr.isCompleted
                                    ? AppColors.gold
                                    : AppColors.primaryGreen,
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: isSelected
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Tanlangan',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Statistika elementi
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.primaryGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Amal tugmasi
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

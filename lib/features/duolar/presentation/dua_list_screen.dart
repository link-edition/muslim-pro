import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/dua_model.dart';
import '../data/dua_repository.dart';

class DuaListScreen extends ConsumerWidget {
  final DuaCategory category;
  
  const DuaListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duasByCategoryProvider(category.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          category.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Subtle background glow for Liquid Glass effect
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emeraldLight.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softGold.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main list
          duasAsync.when(
            data: (duas) {
              if (duas.isEmpty) {
                return Center(
                  child: Text(
                    "Bu bo'limda duolar hozircha yo'q",
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: duas.length,
                itemBuilder: (context, index) {
                  return _DuaItemCard(dua: duas[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emeraldMid)),
            error: (e, st) => Center(child: Text('Xatolik: $e')),
          ),
        ],
      ),
    );
  }
}

class _DuaItemCard extends StatefulWidget {
  final Dua dua;
  const _DuaItemCard({required this.dua});

  @override
  State<_DuaItemCard> createState() => _DuaItemCardState();
}

class _DuaItemCardState extends State<_DuaItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.emeraldLight.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.transparent,
          child: ExpansionTile(
            onExpansionChanged: (val) {
              setState(() => _isExpanded = val);
            },
            shape: const Border(),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: AppColors.emeraldMid,
            collapsedIconColor: AppColors.emeraldMid.withOpacity(0.5),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.dua.title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    
                    // Narrator Intro
                    if (widget.dua.narratorIntro.isNotEmpty) ...[
                      Text(
                        widget.dua.narratorIntro,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Arabic Text
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.dua.arabic,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.amiri(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softGold, // Made it softGold for high visibility
                          height: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Transliteration (faqat bo'lsa ko'rsatish)
                    if (widget.dua.transcription.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "O'QILISHI:",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppColors.emeraldMid,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.dua.transcription,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Translation
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softGold.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* Text(
                            "MA'NOSI:",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.softGold,
                            ),
                          ),
                          const SizedBox(height: 6), */
                          Text(
                            widget.dua.translation,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reference
                    if (widget.dua.reference.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.dua.reference.toUpperCase(),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            color: AppColors.emeraldLight.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/history_repository.dart';
import '../widgets/gymr_logo_title.dart';
import 'add_evolution_photo_view.dart';
import 'progress_view_model.dart';

/// Tela de Galeria de Fotos Comparativas (Antes vs Depois)
/// Permite ao atleta visualizar a evolução estética lado a lado,
/// registrar novas fotos locais e comparar marcos temporais.
class ComparativePhotoView extends StatefulWidget {
  const ComparativePhotoView({super.key});

  @override
  State<ComparativePhotoView> createState() => _ComparativePhotoViewState();
}

class _ComparativePhotoViewState extends State<ComparativePhotoView> {
  int _selectedBaselineIndex = 0;
  int _selectedCurrentIndex = 0;
  bool _isSplitMode = true; // true = lado a lado; false = sobreposição/slider

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadProgressData();
    });
  }

  void _openAddPhotoScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEvolutionPhotoView()),
    );
  }

  Widget _buildPhotoWidget(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPhotoContainer(),
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPhotoContainer(),
      );
    }

    return _buildFallbackPhotoContainer();
  }

  Widget _buildFallbackPhotoContainer() {
    return Container(
      color: const Color(0xFF1E2026),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_outlined, size: 40, color: AppColors.textSecondary),
            SizedBox(height: 6),
            Text(
              'Foto Registrada',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();

    // Extrai medições que possuem foto cadastrada
    final photoRecords = vm.measurements
        .where((m) => m.photoPaths.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const GymrLogoTitle(title: 'Galeria Comparativa'),
        actions: [
          IconButton(
            icon: Icon(
              _isSplitMode ? Icons.view_column_rounded : Icons.compare_rounded,
              color: AppColors.primaryNeon,
            ),
            tooltip: _isSplitMode ? 'Modo Comparação' : 'Modo Lado a Lado',
            onPressed: () {
              setState(() {
                _isSplitMode = !_isSplitMode;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPhotoScreen(context),
        backgroundColor: AppColors.primaryNeon,
        foregroundColor: AppColors.textOnNeon,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text(
          'NOVA FOTO',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
      body: photoRecords.isEmpty
          ? _buildEmptyState(context, vm)
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildHeader(photoRecords.length),
                const SizedBox(height: 16),
                _buildComparisonView(photoRecords),
                const SizedBox(height: 24),
                _buildTimelineGallery(photoRecords),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildHeader(int totalPhotos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'EVOLUÇÃO ANTES & DEPOIS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryNeon.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
          ),
          child: Text(
            '$totalPhotos fotos registradas',
            style: const TextStyle(
              color: AppColors.primaryNeon,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonView(List<MeasurementRecord> records) {
    final baselineRecord = records[_selectedBaselineIndex.clamp(0, records.length - 1)];
    final currentRecord = records[_selectedCurrentIndex.clamp(0, records.length - 1)];

    final baselinePhoto = baselineRecord.photoPaths.first;
    final currentPhoto = currentRecord.photoPaths.first;

    final baselineWeight = baselineRecord.weightKg != null
        ? '${baselineRecord.weightKg!.toStringAsFixed(1)} kg'
        : '--';
    final currentWeight = currentRecord.weightKg != null
        ? '${currentRecord.weightKg!.toStringAsFixed(1)} kg'
        : '--';

    final baselineDate = '${baselineRecord.date.day}/${baselineRecord.date.month}/${baselineRecord.date.year}';
    final currentDate = '${currentRecord.date.day}/${currentRecord.date.month}/${currentRecord.date.year}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF26272B)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: _isSplitMode ? 320 : 480,
            child: Flex(
              direction: _isSplitMode ? Axis.horizontal : Axis.vertical,
              children: [
                // Coluna "Antes"
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPhotoWidget(baselinePhoto),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18191D).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: const Text(
                            'ANTES',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              baselineDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              baselineWeight,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Divisor Neon
                Container(
                  width: _isSplitMode ? 2 : double.infinity,
                  height: _isSplitMode ? double.infinity : 2,
                  color: AppColors.primaryNeon,
                ),

                // Coluna "Depois"
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPhotoWidget(currentPhoto),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNeon,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'DEPOIS',
                            style: TextStyle(
                              color: AppColors.textOnNeon,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              currentWeight,
                              style: const TextStyle(
                                color: AppColors.primaryNeon,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Toque nas miniaturas abaixo para alterar a comparação',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.swipe_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineGallery(List<MeasurementRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HISTÓRICO DE REGISTROS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final r = records[index];
              final photo = r.photoPaths.first;
              final isBaseline = index == _selectedBaselineIndex;
              final isCurrent = index == _selectedCurrentIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedBaselineIndex == index) {
                      _selectedCurrentIndex = index;
                    } else {
                      _selectedBaselineIndex = index;
                    }
                  });
                },
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primaryNeon
                          : (isBaseline ? Colors.white : const Color(0xFF26272B)),
                      width: (isCurrent || isBaseline) ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPhotoWidget(photo),
                      if (isCurrent || isBaseline)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.primaryNeon : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isCurrent ? 'DEPOIS' : 'ANTES',
                              style: TextStyle(
                                color: isCurrent ? AppColors.textOnNeon : Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ProgressViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D22),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 36,
                color: AppColors.primaryNeon,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma Foto de Evolução',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registre fotos periódicas para comparar sua transformação estética lado a lado (Antes vs Depois).',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openAddPhotoScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNeon,
                foregroundColor: AppColors.textOnNeon,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text(
                'REGISTRAR PRIMEIRA FOTO',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

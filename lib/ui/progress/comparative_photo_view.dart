import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/history_repository.dart';
import '../widgets/gymr_logo_title.dart';
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

  Future<String?> _pickAndPersistImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'evolution_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final ext = p.extension(picked.path).isNotEmpty ? p.extension(picked.path) : '.jpg';
    final destPath = p.join(
      photosDir.path,
      'evo_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(picked.path).copy(destPath);
    return destPath;
  }

  void _showAddPhotoDialog(BuildContext context, ProgressViewModel vm) {
    final weightController = TextEditingController();
    String? selectedPath;
    String? pickerError;
    bool isPicking = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> handlePick(ImageSource source) async {
              setDialogState(() {
                isPicking = true;
                pickerError = null;
              });
              try {
                final savedPath = await _pickAndPersistImage(source);
                if (savedPath != null && ctx.mounted) {
                  setDialogState(() {
                    selectedPath = savedPath;
                  });
                }
              } catch (_) {
                if (ctx.mounted) {
                  setDialogState(() {
                    pickerError = 'Não foi possível acessar a mídia neste dispositivo.';
                  });
                }
              } finally {
                if (ctx.mounted) {
                  setDialogState(() => isPicking = false);
                }
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              title: const Text(
                'Registrar Foto de Evolução',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isPicking ? null : () => handlePick(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, size: 18),
                            label: const Text('Câmera'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryNeon,
                              side: BorderSide(color: AppColors.primaryNeon.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isPicking ? null : () => handlePick(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_rounded, size: 18),
                            label: const Text('Galeria'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryNeon,
                              side: BorderSide(color: AppColors.primaryNeon.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isPicking) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(color: AppColors.primaryNeon),
                    ],
                    if (pickerError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        pickerError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (selectedPath != null && File(selectedPath!).existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selectedPath!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 92,
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Text(
                          'Nenhuma foto selecionada.\nEscolha Câmera ou Galeria acima.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Peso (opcional)',
                        hintText: 'Ex: 78,5',
                        suffixText: 'kg',
                        prefixIcon: Icon(Icons.monitor_weight_outlined, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('CANCELAR', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: selectedPath == null
                      ? null
                      : () async {
                          final path = selectedPath!;
                          final weight = double.tryParse(
                            weightController.text.trim().replaceAll(',', '.'),
                          );
                          Navigator.pop(dialogCtx);

                          await vm.addMeasurement(
                            weightKg: weight,
                            photoPaths: [path],
                          );
                        },
                  child: const Text('SALVAR FOTO'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      weightController.dispose();
    });
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
        onPressed: () => _showAddPhotoDialog(context, vm),
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
              onPressed: () => _showAddPhotoDialog(context, vm),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/gymr_logo_title.dart';
import 'progress_view_model.dart';

/// Tela cheia e adaptável para registrar uma foto de evolução (Câmera ou Galeria).
class AddEvolutionPhotoView extends StatefulWidget {
  const AddEvolutionPhotoView({super.key});

  @override
  State<AddEvolutionPhotoView> createState() => _AddEvolutionPhotoViewState();
}

class _AddEvolutionPhotoViewState extends State<AddEvolutionPhotoView> {
  final TextEditingController _weightController = TextEditingController();
  String? _selectedPath;
  String? _pickerError;
  bool _isPicking = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
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

  Future<void> _handlePick(ImageSource source) async {
    setState(() {
      _isPicking = true;
      _pickerError = null;
    });
    try {
      final savedPath = await _pickAndPersistImage(source);
      if (savedPath != null && mounted) {
        setState(() => _selectedPath = savedPath);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pickerError = 'Não foi possível acessar a mídia neste dispositivo.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _savePhoto() async {
    if (_selectedPath == null || _isSaving) return;
    setState(() => _isSaving = true);

    final weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    try {
      await context.read<ProgressViewModel>().addMeasurement(
            weightKg: weight,
            photoPaths: [_selectedPath!],
          );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar foto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidFile = _selectedPath != null && File(_selectedPath!).existsSync();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const GymrLogoTitle(title: 'Registrar Foto de Evolução'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecione uma foto do seu progresso físico:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isPicking ? null : () => _handlePick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: const Text('Câmera'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryNeon,
                          side: BorderSide(color: AppColors.primaryNeon.withValues(alpha: 0.45)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isPicking ? null : () => _handlePick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: const Text('Galeria'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryNeon,
                          side: BorderSide(color: AppColors.primaryNeon.withValues(alpha: 0.45)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isPicking) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(color: AppColors.primaryNeon),
              ],
              if (_pickerError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _pickerError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 18),
              Container(
                height: 250,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: hasValidFile
                        ? AppColors.primaryNeon.withValues(alpha: 0.4)
                        : AppColors.surfaceBorder,
                  ),
                ),
                child: hasValidFile
                    ? Image.file(File(_selectedPath!), fit: BoxFit.cover)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Nenhuma foto selecionada.\nUse Câmera ou Galeria acima.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso atual (opcional)',
                  hintText: 'Ex: 78,5',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: (_selectedPath == null || _isSaving) ? null : _savePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNeon,
                    foregroundColor: AppColors.textOnNeon,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnNeon),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'SALVAR FOTO',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../profile/profile_view_model.dart';
import '../widgets/gymr_logo_title.dart';
import 'progress_view_model.dart';

class RegisterMeasurementView extends StatefulWidget {
  const RegisterMeasurementView({super.key});

  @override
  State<RegisterMeasurementView> createState() => _RegisterMeasurementViewState();
}

class _RegisterMeasurementViewState extends State<RegisterMeasurementView> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _chestController = TextEditingController();
  final _armsController = TextEditingController();
  final _waistController = TextEditingController();
  final _thighsController = TextEditingController();
  final _calvesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _chestController.dispose();
    _armsController.dispose();
    _waistController.dispose();
    _thighsController.dispose();
    _calvesController.dispose();
    super.dispose();
  }

  double? _parseDecimal(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<void> _saveMeasurements() async {
    final weight = _parseDecimal(_weightController.text);
    final bf = _parseDecimal(_bodyFatController.text);
    final chest = _parseDecimal(_chestController.text);
    final arms = _parseDecimal(_armsController.text);
    final waist = _parseDecimal(_waistController.text);
    final thighs = _parseDecimal(_thighsController.text);
    final calves = _parseDecimal(_calvesController.text);

    if (weight == null &&
        bf == null &&
        chest == null &&
        arms == null &&
        waist == null &&
        thighs == null &&
        calves == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha pelo menos uma medida antes de salvar.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<ProgressViewModel>().addMeasurement(
            weightKg: weight,
            bodyFatPercentage: bf,
            chestCm: chest,
            armsCm: arms,
            waistCm: waist,
            thighsCm: thighs,
            calvesCm: calves,
          );
      if (mounted) {
        context.read<ProfileViewModel>().loadProfileData();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar medidas: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GymrLogoTitle(title: 'Nova Medição'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  const Text(
                    'Acompanhe sua evolução física registrando peso, percentual de gordura e circunferências.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionHeader('COMPOSIÇÃO CORPORAL', Icons.monitor_weight_outlined),
                  const SizedBox(height: 10),
                  _buildSectionCard([
                    _buildMeasurementField(
                      controller: _weightController,
                      label: 'Peso Corporal',
                      unit: 'kg',
                      hint: 'Ex: 78.4',
                      icon: Icons.scale_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildMeasurementField(
                      controller: _bodyFatController,
                      label: 'Percentual de Gordura (BF)',
                      unit: '%',
                      hint: 'Ex: 14.5',
                      icon: Icons.pie_chart_outline_rounded,
                    ),
                  ]),
                  const SizedBox(height: 22),

                  _buildSectionHeader('TRONCO E MEMBROS SUPERIORES', Icons.accessibility_new_rounded),
                  const SizedBox(height: 10),
                  _buildSectionCard([
                    _buildMeasurementField(
                      controller: _chestController,
                      label: 'Circunferência do Tórax',
                      unit: 'cm',
                      hint: 'Ex: 102.0',
                      icon: Icons.straighten_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildMeasurementField(
                      controller: _armsController,
                      label: 'Circunferência do Braço',
                      unit: 'cm',
                      hint: 'Ex: 39.5',
                      icon: Icons.fitness_center_rounded,
                    ),
                  ]),
                  const SizedBox(height: 22),

                  _buildSectionHeader('ABDÔMEN E MEMBROS INFERIORES', Icons.directions_run_rounded),
                  const SizedBox(height: 10),
                  _buildSectionCard([
                    _buildMeasurementField(
                      controller: _waistController,
                      label: 'Circunferência da Cintura',
                      unit: 'cm',
                      hint: 'Ex: 80.0',
                      icon: Icons.compress_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildMeasurementField(
                      controller: _thighsController,
                      label: 'Circunferência das Coxas',
                      unit: 'cm',
                      hint: 'Ex: 59.5',
                      icon: Icons.straighten_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildMeasurementField(
                      controller: _calvesController,
                      label: 'Circunferência das Panturrilhas',
                      unit: 'cm',
                      hint: 'Ex: 38.0',
                      icon: Icons.straighten_rounded,
                    ),
                  ]),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF121316),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMeasurements,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNeon,
                    foregroundColor: AppColors.textOnNeon,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnNeon,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 22),
                  label: const Text(
                    'SALVAR MEDIDAS',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryNeon),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26272B)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMeasurementField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primaryNeon, size: 20),
            suffixText: unit,
            suffixStyle: const TextStyle(
              color: AppColors.primaryNeon,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFF121316),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryNeon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

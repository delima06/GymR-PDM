import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/exercise_images.dart';
import '../../domain/models/exercise.dart';
import '../widgets/gymr_logo_title.dart';
import 'exercise_catalog_view_model.dart';
import 'exercise_detail_view.dart';

class ExerciseCatalogView extends StatefulWidget {
  final bool isSelectionMode;
  final Function(Exercise)? onSelectExercise;

  const ExerciseCatalogView({
    super.key,
    this.isSelectionMode = false,
    this.onSelectExercise,
  });

  @override
  State<ExerciseCatalogView> createState() => _ExerciseCatalogViewState();
}

class _ExerciseCatalogViewState extends State<ExerciseCatalogView> {
  final _searchController = TextEditingController();
  late final ExerciseCatalogViewModel _viewModel;

  static const List<String> _muscleGroups = [
    'Todos',
    'Peito',
    'Costas',
    'Pernas',
    'Ombros',
    'Braços',
    'Core',
  ];

  static const List<String> _equipmentOptions = [
    'Todos',
    'Halteres',
    'Barra',
    'Máquina',
    'Peso do corpo',
    'Polia',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ExerciseCatalogViewModel()..loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleExerciseTap(Exercise exercise) {
    if (widget.isSelectionMode) {
      if (widget.onSelectExercise != null) {
        widget.onSelectExercise!(exercise);
      }
      Navigator.of(context).pop(exercise);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExerciseDetailView(exercise: exercise),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ExerciseCatalogViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: GymrLogoTitle(
                title: widget.isSelectionMode ? 'Selecionar Exercício' : 'Catálogo',
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Barra de Busca em tempo real
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: vm.onSearchChanged,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar exercício por nome, músculo...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryNeon, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                vm.onSearchChanged('');
                              },
                            )
                          : null,
                filled: true,
                fillColor: const Color(0xFF18191D),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryNeon, width: 1.5),
                ),
              ),
            ),
          ),

          // 2. Chips de Filtro por Grupamento Muscular
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _muscleGroups.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final group = _muscleGroups[index];
                  final isSelected = vm.selectedMuscleGroup == group;
                  return ChoiceChip(
                    label: Text(group),
                    selected: isSelected,
                    onSelected: (_) => vm.selectMuscleGroup(group),
                    selectedColor: AppColors.primaryNeon,
                    backgroundColor: const Color(0xFF18191D),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.textOnNeon : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryNeon
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ),

          // 3. Chips de Filtro por Equipamento
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 4, bottom: 8),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _equipmentOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final equip = _equipmentOptions[index];
                  final isSelected = vm.selectedEquipment == equip;
                  return ChoiceChip(
                    label: Text(equip),
                    selected: isSelected,
                    onSelected: (_) => vm.selectEquipment(equip),
                    selectedColor: const Color(0xFF28331E),
                    backgroundColor: const Color(0xFF141518),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryNeon : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryNeon.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ),

          // 4. Contador de resultados e status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${vm.exercises.length} EXERCÍCIO${vm.exercises.length == 1 ? '' : 'S'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                if (vm.selectedMuscleGroup != 'Todos' ||
                    vm.selectedEquipment != 'Todos' ||
                    _searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      vm.clearFilters();
                    },
                    child: const Text(
                      'Limpar filtros',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNeon,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 5. Lista de Exercícios ou Estados (Loading / Vazio)
          Expanded(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryNeon),
                  )
                : vm.exercises.isEmpty
                    ? _buildEmptyState(vm)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 600;
                          if (isWide) {
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: vm.exercises.length,
                              itemBuilder: (context, index) {
                                return _buildExerciseCard(vm.exercises[index]);
                              },
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: vm.exercises.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _buildExerciseCard(vm.exercises[index]);
                            },
                          );
                        },
                      ),
          ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return InkWell(
      onTap: () => _handleExerciseTap(exercise),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF18191D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            // Thumbnail da Imagem Local Offline
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF202228),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: ExerciseImageHelper.getExerciseImage(
                  exercise.name,
                  mediaUrl: exercise.mediaUrl,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Informações do Exercício
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      // Badge Grupamento
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNeon.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          exercise.muscleGroup,
                          style: const TextStyle(
                            color: AppColors.primaryNeon,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Badge Equipamento
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22242A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          exercise.equipment,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botão de Detalhes ou Seleção
            IconButton(
              icon: Icon(
                widget.isSelectionMode ? Icons.add_circle_outline_rounded : Icons.info_outline_rounded,
                color: widget.isSelectionMode ? AppColors.primaryNeon : AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => _handleExerciseTap(exercise),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ExerciseCatalogViewModel vm) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 52, color: AppColors.textMuted),
            const SizedBox(height: 14),
            const Text(
              'Nenhum exercício encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tente ajustar o termo de busca ou alterar os filtros de músculo e equipamento.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                vm.clearFilters();
              },
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryNeon, size: 18),
              label: const Text(
                'LIMPAR TODOS OS FILTROS',
                style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

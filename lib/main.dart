library app;
import 'package:flutter/material.dart';
import 'dart:async';
import 'data/models.dart';
import 'data/sample_data.dart';
import 'l10n/i18n.dart';
import 'features/timers/timer_dialog.dart';
import 'features/timers/timer_manager.dart';

part 'features/planner/planner_tab.dart';
part 'features/recipes/recipes_tab.dart';
part 'features/shopping/shopping_tab.dart';
part 'features/cooking/cooking_tab.dart';
part 'features/recipes/add_recipe_dialog.dart';
part 'features/recipes/recipe_summary_sheet.dart';
part 'features/recipes/recipe_box_screen.dart';
part 'features/recipes/recipes_in_planner_screen.dart';

   2,
  });
}

class PlanEntry {
 Timer Settings =====
class _Ti? stepIndex;
  bool isRunningeCtrl.text.trim(),
       ven to 180°C.',
    'Place salmon and asparagus on a tray.',
    'Bake ~15 min with lemon slices.',
  ],
  '6': [
    'Beat the eggs.',
    'Sauté chopped veggies.',
    'Combine and cook until set.',
  ],
};

// ===== Root =====
class _Root extends StatefulWidget {
  const _Root({Key? key}) : super(key: key);
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  Settings settings = Settings(
    language: AppLanguage.es,
    units: AppUnits.metric,
    currency: AppCurrency.eur,
    theme: AppTheme.light,
  );

  @override
  Widget build(BuildContext context) {
    final lang = settings.language == AppLanguage.en ? 'en' : 'es';
    final t = (String k) => i18n[lang]![k] ?? k;
    final themeMode = settings.theme == AppTheme.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return MaterialApp(
      title: t('title'),
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: _Home(
        settings: settings,
        onSettingsChanged: (s) => setState(() => settings = s),
      ),
    );
  }
}

// ===== Home =====
class _Home extends StatefulWidget {
  final Settings settings;
  final ValueChanged<Settings> onSettingsChanged;
  const _Home({required this.settings, required this.onSettingsChanged});

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> with TickerProviderStateMixin {
  static void _onTimerTick() {}

  int _servings = 2;
  RecipeModel? _currentRecipe;
  late final TabController _tab;
  final List<PlanEntry> _plan = [];
  final List<bool> _collapsed = List<bool>.filled(7, true);
  final Set<String> _favorites = {};
  final TimerManager _timerManager = TimerManager(onTick: _onTimerTick);
  List<TimerInstance> get _timers => _timerManager.timers;
  // managed by TimerManager
  Timer? _globalTimer;
  List<bool> _completedSteps = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _setCurrentRecipe(recipes.isNotEmpty ? recipes.first : null, reset: true);
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _tab.dispose();
    super.dispose();
  }

  void _setCurrentRecipe(RecipeModel? r, {bool reset = true}) {
    if (r == null) return;
    setState(() {
      _currentRecipe = r;
      _servings = r.defaultServings;
      if (reset) {
        _resetCooking();
        _completedSteps = List<bool>.filled(r.steps.length, false);
      }
    });
  }

  void _resetCooking() {
    _globalTimer?.cancel();
    _globalTimer = null;
    _timers = [];
  }

  void _addTimer_deprecated(TimerSettings settings) {
    final timer = TimerInstance(
      originalSeconds: settings.seconds,
      remainingSeconds: settings.seconds,
      name: settings.name,
      stepIndex: settings.stepIndex,
    );
    setState(() => _timers.add(timer));
    _startGlobalTick_deprecated();
  }

  void _pauseTimer_deprecated(TimerInstance timer) {
    setState(() {
      timer.isRunning = false;
    });
    _checkTimersRunning();
  }

  void _resumeTimer_deprecated(TimerInstance timer) {
    setState(() {
      timer.isRunning = true;
    });
    _startGlobalTick_deprecated();
  }

  void _restartTimer_deprecated(TimerInstance timer) {
    setState(() {
      timer.remainingSeconds = timer.originalSeconds;
      timer.isRunning = true;
    });
    _startGlobalTick_deprecated();
  }

  void _checkTimersRunning() {
    bool anyRunning = _timers.any((t) => t.isRunning && t.remainingSeconds > 0);
    if (!anyRunning) {
      _globalTimer?.cancel();
      _globalTimer = null;
    }
  }

  void _startGlobalTick_deprecated() {
    if (_globalTimer?.isActive ?? false) return;
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      bool anyRunning = false;
      setState(() {
        for (var timer in _timers) {
          if (timer.isRunning && timer.remainingSeconds > 0) {
            timer.remainingSeconds--;
            anyRunning = true;
            if (timer.remainingSeconds == 0) {
              timer.isRunning = false;
            }
          }
        }
      });
      if (!anyRunning) {
        _globalTimer?.cancel();
        _globalTimer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.settings.language == AppLanguage.en ? 'en' : 'es';
    final t = (String k) => i18n[lang]![k] ?? k;
    final days = lang == 'en' ? daysEn : daysEs;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('title')),
        actions: [
          IconButton(
            tooltip: t('settings'),
            onPressed: () async {
              final updated = await showDialog<Settings>(
                context: context,
                builder: (_) => _SettingsDialog(settings: widget.settings),
              );
              if (updated != null) widget.onSettingsChanged(updated);
              setState(() {});
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: <Widget>[
            Tab(text: t('planner')),
            Tab(text: t('recipes')),
            Tab(text: t('shopping')),
            Tab(text: t('cooking') + (_currentRecipe != null ? ' *' : '')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: <Widget>[
          plannerTab(this, context, t, days),
          recipesTab(this, context, t),
          shoppingTab(this, context, t),
          cookingTab(this, context, t),
        ],
      ),
    );
  }


  Widget _reorderableDayList(
    int dayIndex,
    List<PlanEntry> entries,
    String Function(String) t,
  ) {
    final items = List<MapEntry<int, PlanEntry>>.generate(
      entries.length,
      (i) => MapEntry<int, PlanEntry>(i, entries[i]),
    );
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final List<PlanEntry> dayItems = _plan
              .where((PlanEntry e) => e.dayIndex == dayIndex)
              .toList();
          final PlanEntry moving = dayItems.removeAt(oldIndex);
          dayItems.insert(newIndex, moving);
          _plan.removeWhere((e) => e.dayIndex == dayIndex);
          _plan.addAll(dayItems);
        });
      },
      children: <Widget>[
        for (final MapEntry<int, PlanEntry> entry in items)
          ListTile(
            key: ValueKey<String>(
              'd$dayIndex-${entry.key}-${entry.value.recipeId}',
            ),
            leading: ReorderableDragStartListener(
              index: entry.key,
              child: const Icon(Icons.drag_handle),
            ),
            title: InkWell(
              onTap: () {
                final RecipeModel r = recipeById(entry.value.recipeId);
                _showRecipeSummary(r, t);
              },
              child: Text(
                '${_mealLabel(entry.value.mealType, t)} — ${recipeById(entry.value.recipeId).title}',
              ),
            ),
          
// moved to part file
ase 'unit':
        return 'unit';
      default:
        return unit;
    }
  }

  String fmt(num v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}

List<String> stepsForDisplay(RecipeModel r, AppLanguage lang) {
  if (lang == AppLanguage.en) return _stepsEnById[r.id] ?? r.steps;
  return r.steps;
}

class AddMealResult {
  final String mealType;
  final String recipeId;
  AddMealResult(this.mealType, this.recipeId);
}

class _AddMealDialog extends StatefulWidget {
  final String Function(String) t;
  final Set<String> favorites;
  final RecipeModel? initialRecipe;
  final String languageKey;
  const _AddMealDialog({
    required this.t,
    required this.favorites,
    this.initialRecipe,
    required this.languageKey,
  });

  @override
  State<_AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<_AddMealDialog> {
  late String _selectedRecipeId;
  String? _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedRecipeId = _sortedRecipes().first.id;
  }

  List<RecipeModel> _sortedRecipes() {
    final list = List<RecipeModel>.from(recipes);
    list.sort((a, b) {
      final fa = widget.favorites.contains(a.id) ? 0 : 1;
      final fb = widget.favorites.contains(b.id) ? 0 : 1;
      final byFav = fa.compareTo(fb);
      if (byFav != 0) return byFav;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return list;
  }

  List<MapEntry<String, String>> _mealTypesSorted() {
    final keys = ['breakfast', 'lunch', 'dinner', 'snack'];
    final entries = keys.map((k) => MapEntry(k, _label(k))).toList();
    return entries;
  }

  String _label(String meal) {
    final t = widget.t;
    switch (meal) {
      case 'breakfast':
        return t('breakfast');
      case 'lunch':
        return t('lunch');
      case 'dinner':
        return t('dinner');
      case 'snack':
        return t('snack');
      default:
        return meal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final sortedRecipes = _sortedRecipes();
    final mealOptions = _mealTypesSorted();

    return AlertDialog(
      title: Text(t('add_meal')),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              t('choose_recipe'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedRecipeId,
              items: sortedRecipes.map<DropdownMenuItem<String>>((
                RecipeModel r,
              ) {
                final isFav = widget.favorites.contains(r.id);
                return DropdownMenuItem<String>(
                  value: r.id,
                  child: Row(
                    children: [
                      if (isFav) const Icon(Icons.star, size: 18),
                      if (isFav) const SizedBox(width: 6),
                      Flexible(child: Text(r.title)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) => setState(() {
                if (newValue != null) _selectedRecipeId = newValue;
              }),
            ),
            const SizedBox(height: 12),
            Text(
              t('meal_type'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedMealType,
              hint: Text(t('meal_type')),
              items: mealOptions.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem<String>(
                  value: e.key,
                  child: Text(e.value),
                );
              }).toList(),
              onChanged: (String? newValue) =>
                  setState(() => _selectedMealType = newValue),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: (_selectedMealType == null)
              ? null
              : () {
                  Navigator.pop(
        
// moved to part file
ngs;
  _NewRecipeResult({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.prepMin,
    required this.cookMin,
    required this.defaultServings,
  });
}

class _AddRecipeDialogNew extends StatefulWidget {
  final String Function(String) t;
  final Settings settings;
  final RecipeModel? editingRecipe;
  const
// moved to part file
r(text: '10');
  final _cookCtrl = TextEditingController(text: '15');
  final _servingsCtrl = TextEditingController(text: '2');
  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.editingRecipe != null) {
      _titleCtrl.text = widget.editingRecipe!.title;
      _prepCtrl.text = widget.editingRecipe!.prepMin.toString();
      _cookCtrl.text = widget.editingRecipe!.cookMin.toString();
      _servingsCtrl.text = widget.editingRecipe!.defaultServings.toString();
      for (var ing in widget.editingRecipe!.ingredients) {
        _ingredientControllers.add({
          'name': TextEditingController(text: ing.name),
          'qty': TextEditingController(text: ing.qty.toString()),
          'unit': TextEditingController(text: ing.unit),
        });
      }
      for (var step in widget.editingRecipe!.steps) {
        _stepControllers.add(TextEditingController(text: step));
      }
    } else {
      _addIngredientField();
      _addStepField();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose
// moved to part file
etUnitOptions(widget.settings.units).contains(ctrlMap['unit']!.text)
                                  ? ctrlMap['unit']!.text
                                  : null,
                              hint: const Text('Unit'),
                              onChanged: (String? newValue) {
                                setState(() {
                                  ctrlMap['unit']!.text = newValue ?? '';
                                });
                              },
                              items: _getUnitOptions(widget.settings.units).map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeIngredientField(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: _addIngredientField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                ),
                const SizedBox(height: 12),
                Text(
                  t('steps'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stepControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _stepControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Step ${index + 1}',
                              ),
                            ),
                          ),
                          IconButton(
      
// moved to part file
unction(String) t = (String k) => i18n[lang]![k] ?? k;

    return AlertDialog(
      title: Text(t('settings')),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _sectionTitle(t('language')),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: Text(i18n['en']!['english']!),
                  selected: language == AppLanguage.en,
                  onSelected: (_) => setState(() => language = AppLanguage.en),
                ),
                ChoiceChip(
                  label: Text(i18n['es']!['spanish']!),
                  selected: language == AppLanguage.es,
                  onSelected: (_) => setState(() => language = AppLanguage.es),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionTitle(t('units')),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: Text(i18n[lang]!['metric']!),
                  selected: units == AppUnits.metric,
                  onSelected: (_) => setState(() => units = AppUnits.metric),
                ),
                ChoiceChip(
                  label: Text(i18n[lang]!['imperial']!),
                  selected: units == AppUnits.imperial,
                  onSelected: (_) => setState(() => units = AppUnits.imperial),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionTitle(t('currency')),
            DropdownButton<AppCurrency>(
              value: currency,
              items: const <DropdownMenuItem<AppCurrency>>[
                DropdownMenuItem<AppCurrency>(
                  value: AppCurrency.eur,
                  child: Text('EUR (€)'),
                ),
                DropdownMenuItem<AppCurrency>(
                  value: AppCurrency.usd,
                  child: Text('USD (\$)'),
                ),
              ],
              onChanged: (AppCurrency? v) =>
                  setState(() => currency = v ?? AppCurrency.eur),
            ),
            const SizedBox(height: 12),
            _sectionTitle(t('theme')),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: Text(i18n[lang]!['light']!),
                  selected: theme == AppTheme.light,
                  onSelected: (_) => setState(() => theme = AppTheme.light),
                ),
                ChoiceChip(
                  label: Text(i18n[lang]!['dark']!),
                  selected: theme == AppTheme.dark,
                  onSelected: (_) => setState(() => theme = AppTheme.dark),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(i18n[lang]!['cancel']!),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              Settings(
                language: language,
                units: units,
                currency: currency,
                theme: theme,
              ),
            );
          },
          child: Text(i18n[lang]!['save']!),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

void _addTimer(TimerSettings settings) {
  setState(() {
    _timerManager.addTimer(settings);
  });
}

void _pauseTimer(TimerInstance timer) {
  setState(() {
    _timerManager.pause(timer);
  });
}

void _resumeTimer(TimerInstance timer) {
  setState(() {
    _timerManager.resume(timer);
  });
}

void _restartTimer(TimerInstance timer) {
  setState(() {
    _timerManager.restart(timer);
  });
}

void _startGlobalTick() {
  // no-op: TimerManager starts ticker automatically
}
}
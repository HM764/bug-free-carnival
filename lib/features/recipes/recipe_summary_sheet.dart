part of app;

void showRecipeSummary(RecipeModel r, String Function(String) t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final isActiveCooking = _currentRecipe != null && _currentRecipe!.id != r.id;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t('summary')}: ${r.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text('${t('prep')}: ${r.prepMin} ${t('min')}'),
                  ),
                  Expanded(
                    child: Text(
                      '${t('cooking_label')}: ${r.cookMin} ${t('min')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                t('ingredients_label'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...r.ingredients.map(
                (ing) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(ing.name),
                  trailing: Text(
                    '${ing.qty % 1 == 0 ? ing.qty.toStringAsFixed(0) : ing.qty.toStringAsFixed(2)} ${ing.unit}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final updated = await showDialog<_NewRecipeResult>(
                          context: context,
                          builder: (_) => _AddRecipeDialogNew(
                            t: t,
                            settings: widget.settings,
                            editingRecipe: r,
                          ),
                        );
                        if (updated != null) {
                          final newRecipe = RecipeModel(
                            id: r.id,
                            title: updated.title,
                            ingredients: updated.ingredients,
                            steps: updated.steps,
                            prepMin: updated.prepMin,
                            cookMin: updated.cookMin,
                            defaultServings: updated.defaultServings,
                          );
                          setState(() {
                            final index = recipes.indexWhere((rec) => rec.id == r.id);
                            if (index != -1) recipes[index] = newRecipe;
                            if (_currentRecipe?.id == r.id) {
                              _setCurrentRecipe(newRecipe, reset: true);
                            }
                          });
                        }
                      },
                      child: Text(t('edit')),
                    ),
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(t('delete_recipe')),
                            content: Text(t('confirm_delete_recipe')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(t('cancel')),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(t('delete')),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() {
                            recipes.removeWhere((rec) => rec.id == r.id);
                            _plan.removeWhere((e) => e.recipeId == r.id);
                            _favorites.remove(r.id);
                            if (_currentRecipe?.id == r.id) {
                              _setCurrentRecipe(recipes.isNotEmpty ? recipes.first : null, reset: true);
                            }
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(t('delete')),
                    ),
                    if (isActiveCooking)
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _tab.animateTo(3);
                        },
                        child: Text(t('return_to_cooking')),
                      ),
                    FilledButton.icon(
                      icon: const Icon(Icons.restaurant_menu),
                      label: Text(t('cook_now')),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _setCurrentRecipe(r, reset: true);
                        _tab.animateTo(3);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  String nextRecipeId() {
    int maxId = 0;
    for (final r in recipes) {
      final id = int.tryParse(r.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    return '${maxId + 1}';
  }

  Widget _recipeBoxTab(BuildContext context, String Function(String) t) {
    String query = '';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setInner) {
        List<RecipeModel> list = recipes
            .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        list.sort((a, b) {
          final int fa = _favorites.contains(a.id) ? 0 : 1;
          final int fb = _favorites.contains(b.id) ? 0 : 1;
          final int byFav = fa.compareTo(fb);
          if (byFav != 0) return byFav;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: t('search'),
                ),
                onChanged: (String v) => setInner(() {
                  query = v;
                }),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    final RecipeModel r = list[i];
                    final bool fav = _favorites.contains(r.id);
                    return Card(
                      child: ListTile(
                        title: Text(r.title),
                        subtitle: Text(
                          '${r.ingredients.length} ingredients · ${r.steps.length} steps',
                        ),
                        trailing: IconButton(
                          tooltip: fav ? t('unfavorite') : t('favorite'),
                          icon: Icon(fav ? Icons.star : Icons.star_border),
                          onPressed: () => setState(() {
                            if (fav) {
                              _favorites.remove(r.id);
                            } else {
                              _favorites.add(r.id);
                            }
                          }),
                        ),
                        onTap: () {
                          showRecipeSummary(r, t);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _recipesInPlannerTab(
    BuildContext context,
    String Function(String) t,
    Set<String> usedIds,
  ) {
    final List<RecipeModel> list =
        recipes.where((r) => usedIds.contains(r.id)).toList()..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            );
    if (list.isEmpty) return Center(child: Text(t('no_meals')));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (BuildContext context, int i) {
        final RecipeModel r = list[i];
        final bool fav = _favorites.contains(r.id);
        return Card(
          child: ListTile(
            title: Text(r.title),
            trailing: IconButton(
              tooltip: fav ? t('unfavorite') : t('favorite'),
              icon: Icon(fav ? Icons.star : Icons.star_border),
              onPressed: () => setState(() {
                if (fav) {
                  _favorites.remove(r.id);
                } else {
                  _favorites.add(r.id);
                }
              }),
            ),
            onTap: () {
              showRecipeSummary(r, t);
            },
          ),
        );
      },
    );
  }


  RecipeModel recipeById(String id) => recipes.firstWhere((r) => r.id == id);

  String _mealLabel(String meal, String Function(String) t) {
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

  num convertQty(num qty, String unit, AppUnits units) {
    if (units == AppUnits.metric) return qty;
    switch (unit) {
      case 'g':
        return qty / 28.3495;
      case 'kg':
        return qty * 2.20462;
      case 'ml':
        return qty / 29.5735;
      case 'l':
        return qty * 33.814;
      case 'tsp':
        return qty * 0.166667;
      case 'tbsp':
        return qty * 0.0625;
      case 'cup':
        return qty;
      case 'unit':
        return qty;
      default:
        return qty;
    }
  }

  String unitLabel(String unit, AppUnits units) {
    if (units == AppUnits.metric) {
      return unit;
    }
    switch (unit) {
      case 'g':
        return 'oz';
      case 'kg':
        return 'lb';
      case 'ml':
        return 'fl oz';
      case 'l':
        return 'pt';
      case 'tsp':
        return 'tsp';
      case 'tbsp':
        return 'tbsp';
      case 'cup':
        return 'cup';
      case 'unit':
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

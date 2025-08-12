part of app;

Widget recipesInPlannerScreen(
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
              _showRecipeSummary(r, t);
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

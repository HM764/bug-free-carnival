part of app;

Widget shoppingTab(_HomeState s, BuildContext context, String Function(String) t) {

    final Map<String, Map<String, num>> totals = <String, Map<String, num>>{};
    for (final PlanEntry e in s._plan) {
      final RecipeModel r = recipeById(e.recipeId);
      for (final Ingredient ing in r.ingredients) {
        final String key = unitLabel(ing.unit, widget.settings.units);
        totals.putIfAbsent(key, () => <String, num>{});
        final num convertedQty = convertQty(
          ing.qty,
          ing.unit,
          widget.settings.units,
        );
        totals[key]![ing.name] = (totals[key]![ing.name] ?? 0) + convertedQty;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            t('shopping'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (totals.isEmpty) Text(t('no_meals')),
          if (totals.isNotEmpty)
            Expanded(
              child: ListView(
                children: totals.entries.map<Widget>((
                  MapEntry<String, Map<String, num>> byUnit,
                ) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        byUnit.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...byUnit.value.entries.map<Widget>(
                        (MapEntry<String, num> e) => ListTile(
                          title: Text(e.key),
                          trailing: Text(fmt(e.value)),
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          Text(t('price_demo')),
        ],
      ),
    );
  
}

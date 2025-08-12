part of app;

Widget plannerTab(_HomeState s, BuildContext context, String Function(String) t, List<String> days) {

    final List<List<PlanEntry>> entriesPerDay = List.generate(
      7,
      (i) => s._plan.where((e) => e.dayIndex == i).toList(),
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('plan_week'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.unfold_less),
                    label: Text(t('collapse_all')),
                    onPressed: () => s.setState(() {
                      for (var i = 0; i < 7; i++)
                        if (entriesPerDay[i].isNotEmpty) s._collapsed[i] = true;
                    }),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.unfold_more),
                    label: Text(t('expand_all')),
                    onPressed: () => s.setState(() {
                      for (var i = 0; i < 7; i++)
                        if (entriesPerDay[i].isNotEmpty) s._collapsed[i] = false;
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, i) {
                final entries = entriesPerDay[i];
                final hasMeals = entries.isNotEmpty;
                final collapsed = s._collapsed[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    days[i],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (hasMeals)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer,
                                      ),
                                      child: Text(
                                        '${entries.length} ${t('meals')}',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (hasMeals)
                              IconButton(
                                tooltip: collapsed
                                    ? t('expand')
                                    : t('collapse'),
                                icon: Icon(
                                  collapsed
                                      ? Icons.expand_more
                                      : Icons.expand_less,
                                ),
                                onPressed: () =>
                                    s.setState(() => s._collapsed[i] = !collapsed),
                              ),
                            IconButton(
                              tooltip: t('add_meal'),
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                final added = await showDialog<AddMealResult>(
                                  context: context,
                                  builder: (_) => s._AddMealDialog(
                                    t: t,
                                    favorites: s._favorites,
                                    initialRecipe: s._currentRecipe,
                                    languageKey:
                                        widget.settings.language ==
                                                AppLanguage.en
                                            ? 'en'
                                            : 'es',
                                  ),
                                );
                                if (added != null) {
                                  s.setState(() {
                                    s._plan.add(
                                      PlanEntry(
                                        dayIndex: i,
                                        mealType: added.mealType,
                                        recipeId: added.recipeId,
                                      ),
                                    );
                                    s._collapsed[i] =
                                        false;
                                  });
                                }
                              },
                            ),
                            if (hasMeals)
                              IconButton(
                                tooltip: t('clear_day'),
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(t('clear_day')),
                                      content: Text(t('confirm_clear')),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(t('cancel')),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(t('save')),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    final removed = List<PlanEntry>.from(
                                      entries,
                                    );
                                    s.setState(
                                      () => s._plan.removeWhere(
                                        (e) => e.dayIndex == i,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${days[i]} — ${removed.length} ${t('meals')}',
                                        ),
                                        action: SnackBarAction(
                                          label: t('undo'),
                                          onPressed: () => s.setState(
                                            () => s._plan.addAll(removed),
                                          ),
                                        ),
                                      ),
                                    );
                                    s.setState(() => s._collapsed[i] = true);
                                  }
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (hasMeals && !collapsed)
                          s._reorderableDayList(i, entries, t),
                        if (!hasMeals)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(t('no_meals')),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  
}

part of app;

Widget cookingTab(_HomeState s, BuildContext context, String Function(String) t) {

    final RecipeModel recipe = s._currentRecipe ?? recipes.first;
    final steps = stepsForDisplay(recipe, widget.settings.language);
    final customTimers = s._timers.where((t) => t.stepIndex == null).toList();
    if (s._completedSteps.length != steps.length) {
      s._completedSteps = List<bool>.filled(steps.length, false);
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${t('cooking')}: ${recipe.title}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: <Widget>[
              Text('${t('servings')}: '),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: s._servings,
                items: const <int>[1, 2, 3, 4, 5, 6]
                    .map<DropdownMenuItem<int>>(
                      (int s) =>
                          DropdownMenuItem<int>(value: s, child: Text('$s')),
                    )
                    .toList(),
                onChanged: (int? v) => s.setState(() => s._servings = v ?? recipe.defaultServings),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final timerSettings = await showDialog<TimerSettings>(
                    context: context,
                    builder: (_) => TimerDialog(t: t, steps: steps),
                  );
                  if (timerSettings != null) {
                    s._addTimer(timerSettings);
                  }
                },
                icon: const Icon(Icons.timer),
                label: Text(t('start_timer')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t('ingredients_scaled'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...recipe.ingredients.map<Widget>((Ingredient ing) {
            final num scaled = ing.qty * s._servings / recipe.defaultServings;
            final num converted = convertQty(
              scaled,
              ing.unit,
              widget.settings.units,
            );
            final String label = unitLabel(ing.unit, widget.settings.units);
            return ListTile(
              title: Text('${ing.name} — ${fmt(converted)} $label'),
            );
          }),
          const Divider(),
          Text(t('steps'), style: const TextStyle(fontWeight: FontWeight.bold)),
          if (customTimers.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: customTimers.map((timer) => Row(
                children: [
                  Text(timer.name),
                  const SizedBox(width: 8),
                  Text('${timer.remainingSeconds}${t('seconds')}'),
                  IconButton(
                    icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (timer.isRunning) {
                        s._pauseTimer(timer);
                      } else {
                        s._resumeTimer(timer);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.restart_alt),
                    onPressed: () => s._restartTimer(timer),
                  ),
                ],
              )).toList(),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (BuildContext context, int i) => ListTile(
                leading: InkWell(
                  onTap: () => s.setState(() => s._completedSteps[i] = !s._completedSteps[i]),
                  child: CircleAvatar(
                    backgroundColor: s._completedSteps[i] ? Colors.green : null,
                    child: s._completedSteps[i] ? const Icon(Icons.check) : Text('${i + 1}'),
                  ),
                ),
                title: Text(steps[i]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: s._timers.where((t) => t.stepIndex == i).map((timer) => Row(
                    children: [
                      Text('${timer.remainingSeconds}${t('seconds')}'),
                      IconButton(
                        icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                        onPressed: () {
                          if (timer.isRunning) {
                            s._pauseTimer(timer);
                          } else {
                            s._resumeTimer(timer);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt),
                        onPressed: () => s._restartTimer(timer),
                      ),
                    ],
                  )).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  
}

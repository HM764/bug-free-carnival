part of app;

Widget recipesTab(_HomeState s, BuildContext context, String Function(String) t) {

    final Set<String> usedIds = s._plan.map<String>((e) => e.recipeId).toSet();
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              TabBar(
                tabs: <Widget>[
                  Tab(text: t('recipe_box')),
                  Tab(text: t('in_planner')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    recipeBoxScreen(context, t),
                    recipesInPlannerScreen(context, t, usedIds),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final created = await showDialog<s._NewRecipeResult>(
                context: context,
                builder: (_) => AddRecipeDialogNew(t: t, settings: s.widget.settings),
              );
              if (created != null) {
                s.setState(() {
                  final newId = nextRecipeId();
                  recipes.add(
                    RecipeModel(
                      id: newId,
                      title: created.title,
                      ingredients: created.ingredients,
                      steps: created.steps,
                      prepMin: created.prepMin,
                      cookMin: created.cookMin,
                      defaultServings: created.defaultServings,
                    ),
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${t('add_recipe')}: "${created.title}"'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: Text(t('add_recipe')),
          ),
        ),
      ],
    );
  
}

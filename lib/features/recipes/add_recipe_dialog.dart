part of app;

class NewRecipeResult {
  final String title;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final int prepMin;
  final int cookMin;
  final int defaultServings;
  _NewRecipeResult({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.prepMin,
    required this.cookMin,
    required this.defaultServings,
  });
}

class AddRecipeDialogNew extends StatefulWidget {
  final String Function(String) t;
  final Settings settings;
  final RecipeModel? editingRecipe;
  const _AddRecipeDialogNew({
    required this.t,
    required this.settings,
    this.editingRecipe,
  });

  @override
  State<_AddRecipeDialogNew> createState() => _AddRecipeDialogNewState();
}

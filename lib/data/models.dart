// Generated from monolith: settings + models
enum AppLanguage { en, es }

enum AppUnits { metric, imperial }

enum AppCurrency { eur, usd }

enum AppTheme { light, dark }

class Settings {
  AppLanguage language;
  AppUnits units;
  AppCurrency currency;
  AppTheme theme;
  Settings({
    required this.language,
    required this.units,
    required this.currency,
    required this.theme,
  });
}

class Ingredient {
  final String name;
  final double qty;
  final String unit;
  const Ingredient(this.name, this.qty, this.unit);
}

class RecipeModel {
  final String id;
  final String title;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final int prepMin;
  final int cookMin;
  final int defaultServings;
  const RecipeModel({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.prepMin = 10,
    this.cookMin = 15,
    this.defaultServings = 2,
  });
}

class PlanEntry {
  final int dayIndex;
  final String mealType;
  final String recipeId;
  PlanEntry({
    required this.dayIndex,
    required this.mealType,
    required this.recipeId,
  });
}

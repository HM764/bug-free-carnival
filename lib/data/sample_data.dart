import '../data/models.dart';

// Generated from monolith: recipes and English step overrides
final recipes = <RecipeModel>[
  RecipeModel(
    id: '1',
    title: 'Ensalada Mediterránea',
    ingredients: [
      Ingredient('Tomate', 2, 'unit'),
      Ingredient('Pepino', 1, 'unit'),
      Ingredient('Aceite de oliva', 2, 'tbsp'),
      Ingredient('Queso feta', 100, 'g'),
    ],
    steps: [
      'Corta tomate y pepino.',
      'Mezcla con aceite y feta.',
      'Sal al gusto. ¡Listo!',
    ],
    prepMin: 10,
    cookMin: 0,
    defaultServings: 2,
  ),
  RecipeModel(
    id: '2',
    title: 'Pollo al Horno',
    ingredients: [
      Ingredient('Pechuga de pollo', 2, 'unit'),
      Ingredient('Pimentón', 1, 'tbsp'),
      Ingredient('Ajo', 2, 'unit'),
      Ingredient('Aceite de oliva', 1, 'tbsp'),
    ],
    steps: [
      'Precalienta el horno a 200°C.',
      'Marina el pollo con ajo y pimentón.',
      'Hornea 20–25 min.',
    ],
    prepMin: 10,
    cookMin: 25,
    defaultServings: 2,
  ),
  RecipeModel(
    id: '3',
    title: 'Crema de Calabaza',
    ingredients: [
      Ingredient('Calabaza', 400, 'g'),
      Ingredient('Cebolla', 1, 'unit'),
      Ingredient('Caldo', 400, 'ml'),
    ],
    steps: ['Sofríe cebolla.', 'Añade calabaza y caldo.', 'Cocina y tritura.'],
    prepMin: 10,
    cookMin: 20,
    defaultServings: 2,
  ),
  RecipeModel(
    id: '4',
    title: 'Pasta con Pesto',
    ingredients: [
      Ingredient('Pasta', 200, 'g'),
      Ingredient('Pesto', 50, 'g'),
      Ingredient('Tomates cherry', 100, 'g'),
    ],
    steps: [
      'Hierve la pasta.',
      'Escurre y mezcla con pesto.',
      'Añade tomates cherry.',
    ],
    prepMin: 5,
    cookMin: 10,
    defaultServings: 2,
  ),
  RecipeModel(
    id: '5',
    title: 'Salmón al Horno con Espárragos',
    ingredients: [
      Ingredient('Salmón', 150, 'g'),
      Ingredient('Espárragos', 100, 'g'),
      Ingredient('Limón', 1, 'unit'),
    ],
    steps: [
      'Precalienta el horno a 180°C.',
      'Coloca el salmón y espárragos en una bandeja.',
      'Hornea por 15 minutos con rodajas de limón.',
    ],
    prepMin: 5,
    cookMin: 15,
    defaultServings: 2,
  ),
  RecipeModel(
    id: '6',
    title: 'Tortilla de Verduras',
    ingredients: [
      Ingredient('Huevos', 3, 'unit'),
      Ingredient('Pimiento', 0.5, 'unit'),
      Ingredient('Calabacín', 0.5, 'unit'),
    ],
    steps: [
      'Bate los huevos.',
      'Sofríe las verduras picadas.',
      'Mezcla y cocina hasta cuajar.',
    ],
    prepMin: 10,
    cookMin: 8,
    defaultServings: 2,
  ),
];

// Minimal EN translations for demo steps (keys = recipe.id)
final Map<String, List<String>> stepsEnById = {
  '1': [
    'Chop tomato and cucumber.',
    'Mix with olive oil and feta.',
    'Salt to taste. Done!',
  ],
  '2': [
    'Preheat oven to 200°C.',
    'Marinate chicken with garlic and paprika.',
    'Bake 20–25 min.',
  ],
  '3': ['Sauté onion.', 'Add squash and stock.', 'Cook and blend.'],
  '4': ['Boil pasta.', 'Drain and toss with pesto.', 'Add cherry tomatoes.'],
  '5': [
    'Preheat oven to 180°C.',
    'Place salmon and asparagus on a tray.',
    'Bake ~15 min with lemon slices.',
  ],
  '6': [
    'Beat the eggs.',
    'Sauté chopped veggies.',
    'Combine and cook until set.',
  ],
};


RecipeModel recipeById(String id) => recipes.firstWhere((r) => r.id == id);

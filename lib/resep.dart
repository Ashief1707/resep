class Recipe {
  int? id;
  String name;
  String preparationTime;
  String ingredients;
  String instructions;

  Recipe({
    this.id,
    required this.name,
    required this.preparationTime,
    required this.ingredients,
    required this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'preparation_time': preparationTime,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      name: map['name'] as String,
      preparationTime: map['preparation_time'] as String,
      ingredients: map['ingredients'] as String,
      instructions: map['instructions'] as String,
    );
  }
}

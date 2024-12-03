import 'package:flutter/material.dart';
import 'package:proyek_todolist/database_helper.dart';
import 'package:proyek_todolist/resep.dart';
import 'package:proyek_todolist/recipe_detail_screen.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RecipeList(),
    );
  }
}

class RecipeList extends StatefulWidget {
  const RecipeList({super.key});

  @override
  State<StatefulWidget> createState() => _RecipeList();
}

class _RecipeList extends State<RecipeList> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _preparationTimeCtrl = TextEditingController();
  final TextEditingController _ingredientsCtrl = TextEditingController();
  final TextEditingController _instructionsCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Recipe> recipeList = [];
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async {
    final recipes = await dbHelper.getAllRecipes();
    setState(() {
      recipeList = recipes;
    });
  }

  void addRecipe() async {
    final newRecipe = Recipe(
      name: _nameCtrl.text,
      preparationTime: _preparationTimeCtrl.text,
      ingredients: _ingredientsCtrl.text,
      instructions: _instructionsCtrl.text,
    );
    await dbHelper.addRecipe(newRecipe);
    refreshList();

    // Clear input fields
    _nameCtrl.clear();
    _preparationTimeCtrl.clear();
    _ingredientsCtrl.clear();
    _instructionsCtrl.clear();
  }

  void deleteRecipe(int id) async {
    await dbHelper.deleteRecipe(id);
    refreshList();
  }

  void searchRecipe() async {
    String keyword = _searchCtrl.text.trim();
    List<Recipe> recipes = [];
    if (keyword.isEmpty) {
      recipes = await dbHelper.getAllRecipes();
    } else {
      recipes = await dbHelper.searchRecipe(keyword);
    }
    setState(() {
      recipeList = recipes;
    });
  }

  void showAddRecipeForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(20),
        title: const Text("Tambah Resep"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Tutup"),
          ),
          ElevatedButton(
            onPressed: () {
              addRecipe();
              Navigator.pop(context);
            },
            child: const Text("Tambah"),
          ),
        ],
        content: SizedBox(
          height: 300,
          child: Column(
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Nama Resep'),
              ),
              TextField(
                controller: _preparationTimeCtrl,
                decoration: const InputDecoration(hintText: 'Waktu Persiapan'),
              ),
              TextField(
                controller: _ingredientsCtrl,
                decoration: const InputDecoration(hintText: 'Bahan-bahan'),
              ),
              TextField(
                controller: _instructionsCtrl,
                 maxLines: 5,
                decoration: const InputDecoration(hintText: 'Langkah-langkah'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Resep'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddRecipeForm,
        child: const Icon(Icons.add_box),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) {
                searchRecipe();
              },
              decoration: const InputDecoration(
                hintText: 'Klik disini untuk cari resep...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recipeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recipeList[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  subtitle: Text('Waktu: ${recipeList[index].preparationTime}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteRecipe(recipeList[index].id ?? 0);
                    },
                  ),
                  onTap: () {
// Navigasi ke RecipeDetailScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          recipe: recipeList[index],
                          onDelete: refreshList,
                          onEdit: refreshList,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

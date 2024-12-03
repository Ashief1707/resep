import 'package:flutter/material.dart';
import 'package:proyek_todolist/database_helper.dart';
import 'package:proyek_todolist/resep.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const RecipeDetailScreen({
    required this.recipe,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _currentRecipe;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
  }

  void deleteRecipe(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteRecipe(_currentRecipe.id ?? 0);
    widget.onDelete(); // Refresh list in RecipeList
    Navigator.pop(context);
  }

  void editRecipe(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController =
        TextEditingController(text: _currentRecipe.name);
    final TextEditingController _timeController =
        TextEditingController(text: _currentRecipe.preparationTime);
    final TextEditingController _ingredientsController =
        TextEditingController(text: _currentRecipe.ingredients);
    final TextEditingController _instructionsController =
        TextEditingController(text: _currentRecipe.instructions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Resep'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Resep'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama resep tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: 'Waktu Persiapan'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Waktu persiapan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(labelText: 'Bahan-bahan'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bahan-bahan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(labelText: 'Langkah-langkah'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Langkah-langkah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final dbHelper = DatabaseHelper();
                  final updatedRecipe = Recipe(
                    id: _currentRecipe.id,
                    name: _nameController.text,
                    preparationTime: _timeController.text,
                    ingredients: _ingredientsController.text,
                    instructions: _instructionsController.text,
                  );

                  await dbHelper.updateRecipe(updatedRecipe);

                  // Perbarui data lokal
                  setState(() {
                    _currentRecipe = updatedRecipe;
                  });

                  widget.onEdit(); // Refresh the list
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRecipe.name, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waktu Persiapan: ${_currentRecipe.preparationTime}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Bahan-bahan:', style: const TextStyle(fontSize: 16)),
            Text(_currentRecipe.ingredients, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Text('Langkah-langkah:', style: const TextStyle(fontSize: 16)),
            Text(_currentRecipe.instructions, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => deleteRecipe(context),
                  child: const Text('Hapus'),
                ),
                ElevatedButton(
                  onPressed: () => editRecipe(context),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'resep.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'recipes.db');
    var localDb = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return localDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        preparation_time TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        instructions TEXT NOT NULL
      )
    ''');
  }

  // Fungsi untuk mengambil semua resep
  Future<List<Recipe>> getAllRecipes() async {
    var dbClient = await db;
    var recipes = await dbClient!.query('recipes');
    return recipes.map((recipe) => Recipe.fromMap(recipe)).toList();
  }

  // Fungsi untuk mencari resep berdasarkan keyword
  Future<List<Recipe>> searchRecipe(String keyword) async {
    var dbClient = await db;
    var recipes = await dbClient!.query(
      'recipes',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
    return recipes.map((recipe) => Recipe.fromMap(recipe)).toList();
  }

  // Fungsi untuk menambahkan resep baru
  Future<int> addRecipe(Recipe recipe) async {
    var dbClient = await db;
    return await dbClient!.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fungsi untuk mengupdate resep
  Future<int> updateRecipe(Recipe recipe) async {
    var dbClient = await db;
    return await dbClient!.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  // Fungsi untuk menghapus resep berdasarkan ID
  Future<int> deleteRecipe(int id) async {
    var dbClient = await db;
    return await dbClient!.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

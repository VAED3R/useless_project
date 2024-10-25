import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeGeneratorScreen(),
    );
  }
}

class Recipe {
  final String name;
  final List<String> ingredients;
  final String instructions;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: json['instructions'],
    );
  }
}

class RecipeGeneratorScreen extends StatefulWidget {
  @override
  _RecipeGeneratorScreenState createState() => _RecipeGeneratorScreenState();
}

class _RecipeGeneratorScreenState extends State<RecipeGeneratorScreen> {
  List<Recipe> allRecipes = [];
  List<Recipe> matchedRecipes = [];
  List<String> userIngredients = [];

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    // Load recipe data from JSON file in assets
    final String data = await rootBundle.loadString('assets/recipes.json');
    final List<dynamic> jsonResult = json.decode(data)['recipes'];
    setState(() {
      allRecipes = jsonResult.map((recipe) => Recipe.fromJson(recipe)).toList();
    });
  }

  void findRecipes() {
    setState(() {
      matchedRecipes = allRecipes.where((recipe) {
        return recipe.ingredients.every((ingredient) => userIngredients.contains(ingredient));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter ingredients, separated by commas',
              ),
              onSubmitted: (value) {
                setState(() {
                  userIngredients = value.split(',').map((e) => e.trim()).toList();
                });
                findRecipes();
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: matchedRecipes.isEmpty
                  ? Center(child: Text('No recipes found. Try different ingredients!'))
                  : ListView.builder(
                      itemCount: matchedRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = matchedRecipes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(recipe.name),
                            subtitle: Text(recipe.instructions),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

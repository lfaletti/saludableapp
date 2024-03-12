import 'dart:convert';
import 'package:flutter/services.dart';
import 'nutrition_info.dart';

class DefinitionService {
  Future<NutritionInfo?> getDefinition(String name) async {
  // Load the JSON file.
  String jsonString = await rootBundle.loadString('assets/definitions.json');

  // Decode the JSON to a map.
  Map<String, dynamic> jsonData = jsonDecode(jsonString);

  // Get the "definitions" list from the JSON data.
  List<dynamic> definitions = jsonData['definitions'];

  // Find the definition with the given name.
  Map<String, dynamic>? definition = definitions.firstWhere(
    (def) => def['name'] == name || (def['additional_names'] as List<dynamic>).contains(name),
    orElse: () => null,
  );

  if (definition != null) {
    // Create a NutritionInfo object with the definition details.
    NutritionInfo nutritionInfo = NutritionInfo(
      name: definition['name'],
      description: definition['description'],
      ratingLevel: definition['rating_level'],
    );

    // Return the NutritionInfo object.
    return nutritionInfo;
  }

  // If no definition with the given name is found, return null.
  return null;
}

  Future<List<String>> getAllNames() async {
  // Load the JSON file.
  String jsonString = await rootBundle.loadString('assets/definitions.json');

  // Decode the JSON to a map.
  Map<String, dynamic> jsonData = jsonDecode(jsonString);

  // Get the "definitions" list from the JSON data.
  List<dynamic> definitions = jsonData['definitions'];

  // Create a list to store all names.
  List<String> allNames = [];

  // Iterate through each definition and add the name and additional names to the list.
  for (var definition in definitions) {
    allNames.add(definition['name']);
    if (definition['additional_names'] != null && definition['additional_names'].isNotEmpty) {
      for (var name in definition['additional_names']) {
        if (name is String) {
          allNames.add(name);
        }
      }
    }
  }

  // Return the list of all names.
  return allNames;
}
}
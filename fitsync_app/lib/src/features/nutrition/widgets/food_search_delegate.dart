import 'package:flutter/material.dart';
import '../data/food_database.dart';

class FoodSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final results = kFoodDatabase.where((food) {
      final name = food['name'].toString().toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return ListTile(
          title: Text(food['name']),
          subtitle: Text(
            '${food['calories']} kcal | P: ${food['protein']}g C: ${food['carbs']}g F: ${food['fat']}g',
          ),
          onTap: () => close(context, food),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import '../providers/nutrition_provider.dart';
import 'food_search_delegate.dart';

class LogMealModal extends ConsumerStatefulWidget {
  const LogMealModal({super.key});

  @override
  ConsumerState<LogMealModal> createState() => _LogMealModalState();
}

class _LogMealModalState extends ConsumerState<LogMealModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        protein: int.tryParse(_proteinController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
        fat: int.tryParse(_fatController.text) ?? 0,
        timestamp: DateTime.now(),
      );

      ref.read(dailyLogProvider.notifier).addMeal(meal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Log Meal', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Meal Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final result = await showSearch(
                      context: context,
                      delegate: FoodSearchDelegate(),
                    );
                    if (result != null) {
                      setState(() {
                        _nameController.text = result['name'];
                        _caloriesController.text = result['calories']
                            .toString();
                        _proteinController.text = result['protein'].toString();
                        _carbsController.text = result['carbs'].toString();
                        _fatController.text = result['fat'].toString();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(labelText: 'Protein (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(labelText: 'Carbs (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(labelText: 'Fat (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: const Text('Add Meal')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

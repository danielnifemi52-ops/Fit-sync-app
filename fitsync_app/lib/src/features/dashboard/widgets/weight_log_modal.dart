import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// We need a provider to save weight. I'll add `logWeight` to MealsNotifier (renaming to DailyLogNotifier would be better but keeping it simple)
import '../../nutrition/providers/nutrition_provider.dart';

class WeightLogModal extends ConsumerStatefulWidget {
  const WeightLogModal({super.key});

  @override
  ConsumerState<WeightLogModal> createState() => _WeightLogModalState();
}

class _WeightLogModalState extends ConsumerState<WeightLogModal> {
  final _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Log Weight', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              suffixText: 'kg',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(_weightController.text);
              if (weight != null) {
                ref.read(dailyLogProvider.notifier).logWeight(weight);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Weight logged saved')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Weight'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

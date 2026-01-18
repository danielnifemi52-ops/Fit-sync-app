import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../../core/providers/user_data_provider.dart';

class WeightLogModal extends ConsumerStatefulWidget {
  const WeightLogModal({super.key});

  @override
  ConsumerState<WeightLogModal> createState() => _WeightLogModalState();
}

class _WeightLogModalState extends ConsumerState<WeightLogModal> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    final unitSystem = userData.unitSystem;
    final weightUnit = unitSystem == 'imperial' ? 'lbs' : 'kg';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Log Weight', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Weight ($weightUnit)',
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final input = double.tryParse(_controller.text);
              if (input != null) {
                // Convert to kg if imperial
                final weightKg = unitSystem == 'imperial'
                    ? input / 2.20462
                    : input;
                ref.read(dailyLogProvider.notifier).logWeight(weightKg);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

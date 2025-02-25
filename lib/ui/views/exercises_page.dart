import 'package:coairence/ui/widgets/breath_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';

class ExercisesPage extends ConsumerWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startPageState = ref.watch(breathPageProvider);
    final selectedPatternIndex =
        ref.watch(breathPageProvider).selectedPatternIndex;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
      ),
      itemCount: startPageState.patterns.length,
      itemBuilder: (context, index) {
        final pattern = startPageState.patterns[index];
        final isSelected = index == selectedPatternIndex;

        return GestureDetector(
          onTap:
              () => ref
                  .read(breathPageProvider.notifier)
                  .updateSelectedPattern(index),
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(pattern.description),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimary,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).canvasColor,
            ),
            child: BreathGuide(
              pattern: pattern,
              totalRepetitions: 1,
              onExerciseCompleted: () {},
            ),
          ),
        );
      },
    );
  }
}

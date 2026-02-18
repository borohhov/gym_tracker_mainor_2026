import 'package:flutter/material.dart';
import 'package:gym_tracker/controllers/exercise_log_provider.dart';
import 'package:gym_tracker/views/exercise_log_list.dart';
import 'package:provider/provider.dart';

import 'exercise_log_entry_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Log'),
        centerTitle: false,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: context.watch<ExerciseLogProvider>().getAllLogs(),
        builder: (context, asyncSnapshot) {
          if(asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading');
          }
          var items = asyncSnapshot.data ?? [];
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items.isEmpty
                        ? 'No exercises yet'
                        : '${items.length} exercise${items.length == 1 ? '' : 's'} logged',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List container (card-like) so it doesn’t feel “floating in space”
                  Expanded(
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 1,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: items.isEmpty
                            ? Center(
                          child: Text(
                            'Tap + to add your first exercise',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                            : ExerciseLogListWidget(exerciseLog: items),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Exercise',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Exercise'),
                content: const ExerciseLogEntryForm(),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

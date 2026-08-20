import 'package:coairence/data/models/exercise_session.dart';
import 'package:material_ui/material_ui.dart';

class SessionHistoryItem extends StatelessWidget {
  const SessionHistoryItem({required this.session, super.key});

  final ExerciseSession session;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = Duration(seconds: session.durationSeconds);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.air, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(
        session.patternName,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        '${session.cyclesCompleted} cycles • ${duration.inMinutes}m ${duration.inSeconds % 60}s',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        _formatDate(session.timestamp),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

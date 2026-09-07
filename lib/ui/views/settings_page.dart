import 'dart:async';

import 'package:coairence/ui/viewmodels/settings_page_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// App-wide settings: sensory feedback for breathing exercises.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      // Graceful fallback: show the last known good state or defaults
      error: (e, _) =>
          _buildSettingsContent(context, ref, const SettingsState()),
      data: (settings) => _buildSettingsContent(context, ref, settings),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        8,
        24,
        8,
        MediaQuery.of(context).padding.bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                'Sensory Feedback',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text(
                  'Synthesized ambient tones during breathing',
                ),
                value: settings.sfxEnabled,
                secondary: const Icon(Icons.music_note_rounded),
                onChanged: (value) {
                  unawaited(
                    ref
                        .read(settingsProvider.notifier)
                        .setSfxEnabled(enabled: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Haptic Feedback'),
                subtitle: const Text(
                  'Vibration cues at breath phase transitions',
                ),
                value: settings.hapticsEnabled,
                secondary: const Icon(Icons.vibration_rounded),
                onChanged: (value) {
                  unawaited(
                    ref
                        .read(settingsProvider.notifier)
                        .setHapticsEnabled(enabled: value),
                  );
                },
              ),
              ListTile(
                title: const Text('Volume'),
                subtitle: Slider(
                  value: settings.volume,
                  min: 0.1,
                  divisions: 9,
                  label: '${(settings.volume * 100).round()}%',
                  onChanged: (value) {
                    unawaited(
                      ref.read(settingsProvider.notifier).setVolume(value),
                    );
                  },
                ),
                leading: const Icon(Icons.volume_up_rounded),
              ),
              const _ErrorLogViewer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorLogViewer extends ConsumerWidget {
  const _ErrorLogViewer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(errorLogsProvider);

    // Loading/error states render nothing: this is a diagnostic panel, not
    // core UI, and shouldn't ever compete for attention or show a spinner.
    final logs = logsAsync.value;
    if (logs == null || logs.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          'Recent Errors',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.error,
          ),
        ),
        Text(
          'Tap an entry for technical details, or use the copy icon to '
          'share one (for example in a bug report).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        // Newest first.
        for (final error in logs.reversed)
          _ErrorEntryCard(
            error: error,
            colorScheme: colorScheme,
            textTheme: theme.textTheme,
          ),
      ],
    );
  }
}

/// A single logged error, collapsed to a plain-language one-liner by
/// default. The raw technical text (error + stack trace) is available on
/// tap for anyone who wants it, and always included in the copied report —
/// the reader doesn't need to understand it, just be able to hand it off.
class _ErrorEntryCard extends StatefulWidget {
  const _ErrorEntryCard({
    required this.error,
    required this.colorScheme,
    required this.textTheme,
  });

  final Map<String, String> error;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  State<_ErrorEntryCard> createState() => _ErrorEntryCardState();
}

class _ErrorEntryCardState extends State<_ErrorEntryCard> {
  bool _expanded = false;

  Future<void> _copyReport(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: _buildErrorReport(widget.error)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Icon(Icons.error_outline, color: colorScheme.error),
            title: Text(
              'Something went wrong',
              style: widget.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _friendlyTimestamp(widget.error['timestamp']),
              style: widget.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.copy_rounded,
                color: colorScheme.onErrorContainer,
              ),
              tooltip: 'Copy details to share',
              onPressed: () => unawaited(_copyReport(context)),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  widget.error['error'] ?? 'Unknown error',
                  style: widget.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plain-text rendering of an error entry, meant for pasting into an email
/// or bug report rather than for on-screen display.
String _buildErrorReport(Map<String, String> error) {
  final buffer = StringBuffer()
    ..writeln('coAIRence error report')
    ..writeln('Time: ${error['timestamp'] ?? 'unknown'}')
    ..writeln()
    ..writeln(error['error'] ?? 'Unknown error');

  final stackTrace = error['stackTrace'];
  if (stackTrace != null && stackTrace.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Stack trace:')
      ..write(stackTrace);
  }

  return buffer.toString();
}

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Renders an ISO-8601 timestamp the way a non-technical reader would
/// expect: "Just now" / "5 minutes ago" / "Sep 4, 2026 at 3:42 PM".
String _friendlyTimestamp(String? iso) {
  final time = iso == null ? null : DateTime.tryParse(iso);
  if (time == null) return 'Unknown time';

  final local = time.toLocal();
  final now = DateTime.now();
  final diff = now.difference(local);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) {
    final minutes = diff.inMinutes;
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24 && local.day == now.day) {
    final hours = diff.inHours;
    return '$hours hour${hours == 1 ? '' : 's'} ago';
  }

  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${_monthNames[local.month - 1]} ${local.day}, ${local.year} '
      'at $hour12:$minute $period';
}

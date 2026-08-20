import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:material_ui/material_ui.dart';

class PatternTagIcon extends StatelessWidget {
  const PatternTagIcon(
    this.tag, {
    super.key,
    this.expanded = false,
    this.onTap,
  });

  final PatternTag tag;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = tag.color(theme.colorScheme);
    final tagOnColor = tag.onColor(theme.colorScheme);

    final label = switch (tag.name) {
      'hrv' => 'HRV',
      final n => '${n[0].toUpperCase()}${n.substring(1)}',
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: tagColor,
          borderRadius: BorderRadius.circular(expanded ? 16 : 8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(expanded ? 16 : 8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Icon(tag.icon, size: 16, color: tagOnColor),
                  if (expanded) ...[
                    Text(
                      label,
                      style: TextStyle(
                        color: tagOnColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.close, size: 14),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

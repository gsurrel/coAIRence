import 'package:material_ui/material_ui.dart';

class StretchingWrap extends StatelessWidget {
  const StretchingWrap({
    required this.children,
    super.key,
    this.spacing = 12,
    this.runSpacing = 12,
    this.minItemWidth = 180,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var columns = constraints.hasBoundedWidth
            ? ((constraints.maxWidth + spacing) / (minItemWidth + spacing))
                  .floor()
            : 1;

        if (columns < 1) columns = 1;
        if (columns > children.length) columns = children.length;

        final rows = <Widget>[];

        for (var i = 0; i < children.length; i += columns) {
          final rowItems = children.skip(i).take(columns).toList();
          final rowChildren = <Widget>[];

          for (var j = 0; j < rowItems.length; j++) {
            if (j > 0) {
              rowChildren.add(SizedBox(width: spacing));
            }

            rowChildren.add(
              Expanded(
                child: rowItems[j],
              ),
            );
          }

          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowChildren,
              ),
            ),
          );

          if (i + columns < children.length) {
            rows.add(SizedBox(height: runSpacing));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

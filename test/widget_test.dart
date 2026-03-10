import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';
import 'package:flutter_tree_graph/src/widgets/tree_painter.dart';

class TestNode extends TreeNodeData {
  final String _id;
  final List<String> _parentIds;
  final String label;

  TestNode(this._id, this.label, [this._parentIds = const []]);

  @override
  String get id => _id;

  @override
  List<String> get parentIds => _parentIds;
}

void main() {
  testWidgets('TreeView renders nodes correctly', (WidgetTester tester) async {
    final data = [
      TestNode('1', 'Root'),
      TestNode('2', 'Child', ['1']),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TreeView<TestNode>(
            data: data,
            nodeBuilder: (context, node) {
              return Text(node.label);
            },
          ),
        ),
      ),
    );

    // Verify nodes are rendered
    expect(find.text('Root'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);

    // Verify CustomPaint is present (for lines)
    final customPaintFinder = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is TreePainter,
    );
    expect(customPaintFinder, findsOneWidget);
  });

  testWidgets('TreeView handles empty data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TreeView<TestNode>(data: [], nodeBuilder: _buildNode),
        ),
      ),
    );

    expect(find.text('No data'), findsOneWidget);
  });
}

Widget _buildNode(BuildContext context, TestNode node) {
  return Text(node.label);
}

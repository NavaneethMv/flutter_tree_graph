import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';

class TestNode extends TreeNodeData {
  final String _id;
  final List<String> _parentIds;

  TestNode(this._id, [this._parentIds = const []]);

  @override
  String get id => _id;

  @override
  List<String> get parentIds => _parentIds;
}

void main() {
  group('SimpleLayout', () {
    test('positions single root node at origin', () {
      final root = TreeNode(TestNode('root'));
      const layout = SimpleLayout();

      layout.calculateLayout([root]);

      expect(root.x, 0.0);
      expect(root.y, 0.0);
    });

    test('positions child below parent', () {
      final root = TreeNode(TestNode('root'));
      final child = TreeNode(TestNode('child'));

      root.children.add(child);
      child.parents.add(root);

      const layout = SimpleLayout();
      layout.calculateLayout(
        [root],
        nodeWidth: 100,
        nodeHeight: 50,
        verticalSpacing: 50,
      );

      // Child should be at same X as parent (since it's the only child)
      // and below parent by verticalSpacing
      expect(child.x, 0.0);
      expect(
        child.y,
        50.0,
      ); // 0 + verticalSpacing (assuming y starts at 0 for each level?)
      // Actually SimpleLayout accumulates y + vSpacing
      // root.y=0, child.y = 0 + 50 = 50.
    });

    test('positions siblings with spacing', () {
      final root = TreeNode(TestNode('root'));
      final child1 = TreeNode(TestNode('child1'));
      final child2 = TreeNode(TestNode('child2'));

      root.children.addAll([child1, child2]);

      const layout = SimpleLayout();
      layout.calculateLayout([root], nodeWidth: 100, horizontalSpacing: 20);

      // Child 1 starts at parent's X (initially 0)
      expect(child1.x, 0.0);

      // Child 2 starts at Child 1's X + nodeWidth + spacing
      // 0 + 100 + 20 = 120
      expect(child2.x, 120.0);

      // Parent should be centered over children
      // Center of children block: (0 + (120 + 100)) / 2 = 110
      // Parent center: 110 - (100 / 2) = 60
      expect(root.x, 60.0);
    });
  });
}

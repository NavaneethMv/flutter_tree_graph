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
  group('TreeNodeData', () {
    test('equality works correctly', () {
      final node1 = TestNode('1');
      final node2 = TestNode('1');
      final node3 = TestNode('3');

      expect(node1, equals(node2));
      expect(node1, isNot(equals(node3)));
    });

    test('hashCode is consistent', () {
      final node1 = TestNode('1');
      final node2 = TestNode('1');

      expect(node1.hashCode, equals(node2.hashCode));
    });
  });

  group('TreeNode', () {
    test('initialization sets default values', () {
      final data = TestNode('1');
      final node = TreeNode(data);

      expect(node.data, equals(data));
      expect(node.parents, isEmpty);
      expect(node.children, isEmpty);
      expect(node.x, 0.0);
      expect(node.y, 0.0);
    });

    test('structure properties work correctly', () {
      final rootData = TestNode('root');
      final childData = TestNode('child', ['root']);

      final root = TreeNode(rootData);
      final child = TreeNode(childData);

      // Manually link for unit testing structure properties
      // Note: In real usage, TreeBuilder handles this
      root.children.add(child);
      child.parents.add(root);

      expect(root.isRoot, isTrue);
      expect(root.isLeaf, isFalse);
      expect(root.leftmostChild, equals(child));
      expect(root.rightmostChild, equals(child));

      expect(child.isRoot, isFalse);
      expect(child.isLeaf, isTrue);
      expect(child.leftmostChild, isNull);
    });
  });
}

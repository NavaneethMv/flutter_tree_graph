import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';
import 'package:flutter_tree_graph/src/utils/tree_builder.dart';

class TestNode extends TreeNodeData {
  final String _id;
  final List<String> _parentIds;
  final String? _partnerId;

  TestNode(this._id, {List<String> parentIds = const [], String? partnerId})
    : _parentIds = parentIds,
      _partnerId = partnerId;

  @override
  String get id => _id;

  @override
  List<String> get parentIds => _parentIds;

  @override
  String? get partnerId => _partnerId;
}

void main() {
  group('TreeBuilder Partner Logic', () {
    test('Root couple: Only one becomes root', () {
      final data = [
        TestNode('A', partnerId: 'B'),
        TestNode('B', partnerId: 'A'),
      ];

      final builder = TreeBuilder<TestNode>();
      final roots = builder.buildTree(data);

      expect(roots.length, 1);
      final root = roots.first;
      expect(root.data.id, anyOf('A', 'B'));
      expect(root.partner, isNotNull);
      expect(root.partner!.data.id, anyOf('A', 'B'));
      expect(root.partner!.data.id, isNot(root.data.id));
    });

    test('Descendant couple: Partner is not added to roots', () {
      final data = [
        TestNode('Root'),
        TestNode('Child', parentIds: ['Root'], partnerId: 'Spouse'),
        TestNode(
          'Spouse',
          partnerId: 'Child',
        ), // No parents, but partner has parents
      ];

      final builder = TreeBuilder<TestNode>();
      final roots = builder.buildTree(data);

      expect(roots.length, 1);
      final root = roots.first;
      expect(root.data.id, 'Root');

      expect(root.children, hasLength(1));
      final child = root.children.first;
      expect(child.data.id, 'Child');
      expect(child.partner, isNotNull);
      expect(child.partner!.data.id, 'Spouse');

      // Verify 'Spouse' is NOT a root
      // (If Spouse were a root, roots.length would be 2)
    });
  });
}

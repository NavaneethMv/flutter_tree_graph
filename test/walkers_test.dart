import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';
import 'package:flutter_tree_graph/src/layout/walkers_layout.dart';

class SimpleNode extends TreeNodeData {
  final String _id;
  SimpleNode(this._id);

  @override
  String get id => _id;

  @override
  List<String> get parentIds => [];

  @override
  // ignore: annotate_overrides
  String? get partnerId => null;
}

TreeNode<SimpleNode> node(String id) {
  return TreeNode<SimpleNode>(SimpleNode(id));
}

void connect(TreeNode<SimpleNode> parent, List<TreeNode<SimpleNode>> children) {
  for (var child in children) {
    if (!parent.children.contains(child)) parent.children.add(child);
    if (!child.parents.contains(parent)) child.parents.add(parent);
  }
}

void wirePartner(TreeNode<SimpleNode> p1, TreeNode<SimpleNode> p2) {
  p1.partner = p2;
  p2.partner = p1;
}

void main() {
  group('WalkersTreeLayout', () {
    const layout = WalkersTreeLayout();
    const double w = 100;
    const double h = 80;
    const double hSpace = 50;
    const double vSpace = 100;

    test('Single root node positioning', () {
      final root = node('Root');
      layout.calculateLayout([root], nodeWidth: w, horizontalSpacing: hSpace);

      expect(root.x, 0);
      expect(root.y, 0);
    });

    test('Parent with one child (centered)', () {
      final child = node('Child');
      final root = node('Root');
      connect(root, [child]);

      layout.calculateLayout([root], nodeWidth: w, horizontalSpacing: hSpace);

      expect(child.x, 0);
      expect(root.x, 0);
      expect(child.y, vSpace);
    });

    test('Parent with two children (spaced)', () {
      final c1 = node('C1');
      final c2 = node('C2');
      final root = node('Root');
      connect(root, [c1, c2]);

      layout.calculateLayout([root], nodeWidth: w, horizontalSpacing: hSpace);

      // c1 starts at 0
      expect(c1.x, 0);
      // c2 starts at 100 + 50 = 150
      expect(c2.x, 150);
      // Parent centered at (0 + 150) / 2 = 75
      expect(root.x, 75);
    });

    test('Partner handling (Couple width)', () {
      final p1 = node('P1');
      final p2 = node('P2');
      wirePartner(p1, p2);

      final root = p1;
      layout.calculateLayout([root], nodeWidth: w, horizontalSpacing: hSpace);

      expect(p1.x, 0);
      expect(p2.x, 150); // straight to right
    });
  });
}

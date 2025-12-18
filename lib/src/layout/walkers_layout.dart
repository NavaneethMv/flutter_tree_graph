// lib/src/layout/walkers_layout.dart

import 'package:flutter_tree_graph/flutter_tree_graph.dart';

class WalkersTreeLayout extends TreeLayout {
  @override
  void calculateLayout(
    List<TreeNode> roots, {
    double nodeWidth = 100,
    double nodeHeight = 80,
    double horizontalSpacing = 50,
    double verticalSpacing = 100,
  }) {
    // TODO: Implement Walker's algorithm
    SimpleLayout().calculateLayout(
      roots,
      nodeWidth: nodeWidth,
      nodeHeight: nodeHeight,
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
    );
  }
}

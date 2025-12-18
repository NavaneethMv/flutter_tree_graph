// lib/src/layout/tree_layout.dart

import 'package:flutter_tree_graph/flutter_tree_graph.dart';

abstract class TreeLayout {
  /// Calculate positions for all nodes
  void calculateLayout(
    List<TreeNode> roots, {
    double nodeWidth = 100,
    double nodeHeight = 80,
    double horizontalSpacing = 50,
    double verticalSpacing = 100,
  });
}

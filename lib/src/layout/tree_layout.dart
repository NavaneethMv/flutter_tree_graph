// lib/src/layout/tree_layout.dart

import 'package:flutter_tree_graph/flutter_tree_graph.dart';

/// Base class for all tree layout algorithms.
///
/// A [TreeLayout] is responsible for calculating the `x` and `y` coordinates
/// of [TreeNode]s in a tree structure. Subclasses must implement
/// [calculateLayout] to likely traverse the tree and assign positions.
abstract class TreeLayout {
  /// Const constructor for the base layout class.
  const TreeLayout();

  /// Calculates the `x` and `y` positions for all [roots] and their
  /// descendants.
  ///
  /// Implementations should respect the provided [nodeWidth], [nodeHeight],
  /// [horizontalSpacing] and [verticalSpacing] configuration.
  void calculateLayout(
    List<TreeNode> roots, {
    double nodeWidth = 100,
    double nodeHeight = 80,
    double horizontalSpacing = 50,
    double verticalSpacing = 100,
  });
}

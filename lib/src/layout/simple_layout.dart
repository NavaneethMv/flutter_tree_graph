// lib/src/layout/simple_layout.dart

import 'package:flutter_tree_graph/flutter_tree_graph.dart';

/// A basic tree layout algorithm that arranges nodes in a simple hierarchical structure.
///
/// The [SimpleLayout] positions nodes in a traditional tree format where:
/// - Root nodes are placed at the top
/// - Children are arranged horizontally below their parents
/// - Parents are centered above their children
/// - Multiple trees are placed side by side
///
/// This layout is suitable for:
/// - Small to medium-sized trees
/// - Trees where simplicity and readability are prioritized
/// - Cases where advanced positioning algorithms are not needed
///
/// **Layout Characteristics:**
/// - **Vertical arrangement**: Each level is placed at a fixed vertical distance
/// - **Horizontal centering**: Parents are centered over their children
/// - **Uniform spacing**: All nodes at the same level have consistent spacing
/// - **Multi-tree support**: Multiple root trees are arranged side by side
///
/// Example usage:
/// ```dart
/// final layout = SimpleLayout();
/// layout.calculateLayout(
///   roots,
///   nodeWidth: 120,
///   nodeHeight: 80,
///   horizontalSpacing: 60,
///   verticalSpacing: 120,
/// );
/// ```
class SimpleLayout extends TreeLayout {
  /// Calculates and applies layout positions for all nodes in the provided trees.
  ///
  /// This method implements the main layout algorithm that positions each node
  /// based on its position in the tree hierarchy. The algorithm processes each
  /// root tree independently and arranges them side by side.
  ///
  /// **Algorithm Overview:**
  /// 1. Process each root tree sequentially from left to right
  /// 2. For each tree, recursively position nodes using depth-first traversal
  /// 3. Position children horizontally below parents
  /// 4. Center parents above their children groups
  /// 5. Calculate total tree width for proper spacing between multiple trees
  ///
  /// **Time Complexity:** O(n) where n is the total number of nodes
  /// **Space Complexity:** O(h) where h is the maximum tree height (recursion stack)
  ///
  /// Parameters:
  /// - [roots]: List of root nodes representing the trees to layout. Each root
  ///   represents an independent tree structure.
  /// - [nodeWidth]: Width of each node in layout units. Used for horizontal
  ///   spacing calculations and parent centering. Default: 100.
  /// - [nodeHeight]: Height of each node in layout units. Currently not used
  ///   in positioning but available for future enhancements. Default: 80.
  /// - [horizontalSpacing]: Horizontal gap between sibling nodes at the same
  ///   level. Also affects spacing between separate trees. Default: 50.
  /// - [verticalSpacing]: Vertical gap between parent and child levels.
  ///   Determines the vertical distance between tree levels. Default: 100.
  ///
  /// Side Effects:
  /// - Modifies the `x` and `y` properties of all [TreeNode] objects in the trees
  /// - Nodes are positioned starting from coordinates (0, 0) for the first tree
  /// - Multiple trees are positioned with appropriate horizontal offsets
  ///
  /// Example:
  /// ```dart
  /// final layout = SimpleLayout();
  /// layout.calculateLayout(
  ///   myTreeRoots,
  ///   nodeWidth: 150,     // Wider nodes
  ///   horizontalSpacing: 75,  // More space between siblings
  ///   verticalSpacing: 120,   // More space between levels
  /// );
  ///
  /// // Access calculated positions
  /// for (final root in myTreeRoots) {
  ///   print('Root at (${root.x}, ${root.y})');
  /// }
  /// ```
  @override
  void calculateLayout(
    List<TreeNode<TreeNodeData>> roots, {
    double nodeWidth = 100,
    double nodeHeight = 80,
    double horizontalSpacing = 50,
    double verticalSpacing = 100,
  }) {
    double currentX = 0.0;

    for (var root in roots) {
      _layoutTree(
        root,
        currentX,
        0,
        nodeWidth,
        horizontalSpacing,
        verticalSpacing,
      );
      currentX += _getTreeWidth(root, nodeWidth, horizontalSpacing);
    }
  }

  /// Recursively positions nodes within a single tree structure.
  ///
  /// This private method implements the core positioning logic for a single tree,
  /// using a two-pass algorithm: first positioning children, then adjusting the
  /// parent position to center it above its children.
  ///
  /// **Algorithm Steps:**
  /// 1. Set the current node's initial position
  /// 2. If the node has children:
  ///    a. Position each child recursively from left to right
  ///    b. Calculate the center point of all children
  ///    c. Adjust parent's x-coordinate to center it above children
  /// 3. If the node is a leaf, keep its original position
  ///
  /// **Positioning Strategy:**
  /// - Children are placed in a horizontal line below their parent
  /// - Each child is positioned with the specified horizontal spacing
  /// - Parent x-coordinate is adjusted to the midpoint between first and last child
  /// - Y-coordinates follow the tree level with consistent vertical spacing
  ///
  /// Parameters:
  /// - [node]: The current node being positioned
  /// - [x]: Initial x-coordinate for the current node
  /// - [y]: Y-coordinate for the current node (based on tree level)
  /// - [nodeWidth]: Width of each node for spacing calculations
  /// - [hSpacing]: Horizontal spacing between sibling nodes
  /// - [vSpacing]: Vertical spacing between parent and child levels
  ///
  /// Side Effects:
  /// - Modifies the `x` and `y` properties of [node] and all its descendants
  /// - Parent positions may be adjusted after children are positioned
  ///
  /// Time Complexity: O(n) where n is the number of nodes in the subtree
  void _layoutTree(
    TreeNode node,
    double x,
    double y,
    double nodeWidth,
    double hSpacing,
    double vSpacing,
  ) {
    // Set initial position for current node
    node.x = x;
    node.y = y;

    if (node.children.isEmpty) return;

    double childX = x;
    for (var child in node.children) {
      _layoutTree(child, childX, y + vSpacing, nodeWidth, hSpacing, vSpacing);
      childX += nodeWidth + hSpacing;
    }

    // Center parent over the span of its children
    if (node.children.isNotEmpty) {
      double leftmostChild = node.children.first.x;
      double rightmostChild = node.children.last.x;
      node.x = (leftmostChild + rightmostChild) / 2;
    }
  }

  /// Calculates the total horizontal width required for a tree rooted at the given node.
  ///
  /// This method recursively computes the minimum width needed to accommodate
  /// a tree structure, considering node widths and horizontal spacing between
  /// siblings. The calculation is used to properly position multiple trees
  /// side by side without overlap.
  ///
  /// **Calculation Logic:**
  /// - For leaf nodes: Returns the node width
  /// - For internal nodes: Sums the widths of all child subtrees plus spacing
  /// - Accounts for horizontal spacing between all sibling groups
  ///
  /// **Width Components:**
  /// ```
  /// Total Width = Sum of (Child Tree Width + Horizontal Spacing)
  /// ```
  ///
  /// The method ensures that:
  /// - Each subtree has enough space for its widest level
  /// - Sibling trees don't overlap when positioned side by side
  /// - Spacing is consistent across all tree levels
  ///
  /// Parameters:
  /// - [node]: The root node of the tree/subtree to measure
  /// - [nodeWidth]: Width of individual nodes in layout units
  /// - [hSpacing]: Horizontal spacing between sibling nodes
  ///
  /// Returns:
  /// The total horizontal width required for the tree rooted at [node],
  /// including all descendant nodes and required spacing.
  ///
  /// Time Complexity: O(n) where n is the number of nodes in the subtree
  ///
  /// Example:
  /// ```
  /// Tree structure:
  ///     A
  ///   /   \
  ///  B     C
  ///       / \
  ///      D   E
  ///
  /// Width calculation:
  /// - D width: nodeWidth (100)
  /// - E width: nodeWidth (100)
  /// - C width: 100 + 50 + 100 = 250 (D + spacing + E)
  /// - B width: nodeWidth (100)
  /// - A width: 100 + 50 + 250 = 400 (B + spacing + C subtree)
  /// ```
  double _getTreeWidth(TreeNode node, double nodeWidth, double hSpacing) {
    if (node.children.isEmpty) return nodeWidth;

    double totalWidth = 0;
    for (var child in node.children) {
      totalWidth += _getTreeWidth(child, nodeWidth, hSpacing) + hSpacing;
    }

    return totalWidth > 0 ? totalWidth - hSpacing : 0;
  }
}

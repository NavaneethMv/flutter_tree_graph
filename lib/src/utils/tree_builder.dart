// lib/src/utils/tree_builder.dart

import 'package:flutter_tree_graph/flutter_tree_graph.dart';

/// A utility class for constructing tree structures from flat lists of data.
///
/// The [TreeBuilder] takes a flat list of objects implementing [TreeNodeData]
/// and constructs a hierarchical tree structure by analyzing parent-child
/// relationships defined by the data's ID and parent ID properties.
///
/// The generic type [T] must extend [TreeNodeData] to ensure the input data
/// provides the necessary identification and relationship information.
///
/// Example usage:
/// ```dart
/// class PersonData extends TreeNodeData {
///   final String _id;
///   final String? _parentId;
///   final String name;
///
///   PersonData(this._id, this._parentId, this.name);
///
///   @override
///   String get id => _id;
///
///   @override
///   String? get parentId => _parentId;
/// }
///
/// final data = [
///   PersonData('1', null, 'CEO'),
///   PersonData('2', '1', 'VP Engineering'),
///   PersonData('3', '1', 'VP Sales'),
///   PersonData('4', '2', 'Senior Engineer'),
/// ];
///
/// final builder = TreeBuilder<PersonData>();
/// final roots = builder.buildTree(data);
///
/// // roots will contain one TreeNode with CEO as root
/// // and the hierarchy properly established
/// ```
class TreeBuilder<T extends TreeNodeData> {
  /// Constructs a tree structure from a flat list of data objects.
  ///
  /// This method processes the input data in several steps:
  /// 1. Creates [TreeNode] wrappers for each data object
  /// 2. Builds parent-child relationships based on ID matching
  /// 3. Identifies root nodes (those with no parent)
  /// 4. Calculates depth levels for all nodes in the hierarchy
  ///
  /// **Time Complexity:** O(n) where n is the number of data objects.
  /// **Space Complexity:** O(n) for the internal node mapping.
  ///
  /// Parameters:
  /// - [data]: A flat list of objects implementing [TreeNodeData]. Each object
  ///   must have a unique [id] and may have a [parentId] pointing to another
  ///   object's ID to establish parent-child relationships.
  ///
  /// Returns:
  /// A [List] of [TreeNode] objects representing the root nodes of the
  /// constructed tree(s). If the data represents a single tree, this list
  /// will contain one element. If the data represents a forest (multiple
  /// disconnected trees), multiple root nodes will be returned.
  ///
  /// **Orphan Node Handling:**
  /// Nodes with a [parentId] that doesn't match any existing node's [id]
  /// are treated as root nodes. This behavior ensures the method doesn't
  /// fail on malformed data but may need refinement based on requirements.
  ///
  /// Throws:
  /// - No exceptions are thrown directly, but malformed data (duplicate IDs,
  ///   circular references) may result in unexpected tree structures.
  ///
  /// Example:
  /// ```dart
  /// final builder = TreeBuilder<MyNodeData>();
  /// final roots = builder.buildTree(myDataList);
  ///
  /// // Process each tree
  /// for (final root in roots) {
  ///   print('Tree root: ${root.data.id}');
  ///   print('Children count: ${root.children.length}');
  /// }
  /// ```
  List<TreeNode<T>> buildTree(List<T> data) {
    // Create map for O(1) lookup of nodes by ID
    Map<String, TreeNode<T>> nodeMap = {};

    for (var item in data) {
      nodeMap[item.id] = TreeNode<T>(item);
    }

    List<TreeNode<T>> roots = [];

    for (var node in nodeMap.values) {
      if (node.data.parentId == null) {
        // Node has no parent - it's a root
        roots.add(node);
      } else {
        final TreeNode<T>? parent = nodeMap[node.data.parentId];
        if (parent != null) {
          parent.children.add(node);
          node.parent = parent;
        } else {
          // Parent not found - treat as orphaned root
          // TODO: Consider stricter validation or error handling
          roots.add(node);
        }
      }
    }

    // Phase 3: Calculate depth levels for all nodes
    for (var root in roots) {
      _calculateLevels(root);
    }

    return roots;
  }

  /// Recursively calculates and assigns depth levels to all nodes in a subtree.
  ///
  /// This private method performs a depth-first traversal of the tree starting
  /// from the given node, assigning level values based on the node's distance
  /// from the root. The level is used by layout algorithms for vertical
  /// positioning and by rendering code for styling purposes.
  ///
  /// **Algorithm:** Depth-first traversal with level propagation
  /// **Time Complexity:** O(n) where n is the number of nodes in the subtree
  /// **Space Complexity:** O(h) where h is the height of the subtree (recursion stack)
  ///
  /// Parameters:
  /// - [node]: The starting node for level calculation. This node will be
  ///   assigned the specified [level], and all descendants will be assigned
  ///   incrementally higher levels.
  /// - [level]: The level to assign to the current [node]. Defaults to 0,
  ///   which is appropriate for root nodes.
  ///
  /// Side Effects:
  /// - Modifies the [level] property of [node] and all its descendants
  /// - The traversal order affects the order in which nodes are processed,
  ///   but not the final level assignments
  ///
  /// Example behavior:
  /// ```
  /// Root (level 0)
  /// ├── Child A (level 1)
  /// │   ├── Grandchild A1 (level 2)
  /// │   └── Grandchild A2 (level 2)
  /// └── Child B (level 1)
  ///     └── Grandchild B1 (level 2)
  /// ```
  void _calculateLevels(TreeNode<T> node, [int level = 0]) {
    node.level = level;

    for (var child in node.children) {
      _calculateLevels(child, level + 1);
    }
  }
}

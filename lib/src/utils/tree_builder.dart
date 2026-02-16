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
    if (data.isEmpty) {
      return [];
    }
    // Create map for O(1) lookup of nodes by ID
    Map<String, TreeNode<T>> nodeMap = {};

    for (var item in data) {
      nodeMap[item.id] = TreeNode<T>(item);
    }

    // pairing nodes - adding partners
    for (var node in nodeMap.values) {
      final partnerId = node.data.partnerId;
      if (partnerId != null && nodeMap.containsKey(partnerId)) {
        final partnerNode = nodeMap[partnerId]!;

        node.partner = partnerNode;
        partnerNode.partner = node;
      }
    }

    // Build hierarchy (connect parents and children)
    for (var node in nodeMap.values) {
      final parentIds = node.data.parentIds;
      for (var parentId in parentIds) {
        TreeNode<T>? parent = nodeMap[parentId];
        if (parent != null) {
          if (!parent.children.contains(node)) {
            parent.children.add(node);
          }
          if (!node.parents.contains(parent)) {
            node.parents.add(parent);
          }
        }
      }
    }

    // Auto-include partner parents for children with single parents
    // This ensures children of couples appear under both parents in the tree
    // even if only one parent was explicitly specified in the data
    for (var node in nodeMap.values) {
      if (node.parents.length == 1) {
        final singleParent = node.parents.first;
        final partnerOfParent = singleParent.partner;

        if (partnerOfParent != null &&
            !node.parents.contains(partnerOfParent)) {
          // Add partner as second parent
          node.parents.add(partnerOfParent);

          // Add this node to partner's children if not already there
          if (!partnerOfParent.children.contains(node)) {
            partnerOfParent.children.add(node);
          }
        }
      }
    }

    // Identify roots
    List<TreeNode<T>> roots = [];
    for (var node in nodeMap.values) {
      final hasParents = node.parents.isNotEmpty;

      if (!hasParents) {
        if (node.partner == null) {
          roots.add(node);
        } else {
          // Node has a partner
          // We should add to roots only if:
          // 1. Partner is not already in roots (avoid duplicates for
          //    root couples)
          // 2. Partner also has no parents (if partner has parents, this node
          //    is attached to descendent)
          final partnerHasParents = node.partner!.parents.isNotEmpty;
          final partnerAlreadyRoot = roots.contains(node.partner);

          if (!partnerHasParents && !partnerAlreadyRoot) {
            roots.add(node);
          }
        }
      }
    }

    // Calculate depth levels for all nodes
    for (var root in roots) {
      _calculateLevels(root);
    }

    return roots;
  }

  /// Recursively calculates and assigns depth levels to all nodes in a subtree.
  /// Also reorders parents list to align with traversal path for correct
  /// layout.
  void _calculateLevels(
    TreeNode<T> node, [
    int level = 0,
    TreeNode<T>? traversalParent,
  ]) {
    node.level = level;

    // Ensure partner node gets the same level
    if (node.partner != null) {
      node.partner!.level = level;
    }

    // Prioritize traversal parent in parents list for layout algorithms
    // This ensures getLeftSibling() finds the correct sibling in the traversal
    // parent's children list
    if (traversalParent != null && node.parents.contains(traversalParent)) {
      node.parents.remove(traversalParent);
      node.parents.insert(0, traversalParent);
    }

    for (var child in node.children) {
      _calculateLevels(child, level + 1, node);
    }
  }
}

// lib/src/models/tree_node_data.dart

/// Abstract base class for data that can be represented as nodes in a tree structure.
///
/// This class defines the minimum interface required for any data to be used
/// with the tree graph widget. Implementations must provide unique identifiers
/// and parent relationships to establish the tree hierarchy.
///
/// Example implementation:
/// ```dart
/// class MyNodeData extends TreeNodeData {
///   final String _id;
///   final String? _parentId;
///   final String title;
///
///   MyNodeData(this._id, this._parentId, this.title);
///
///   @override
///   String get id => _id;
///
///   @override
///   String? get parentId => _parentId;
/// }
/// ```
abstract class TreeNodeData {
  // Unique identifier for the tree node
  String get id;

  // Identifier of the parent node; null if this is a root node
  List<String> get parentIds;

  String? get partnerId => null;

  // Override for custom equality comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeNodeData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TreeNode<T extends TreeNodeData> {
  final T data;

  List<TreeNode<T>> parents = [];
  final List<TreeNode<T>> children = [];
  TreeNode<T>? partner; // Spouse/partner

  // Layout properties
  double x = 0.0;
  double y = 0.0;

  // Walker's modifier
  double mod = 0.0;

  int level = 0;

  // For tracking during layout
  TreeNode<T>? thread;
  TreeNode<T>? ancestor;
  double change = 0;
  double shift = 0;
  int number = 0;

  TreeNode(this.data);

  /// Whether this node is a root (no parents)
  bool get isRoot => parents.isEmpty;

  /// Whether this node is a leaf (no children)
  bool get isLeaf => children.isEmpty;

  /// Get leftmost child
  TreeNode<T>? get leftmostChild => children.isEmpty ? null : children.first;

  /// Get rightmost child
  TreeNode<T>? get rightmostChild => children.isEmpty ? null : children.last;

  /// Get left sibling
  TreeNode<T>? getLeftSibling() {
    if (parents.isEmpty) return null;

    final parent = parents.first;
    final index = parent.children.indexOf(this);

    return index > 0 ? parent.children[index - 1] : null;
  }
}

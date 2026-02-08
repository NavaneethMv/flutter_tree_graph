// lib/src/models/tree_node_data.dart

/// Abstract base class for data that can be represented as nodes in a tree
/// structure.
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
  /// Unique identifier for the tree node
  String get id;

  /// Identifier of the parent node; null if this is a root node
  List<String> get parentIds;

  /// Identifier of the partner node
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

/// Internal representation of a node in the tree structure.
///
/// Wraps the user-provided [TreeNodeData] with layout-specific properties
/// such as coordinates (`x`, `y`), hierarchy references (`parents`,
/// `children`) and traversal helpers.
class TreeNode<T extends TreeNodeData> {
  /// The user-provided data associated with this node.
  final T data;

  /// List of parent nodes.
  List<TreeNode<T>> parents = [];

  /// List of child nodes.
  final List<TreeNode<T>> children = [];

  /// The partner of this node, if any (e.g., spouse).
  TreeNode<T>? partner; // Spouse/partner

  // Layout properties
  /// The x-coordinate calculated by the layout algorithm.
  double x = 0.0;

  /// The y-coordinate calculated by the layout algorithm.
  double y = 0.0;

  // Walker's modifier
  /// Modifier used by Walker's algorithm for adjusting subtrees.
  double mod = 0.0;

  /// The depth level of the node in the tree (0-indexed).
  int level = 0;

  // For tracking during layout
  /// Thread reference for Walker's algorithm.
  TreeNode<T>? thread;

  /// Ancestor reference for Walker's algorithm.
  TreeNode<T>? ancestor;

  /// Shift value for Walker's algorithm.
  double change = 0;

  /// Shift value for Walker's algorithm.
  double shift = 0;

  /// The order number of the node among its siblings.
  int number = 0;

  /// Creates a [TreeNode] wrapping the given [data].
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

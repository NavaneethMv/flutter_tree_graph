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
  String? get parentId;

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
  TreeNode<T>? parent;
  final List<TreeNode<T>> children = [];

  // Layout porperties
  double x = 0.0;
  double y = 0.0;

  // Walker's modifier
  double mod = 0.0;

  int level = 0;

  TreeNode(this.data);
}

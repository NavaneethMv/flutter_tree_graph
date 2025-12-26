// lib/src/widgets/tree_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';
import 'package:flutter_tree_graph/src/utils/tree_builder.dart';
import 'package:flutter_tree_graph/src/widgets/tree_painter.dart';

/// A customizable widget that lays out and renders a tree of nodes.
///
/// `TreeView` is a generic widget that accepts a list of data items of type
/// `T extends TreeNodeData` and a `nodeBuilder` callback used to build the
/// visual representation of each node. The widget uses a `TreeBuilder` to
/// convert the flat list of data into a tree of `TreeNode<T>` objects, then
/// applies the provided `TreeLayout` to compute `x`/`y` coordinates for each
/// node. Connection lines between nodes are drawn using `TreePainter` and the
/// nodes themselves are positioned as `Positioned` children inside a `Stack`.
///
/// Important notes / contract:
/// - The layout algorithm will populate `x` and `y` on each `TreeNode`.
/// - `nodeBuilder` receives the original `T` data and should produce a
///   widget sized to match `nodeWidth`/`nodeHeight` (or use `SizedBox` to
///   constrain the returned widget).
/// - Connections are drawn beneath the node widgets; interactivity (taps,
///   gestures) should be handled by the node widgets provided by
///   `nodeBuilder`.
///
/// Example
/// ```dart
/// TreeView<MyNodeData>(
///   data: items,
///   nodeBuilder: (context, data) => Card(
///     child: Center(child: Text(data.title)),
///   ),
///   layout: SimpleLayout(),
///   nodeWidth: 120,
///   nodeHeight: 64,
/// );
/// ```

/// Builds a widget for a single node given its typed data.
///
/// The returned widget will be placed into a fixed `SizedBox` matching the
/// `nodeWidth` and `nodeHeight` provided to `TreeView`. For consistent
/// visuals, make sure the builder returns a widget that respects those
/// constraints (or wrap it in `SizedBox`).
typedef NodeBuilder<T> = Widget Function(BuildContext context, T data);

class TreeView<T extends TreeNodeData> extends StatefulWidget {
  /// The list of data items used to build the logical tree. Each item must
  /// contain identifiers/parent references understood by `TreeBuilder`.
  final List<T> data;

  /// Callback that builds the widget for a single node from its data.
  final NodeBuilder<T> nodeBuilder;

  /// The layout algorithm used to compute node coordinates.
  ///
  /// Defaults to [SimpleLayout] when not provided.
  final TreeLayout layout;

  /// The width and height used when positioning node widgets and when
  /// drawing connection lines.
  final double nodeWidth;
  final double nodeHeight;

  /// Spacing between nodes horizontally and vertically used by the layout
  /// algorithm.
  final double horizontalSpacing;
  final double verticalSpacing;

  /// Styling of the connecting lines (color and stroke width).
  final Color lineColor;
  final double lineWidth;

  /// Create a [TreeView].
  ///
  /// Provide `data` and `nodeBuilder`. Other parameters have sensible
  /// defaults but can be tuned to alter sizes, spacing and line styling.
  const TreeView({
    super.key,
    required this.data,
    required this.nodeBuilder,
    TreeLayout? layout,
    this.nodeWidth = 100,
    this.nodeHeight = 80,
    this.horizontalSpacing = 50,
    this.verticalSpacing = 100,
    this.lineColor = Colors.grey,
    this.lineWidth = 2,
  }) : layout = layout ?? const SimpleLayout();

  @override
  State<TreeView<T>> createState() => _TreeViewState<T>();
}

class _TreeViewState<T extends TreeNodeData> extends State<TreeView<T>> {
  List<TreeNode<T>> roots = [];

  @override
  void initState() {
    super.initState();
    _buildTree();
  }

  @override
  void didUpdateWidget(TreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild the tree when the input data changes.
    if (oldWidget.data != widget.data) {
      _buildTree();
    }
  }

  void _buildTree() {
    final builder = TreeBuilder<T>();
    roots = builder.buildTree(widget.data);

    widget.layout.calculateLayout(
      roots,
      nodeHeight: widget.nodeHeight,
      nodeWidth: widget.nodeWidth,
      horizontalSpacing: widget.horizontalSpacing,
      verticalSpacing: widget.verticalSpacing,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (roots.isEmpty) {
      return const Center(child: Text('No data'));
    }

    double maxX = 0, maxY = 0;
    _findBounds(roots, (x, y) {
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    });

    return InteractiveViewer(
      boundaryMargin: EdgeInsets.all(100.0),
      minScale: 0.1,
      maxScale: 4.0,
      child: SizedBox(
        width: maxX + widget.nodeWidth + 100,
        height: maxY + widget.nodeHeight + 100,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(maxX + widget.nodeWidth, maxY + widget.nodeHeight),
              painter: TreePainter(
                roots: roots,
                nodeWidth: widget.nodeWidth,
                nodeHeight: widget.nodeHeight,
                lineColor: widget.lineColor,
                lineWidth: widget.lineWidth,
              ),
            ),

            // Draw nodes
            ..._buildNodeWidgets(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNodeWidgets() {
    List<Widget> widgets = [];

    void traverse(TreeNode<T> node) {
      // Each node is wrapped in a Positioned widget so it can be placed at
      // the coordinates calculated by the layout algorithm. The child is
      // constrained to `nodeWidth`/`nodeHeight` which keeps node sizes
      // consistent with the painter.
      widgets.add(
        Positioned(
          left: node.x,
          top: node.y,
          child: SizedBox(
            width: widget.nodeWidth,
            height: widget.nodeHeight,
            child: widget.nodeBuilder(context, node.data),
          ),
        ),
      );

      for (var child in node.children) {
        traverse(child);
      }
    }

    for (var root in roots) {
      traverse(root);
    }

    return widgets;
  }

  void _findBounds(
    List<TreeNode<T>> nodes,
    Function(double x, double y) callback,
  ) {
    for (var node in nodes) {
      callback(node.x, node.y);
      _findBounds(node.children, callback);
    }
  }
}

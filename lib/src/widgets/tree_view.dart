// lib/src/widgets/tree_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';
import 'package:flutter_tree_graph/src/utils/tree_builder.dart';
import 'package:flutter_tree_graph/src/widgets/tree_painter.dart';

typedef NodeBuilder<T> = Widget Function(BuildContext context, T data);

class TreeView<T extends TreeNodeData> extends StatefulWidget {
  // List of data items
  final List<T> data;

  /// Builder for individual node widgets
  final NodeBuilder<T> nodeBuilder;

  /// Layout algorithm
  final TreeLayout layout;

  /// Node dimensions
  final double nodeWidth;
  final double nodeHeight;

  /// Spacing
  final double horizontalSpacing;
  final double verticalSpacing;

  /// Line styling
  final Color lineColor;
  final double lineWidth;

  TreeView({
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
  }) : layout = layout ?? SimpleLayout();

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

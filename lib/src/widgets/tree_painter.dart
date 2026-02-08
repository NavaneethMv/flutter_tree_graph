// lib/src/widgets/tree_painter.dart

import 'package:flutter/material.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';

/// A [CustomPainter] that draws connection lines between tree nodes.
///
/// The painter expects a list of root [TreeNode]s. Each node must have
/// calculated layout properties `x` and `y` which represent the top-left
/// coordinates of the node's rectangular box. Connections are drawn from the
/// bottom-center of a parent node to the top-center of each child node using
/// a simple vertical-then-horizontal path.
///
/// The painting parameters are configurable via the constructor
/// (`nodeWidth`, `nodeHeight`, `lineColor`, `lineWidth`). This class only
/// concerns itself with drawing the connection lines — rendering of the node
/// boxes or labels should be done by other widgets placed on top of or under
/// the [CustomPaint] that uses this painter.
///
/// Example
/// ```dart
/// // Given that layout has populated `x` and `y` for each node:
/// final painter = TreePainter(
///   roots: roots,
///   nodeWidth: 120,
///   nodeHeight: 48,
///   lineColor: Colors.black54,
///   lineWidth: 2.0,
/// );
///
/// // Use inside a CustomPaint. Place node widgets above using a Stack.
/// CustomPaint(
///   size: Size.infinite,
///   painter: painter,
///   child: Stack(
///     children: [
///       // ... node widgets positioned using Positioned(left: node.x, top: node.y)
///     ],
///   ),
/// );
/// ```

class TreePainter extends CustomPainter {
  /// The list of roots of the trees to paint.
  final List<TreeNode> roots;

  /// The width of each node, used to calculate connection points.
  final double nodeWidth;

  /// The height of each node, used to calculate connection points.
  final double nodeHeight;

  /// The color of the connection lines.
  final Color lineColor;

  /// The stroke width of the connection lines.
  final double lineWidth;

  /// Creates a [TreePainter].
  TreePainter({
    required this.roots,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.lineColor,
    required this.lineWidth,
  });

  /// The list of root nodes for which connections will be drawn.
  ///
  /// Each node is expected to have its `x` and `y` layout coordinates set
  /// before this painter is used.

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    for (var root in roots) {
      _drawConnections(canvas, root, paint);
    }
  }

  /// Paint the connection lines for [node] and all its descendants.
  ///
  /// The algorithm draws an orthogonal path from the parent's bottom-center
  /// to the child's top-center: it goes vertically down from the parent to a
  /// to the child's top-center: it goes vertically down from the parent to a
  /// mid Y, moves horizontally to the child's column, then vertically to the
  /// child. This produces a clear tree layout without diagonal lines.
  void _drawConnections(Canvas canvas, TreeNode node, Paint paint) {
    if (node.partner != null) {
      // We only draw from left to right to avoid drawing the line twice
      if (node.x < node.partner!.x) {
        final startX = node.x + nodeWidth;
        final startY = node.y + (nodeHeight / 2);
        final endX = node.partner!.x;
        final endY = startY;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }
    }

    if (node.children.isEmpty) return;

    // Parent center bottom
    double parentX = node.x + nodeWidth / 2;
    double parentY = node.y + nodeHeight;

    // If there is a partner, the "center" of the parent unit is between them
    if (node.partner != null) {
      // Assuming layout places partner to the right
      // Center = (Node Center + Partner Center) / 2
      // Node Center = node.x + w/2
      // Partner Center = partner.x + w/2
      parentX = (parentX + (node.partner!.x + nodeWidth / 2)) / 2;
    }

    for (var child in node.children) {
      // Child center top
      double childX = child.x + nodeWidth / 2;
      double childY = child.y;

      // Draw line
      Path path = Path();
      path.moveTo(parentX, parentY);

      // Vertical down from parent
      double midY = (parentY + childY) / 2;
      path.lineTo(parentX, midY);

      // Horizontal to child
      path.lineTo(childX, midY);

      // Vertical up to child
      path.lineTo(childX, childY);

      canvas.drawPath(path, paint);

      // Recursively draw child connections
      _drawConnections(canvas, child, paint);
    }
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) => true;
}

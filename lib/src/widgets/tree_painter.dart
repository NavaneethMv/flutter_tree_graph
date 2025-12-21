// lib/src/widgets/tree_painter.dart

import 'package:flutter/material.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';

class TreePainter extends CustomPainter {
  final List<TreeNode> roots;
  final double nodeWidth;
  final double nodeHeight;
  final Color lineColor;
  final double lineWidth;

  TreePainter({
    required this.roots,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.lineColor,
    required this.lineWidth,
  });

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

  void _drawConnections(Canvas canvas, TreeNode node, Paint paint) {
    if (node.children.isEmpty) return;

    // Parent center bottom
    double parentX = node.x + nodeWidth / 2;
    double parentY = node.y + nodeHeight;

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

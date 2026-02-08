// lib/src/layout/walkers_layout.dart

import 'package:flutter_tree_graph/flutter_tree_graph.dart';

/// A tree layout strategy based on Buchheim's linear-time improvement of
/// Walker's algorithm.
///
/// This layout algorithm produces a compact, aesthetically pleasing tree where:
/// - Parents are centered above their children.
/// - Isomorphic subtrees look identical.
/// - Partners are handled as a single unit with the primary node.
class WalkersTreeLayout extends TreeLayout {
  /// Creates a [WalkersTreeLayout].
  const WalkersTreeLayout();

  @override
  void calculateLayout(
    List<TreeNode> roots, {
    double nodeWidth = 100,
    double nodeHeight = 80,
    double horizontalSpacing = 50,
    double verticalSpacing = 100,
  }) {
    // 1. Reset and Initialize
    _resetWalkerFields(roots);

    double currentTreeStart = 0.0;

    for (var root in roots) {
      // Pass 1: Post-order traversal (Bottom-up). Calculates 'prelim' (x)
      // and 'mod'.
      _firstWalk(root, nodeWidth: nodeWidth, hSpacing: horizontalSpacing);

      // Pass 2: Pre-order traversal (Top-down). Calculates final absolute X/Y.
      _secondWalk(
        root,
        -root.x, // Initial mod so root starts at 0 relative to itself
        0, // Level
        nodeWidth: nodeWidth,
        nodeHeight: nodeHeight,
        hSpacing: horizontalSpacing,
        vSpacing: verticalSpacing,
      );

      // 3. Normalize and Shift
      // Find the bounds of this specific tree
      double minX = double.infinity;
      double maxX = double.negativeInfinity;

      _getBounds(root, (x) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
      });

      // Shift tree so minX starts at currentTreeStart
      double shiftX = currentTreeStart - minX;
      _shiftTreeXY(root, shiftX, 0);

      // Prepare for next tree: rightmost edge + spacing
      // We calculate the new max X after the shift
      double treeWidth = maxX - minX;
      // Add a buffer for the actual width of the rightmost node
      // (Bounds usually track left edge, so we need to know the width of the
      // last node)
      // For simplicity, we assume the bounds tracker saw the 'left' edge of
      // the right-most node.
      // We'll add a safety buffer of (nodeWidth * 2 + spacing) to be safe for
      // couples.
      currentTreeStart += treeWidth + (nodeWidth * 2) + horizontalSpacing;
    }
  }

  /// Reset walker-specific fields for all nodes in the hierarchy
  void _resetWalkerFields(List<TreeNode> nodes) {
    for (var node in nodes) {
      node.mod = 0;
      node.thread = null;
      node.ancestor = node;
      node.change = 0;
      node.shift = 0;
      node.number = 0;
      node.x = 0;
      node.y = 0;
      // We also need to set 'number' index for siblings
      // But we can't do it in this flat list easily if it recursively visits.
    }

    // Recursive reset + numbering
    for (var root in nodes) {
      _recursiveReset(root);
    }
  }

  void _recursiveReset(TreeNode node) {
    node.mod = 0;
    node.thread = null;
    node.ancestor = node;
    node.change = 0;
    node.shift = 0;
    node.x = 0;
    node.y = 0;

    for (int i = 0; i < node.children.length; i++) {
      var child = node.children[i];
      child.number = i; // Assign sibling index
      child.ancestor = child; // Reset ancestor to self initially
      _recursiveReset(child);
    }
  }

  /// Width of a "Logical Node Unit".
  /// Single Node = width
  /// Couple (Node + Partner) = width + spacing + width
  double _getUnitWidth(TreeNode node, double nodeWidth, double hSpacing) {
    return node.partner != null ? (nodeWidth * 2) + hSpacing : nodeWidth;
  }

  /// PASS 1: Calculate 'prelim' (x) and 'mod' values
  void _firstWalk(
    TreeNode v, {
    required double nodeWidth,
    required double hSpacing,
  }) {
    // Leaf node (no children)
    if (v.children.isEmpty) {
      TreeNode? leftSibling = v.getLeftSibling();
      if (leftSibling != null) {
        // Position to the right of the left sibling's unit
        v.x =
            leftSibling.x +
            _getUnitWidth(leftSibling, nodeWidth, hSpacing) +
            hSpacing;
      } else {
        v.x = 0;
      }
    }
    // Internal node
    else {
      TreeNode defaultAncestor = v.children[0];

      for (var w in v.children) {
        _firstWalk(w, nodeWidth: nodeWidth, hSpacing: hSpacing);
        defaultAncestor = _apportion(w, defaultAncestor, nodeWidth, hSpacing);
      }

      _executeShifts(v);

      // Determine Center of Children
      // We want to center the PARENT UNIT over the CHILDREN GROUP.

      // Children Center = (FirstChild.Left + LastChild.Right) / 2
      // LastChild.Right = LastChild.x + LastChild.UnitWidth
      double childrenCenter =
          (v.children.first.x +
              (v.children.last.x +
                  _getUnitWidth(v.children.last, nodeWidth, hSpacing))) /
          2;

      // Parent Center offset
      // Since 'v.x' represents the LEFT edge of the parent unit:
      // ParentUnitCenter = v.x + (v.UnitWidth / 2)

      // We want: ParentUnitCenter = ChildrenCenter
      // v.x + (v.UnitWidth / 2) = ChildrenCenter
      // v.x = ChildrenCenter - (v.UnitWidth / 2)

      double parentUnitWidth = _getUnitWidth(v, nodeWidth, hSpacing);
      double desiredX = childrenCenter - (parentUnitWidth / 2);

      TreeNode? leftSibling = v.getLeftSibling();
      if (leftSibling != null) {
        // Result of conflicting constraints:
        // Position based on sibling
        v.x =
            leftSibling.x +
            _getUnitWidth(leftSibling, nodeWidth, hSpacing) +
            hSpacing;
        v.mod = v.x - desiredX;
      } else {
        v.x = desiredX;
      }
    }
  }

  TreeNode _apportion(
    TreeNode v,
    TreeNode defaultAncestor,
    double nodeWidth,
    double hSpacing,
  ) {
    TreeNode? leftSibling = v.getLeftSibling();
    if (leftSibling != null) {
      TreeNode vip = v; // v inside left
      TreeNode vop = v; // v outside left
      TreeNode vim = leftSibling; // v inside right (neighbor)
      TreeNode vom =
          v.parents.first.children.first; // v outside right (leftmost sibling)

      double sip = vip.mod;
      double sop = vop.mod;
      double sim = vim.mod;
      double som = vom.mod;

      TreeNode? nextRight(TreeNode n) => n.rightmostChild ?? n.thread;
      TreeNode? nextLeft(TreeNode n) => n.leftmostChild ?? n.thread;

      while (nextRight(vim) != null && nextLeft(vip) != null) {
        vim = nextRight(vim)!;
        vip = nextLeft(vip)!;
        vom = nextLeft(vom)!;
        vop = nextRight(vop)!;

        vop.ancestor = v;

        // Calculate shift considering UNIT WIDTHS
        // shift = (min_pos_for_v) - (curr_pos_of_v)
        // min_pos_for_v = vim.x + sim + vim.UnitWidth + spacing
        double shift =
            (vim.x + sim) -
            (vip.x + sip) +
            _getUnitWidth(vim, nodeWidth, hSpacing) +
            hSpacing;

        if (shift > 0) {
          _moveSubtree(_ancestor(vim, v, defaultAncestor), v, shift);
          sip += shift;
          sop += shift;
        }

        sim += vim.mod;
        sip += vip.mod;
        som += vom.mod;
        sop += vop.mod;
      }

      if (nextRight(vim) != null && nextRight(vop) == null) {
        vop.thread = nextRight(vim);
        vop.mod += sim - sop;
      }

      if (nextLeft(vip) != null && nextLeft(vom) == null) {
        vom.thread = nextLeft(vip);
        vom.mod += sip - som;
        defaultAncestor = v;
      }
    }
    return defaultAncestor;
  }

  void _moveSubtree(TreeNode wm, TreeNode wp, double shift) {
    // Count siblings between wm and wp
    int subtrees = wp.number - wm.number;
    wp.change -= shift / subtrees;
    wp.shift += shift;
    wm.change += shift / subtrees;
    wp.x += shift;
    wp.mod += shift;
  }

  void _executeShifts(TreeNode v) {
    double shift = 0;
    double change = 0;
    for (int i = v.children.length - 1; i >= 0; i--) {
      TreeNode w = v.children[i];
      w.x += shift;
      w.mod += shift;
      change += w.change;
      shift += w.shift + change;
    }
  }

  TreeNode _ancestor(TreeNode vim, TreeNode v, TreeNode defaultAncestor) {
    // If vim's ancestor is a sibling of v (child of v's parent)
    if (v.parents.isNotEmpty) {
      final parent = v.parents.first;
      if (parent.children.contains(vim.ancestor)) {
        return vim.ancestor!;
      }
    }
    return defaultAncestor;
  }

  /// PASS 2: Calculate Absolute Coordinates
  void _secondWalk(
    TreeNode v,
    double m,
    int level, {
    required double nodeWidth,
    required double nodeHeight,
    required double hSpacing,
    required double vSpacing,
  }) {
    v.x += m;
    v.y = level * vSpacing;

    // Position Partner explicitly
    if (v.partner != null) {
      v.partner!.x = v.x + nodeWidth + hSpacing;
      v.partner!.y = v.y; // Same level
    }

    for (var w in v.children) {
      _secondWalk(
        // Recurse
        w,
        m + v.mod,
        level + 1,
        nodeWidth: nodeWidth,
        nodeHeight: nodeHeight,
        hSpacing: hSpacing,
        vSpacing: vSpacing,
      );
    }
  }

  void _shiftTreeXY(TreeNode node, double shiftX, double shiftY) {
    node.x += shiftX;
    node.y += shiftY;
    if (node.partner != null) {
      node.partner!.x += shiftX;
      node.partner!.y += shiftY;
    }
    for (var child in node.children) {
      _shiftTreeXY(child, shiftX, shiftY);
    }
  }

  void _getBounds(TreeNode node, Function(double) updateBounds) {
    updateBounds(node.x);
    // If partner exists, their right edge is further out
    if (node.partner != null) updateBounds(node.partner!.x);
    for (var child in node.children) {
      _getBounds(child, updateBounds);
    }
  }
}

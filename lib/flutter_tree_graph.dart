/// A Flutter package for displaying hierarchical tree structures.
///
/// This library provides widgets and utilities for creating interactive
/// tree visualizations with automatic layout algorithms.
library;

// Models
export 'src/models/tree_node_data.dart';

// Layouts
export 'src/layout/tree_layout.dart';
export 'src/layout/simple_layout.dart';
// Don't export walkers_layout.dart yet if not implemented

// Widgets
export 'src/widgets/tree_view.dart';

// Optional utilities
export 'src/utils/lazy_tree_controller.dart';

// DON'T export:
// - tree_builder.dart (internal utility)
// - tree_painter.dart (internal widget)

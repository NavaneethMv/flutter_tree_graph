# flutter_tree_graph

A Flutter package for displaying hierarchical tree structures with automatic layout using Walker's algorithm.

## Features

- Automatic tree layout
- Extendable data model
- Customizable node widgets
- Reactive updates
- Interactive pan & zoom
- Performance optimized

## Installation
```yaml
dependencies:
  flutter_tree_graph: ^0.1.0
```

## Usage
```dart
// Define your data model
class Person extends TreeNodeData {
  @override
  final String id;
  @override
  final String? parentId;
  final String name;
  
  Person({required this.id, this.parentId, required this.name});
}

// Use the widget
TreeView<Person>(
  data: myPeople,
  nodeBuilder: (context, person) => Text(person.name),
)
```

## Roadmap

- [x] Basic tree layout
- [x] Simple grid algorithm
- [ ] Walker's algorithm
- [ ] Drag to reposition
- [ ] Custom line styles
- [ ] Animations
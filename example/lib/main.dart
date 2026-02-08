import 'package:flutter/material.dart';
import 'package:flutter_tree_graph/flutter_tree_graph.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Partner Logic Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FamilyTreeScreen(),
    );
  }
}

// 1. Define your data model
class Person extends TreeNodeData {
  final String _id;
  final String _name;
  final List<String> _parentIds;

  final String? _partnerId;
  final Color color;

  Person(
    this._id,
    this._name, {
    List<String> parentIds = const [],
    String? partnerId,
    this.color = Colors.blue,
  }) : _parentIds = parentIds,
       _partnerId = partnerId;

  @override
  String get id => _id;

  @override
  List<String> get parentIds => _parentIds;

  @override
  String? get partnerId => _partnerId;

  String get name => _name;
}

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  // 2. Create the data
  final List<Person> familyData = [
    // --- Generation 1 (Roots) ---
    Person('grandpa', 'Grandpa', partnerId: 'grandma', color: Colors.blueGrey),
    Person(
      'grandma',
      'Grandma',
      partnerId: 'grandpa',
      color: Colors.pink.shade200,
    ),

    // --- Generation 2 ---
    // Uncle (Single)
    Person(
      'uncle',
      'Uncle Bob',
      parentIds: ['grandpa'], // Child of Grandpa
      color: Colors.orange,
    ),

    // Father (Married)
    Person(
      'dad',
      'Father',
      parentIds: ['grandpa'],
      partnerId: 'mom',
      color: Colors.blue,
    ),
    Person(
      'mom',
      'Mother',
      partnerId: 'dad', // Not strictly a child of grandpa, but linked to dad
      color: Colors.pink,
    ),

    // --- Generation 3 ---
    Person(
      'son',
      'Son',
      parentIds: ['dad'], // Child of Father
    ),
    Person(
      'daughter',
      'Daughter',
      parentIds: ['dad'], // Child of Father
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Tree with Partners')),
      body: Center(
        // 3. Use the TreeView
        child: TreeView<Person>(
          data: familyData,

          // Layout Configuration
          layout: const WalkersTreeLayout(),
          nodeWidth: 120,
          nodeHeight: 60,
          horizontalSpacing: 20,
          verticalSpacing: 100,

          // Node Builder
          nodeBuilder: (context, person) {
            return Card(
              color: person.color,
              elevation: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      person.id,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

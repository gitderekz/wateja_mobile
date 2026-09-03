import 'package:flutter/material.dart';

class LessonDetailScreen extends StatelessWidget {
  final String? id;
  const LessonDetailScreen({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Detail')),
      body: Center(child: Text('Placeholder: LessonDetailScreen ${id ?? ""}')),
    );
  }
}

import 'package:flutter/material.dart';

class Todo {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime createdAt;
  Priority priority;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.priority = Priority.medium,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'priority': priority.index,
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isCompleted: json['isCompleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        priority: Priority.values[json['priority'] ?? 1],
      );

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
  }) =>
      Todo(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt,
        priority: priority ?? this.priority,
      );
}

enum Priority { low, medium, high }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return '낮음';
      case Priority.medium:
        return '보통';
      case Priority.high:
        return '높음';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return const Color(0xFF4CAF50);
      case Priority.medium:
        return const Color(0xFFFFC107);
      case Priority.high:
        return const Color(0xFFF44336);
    }
  }
}

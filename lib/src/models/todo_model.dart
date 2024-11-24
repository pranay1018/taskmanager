class Todo {
  final String id;
  final String title;
  final String description;
  final String status;
  final List<String> tags;
  final String userId;
  final String createOn;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.tags,
    required this.userId,
    required this.createOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'tags': tags,
      'userId': userId,
      'createOn': createOn,
    };
  }

  // Convert Firestore document to Todo with null safety checks
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',  // If 'id' is null, provide an empty string as a fallback
      title: map['title'] ?? '',  // Provide default value for title
      description: map['description'] ?? '',  // Provide default value for description
      status: map['status'] ?? '',  // Provide default value for status
      tags: map['tags'] != null
          ? List<String>.from(map['tags'])  // Handle null in the 'tags' field
          : [],  // Provide an empty list if 'tags' is null
      userId: map['userId'] ?? '',  // Provide default value for userId
      createOn: map['createOn'] ?? '',  // Provide default value for createOn
    );
  }

  // Copy with method
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    List<String>? tags,
    String? userId,
    String? createOn,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      createOn: createOn ?? this.createOn,
    );
  }
}

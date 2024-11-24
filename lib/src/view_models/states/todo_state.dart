
import '../../models/todo_model.dart';

class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  final String? errorMessage;

  TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

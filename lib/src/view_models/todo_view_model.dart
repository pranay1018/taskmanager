import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanager/src/repository/firestore_service.dart';
import 'package:taskmanager/src/view_models/states/todo_state.dart';
import '../models/todo_model.dart';

final todoProvider = StateNotifierProvider<TodoViewModel, TodoState>((ref) {
  final fireStoreService = ref.watch(firestoreServiceProvider); // assuming you have a provider for FireStoreService
  return TodoViewModel(fireStoreService);
});



class TodoViewModel extends StateNotifier<TodoState> {
  final FireStoreService _fireStoreService;

  TodoViewModel(this._fireStoreService) : super(TodoState());

  // Add new Todo
  Future<void> addTodo(Todo todo) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fireStoreService.addDataToFireStore(
        todo.toMap(),
        'users/${todo.userId}/todos',
        todo.id,
      );
      state = state.copyWith(
        todos: [...state.todos, todo],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      print("Error adding todo: $e");
    }
  }

  // Get todos stream (Real-time data)
  Stream<List<Todo>> getTodosStream(String userId) {
    final collectionPath = 'users/$userId/todos';

    return _fireStoreService.getCollectionStream(collectionPath).map((docs) {
      return docs.map((doc) => Todo.fromMap(doc)).toList();
    });
  }

  // Update an existing Todo
  Future<void> updateTodo(Todo todo,String userId,String id) async {
    state = state.copyWith(isLoading: true);
    try {
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }
      if (id.isEmpty) {
        print(" id : $id");
        throw Exception( 'ID is empty');
      }

      // Update data in Firestore
      await _fireStoreService.updateDataInFireStore(
        todo.toMap(),
        'users/$userId/todos',
        id,
      );

      // Update the todo locally in the state
      state = state.copyWith(
        todos: state.todos.map((existingTodo) {
          return existingTodo.id == todo.id ? todo : existingTodo;
        }).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      print("Error updating todo: $e");
    }
  }


  // Delete a Todo
  Future<void> deleteTodo(String userId, String todoId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fireStoreService.deleteDocument('users/$userId/todos', todoId);
      // Remove todo from local state
      state = state.copyWith(
        todos: state.todos.where((todo) => todo.id != todoId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      print("Error deleting todo: $e");
    }
  }
}

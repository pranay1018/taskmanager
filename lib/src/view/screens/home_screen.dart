import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmanager/src/view/screens/add_todo_screen.dart';
import 'package:taskmanager/src/routes/app_routes.dart';
import 'package:taskmanager/src/utils/color_constants.dart';
import '../../models/todo_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/todo_view_model.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final authNotifier = ref.read(authProvider.notifier);
    final userId = FirebaseAuth.instance.currentUser
        ?.uid; // Get current user ID

    if (userId == null) {
      return const Center(child: Text('No user found'));
    }

    final todoViewModel = ref.watch(todoProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        isHomePage: true,
        onLogOut: () async {
          final result = await authNotifier.logout();
          if (result) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Successfully logged out!")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Failed to logout. Please try again.")),
            );
          }
          Navigator.pushNamed(context, AppRoutes.login);
        },
      ),
      body: StreamBuilder<List<Todo>>(
        stream: todoViewModel.getTodosStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Todos Available'));
          }

          final todos = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildSection(
                  title: 'To-Do',
                  todos: todos.where((todo) => todo.status == 'To Do').toList(),
                  todoViewModel: todoViewModel,
                ),
                const SizedBox(width: 8),
                _buildSection(
                  title: 'In Progress',
                  todos: todos
                      .where((todo) => todo.status == 'In Progress')
                      .toList(),
                  todoViewModel: todoViewModel,
                ),
                const SizedBox(width: 8),
                _buildSection(
                  title: 'Done',
                  todos: todos
                      .where((todo) => todo.status == 'Done')
                      .toList(),
                  todoViewModel: todoViewModel,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scaffoldKey.currentState!.openEndDrawer();
        },
        child: const Icon(Icons.add),
      ),
      endDrawer: Drawer(
        shape: Border.all(width: 0),
        width: MediaQuery
            .of(context)
            .size
            .width * 0.40,
        backgroundColor: ColorConstants.background,
        child: const AddTodoScreen(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Todo> todos,
    required TodoViewModel todoViewModel,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DragTarget<Todo>(
              onWillAccept: (data) => true, // Allow acceptance
              onAccept: (data) {
                // Determine the new status for the Todo based on the section
                String newStatus;
                if (title == 'To-Do') {
                  newStatus = 'To Do';
                } else if (title == 'In Progress') {
                  newStatus = 'In Progress';
                } else if (title == 'Done') {
                  newStatus = 'Done';
                } else {
                  return; // Just in case, handle unexpected sections
                }

                print(newStatus);
                // Update the Todo's status using the view model
                // todoViewModel.updateTodoStatus(data.copyWith(status: newStatus));
                // Print which item is being dragged into which section
                print('Dragged Todo: ${data.title} into $newStatus');
              },
              builder: (context, candidateData, rejectedData) {
                // Visual feedback for when the item is being dragged over
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Colors.blue.withOpacity(0.2) // Feedback when accepting
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Draggable<Todo>(
                        data: todo,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.7, // Adjust opacity for better visibility
                            child: NoteCard(text: todo.title),
                          ),
                        ),
                        childWhenDragging: const Opacity(
                          opacity: 0.5,
                          child: SizedBox.shrink(),
                        ),
                        child: NoteCard(text: todo.title),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class NoteCard extends StatelessWidget {
  final String text;

  const NoteCard({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

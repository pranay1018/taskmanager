import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmanager/src/routes/app_routes.dart';
import '../../models/todo_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/color_constants.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/todo_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'add_todo_screen.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final authNotifier = ref.read(authProvider.notifier);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('No user found'));
    }

    final todoViewModel = ref.watch(todoProvider.notifier);

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        isHomePage: true,
        onLogOut: () async {
          final result = await authNotifier.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result
                    ? "Successfully logged out!"
                    : "Failed to logout. Please try again.",
              ),
            ),
          );
          if (result) {
            Navigator.pushNamed(context, AppRoutes.login);
          }
        },
      ),
      body: Container(
        color: ColorConstants.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActionButton(
                    hasFullWidth: false,
                    label: 'Add Task',
                    backgroundColor: ColorConstants.primary,
                    onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                  ),
                  const SizedBox(height: 8),
                  _buildSearchBar(context),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Todo>>(
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
                  final filteredTodos = todos
                      .where((todo) =>
                      todo.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildSection(
                          context: context,
                          status: 'To-Do',
                          todos: filteredTodos
                              .where((todo) => todo.status == 'To Do')
                              .toList(),
                        ),
                        const SizedBox(width: 8),
                        _buildSection(
                          context: context,
                          status: 'In Progress',
                          todos: filteredTodos
                              .where((todo) => todo.status == 'In Progress')
                              .toList(),
                        ),
                        const SizedBox(width: 8),
                        _buildSection(
                          context: context,
                          status: 'Done',
                          todos: filteredTodos
                              .where((todo) => todo.status == 'Done')
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.4,
        backgroundColor: ColorConstants.background,
        child: const AddTodoScreen(),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Row(
        children: [
          Text("Search", style: AppTheme.header),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _searchQuery = query;
                  });
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: ColorConstants.primary),
                ),
              ),
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: 'Recent',
            onChanged: (String? newValue) {
              // Handle sorting logic
            },
            items: <String>['Recent', 'Oldest', 'A-Z', 'Z-A']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String status,
    required List<Todo> todos,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorConstants.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorConstants.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              color: ColorConstants.primary,
              child: Text(
                status,
                style: AppTheme.header.copyWith(color: ColorConstants.background),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DragTarget<Todo>(
                onWillAccept: (data) => true,
                onAccept: (data) {
                  final newStatus = status == 'To-Do'
                      ? 'To Do'
                      : status == 'In Progress'
                      ? 'In Progress'
                      : 'Done';
                  ref.read(todoProvider.notifier).updateTodo(
                    data.copyWith(status: newStatus),
                    data.userId,
                    data.createOn,
                  );
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: candidateData.isNotEmpty
                          ? Colors.blueAccent.withOpacity(0.1)
                          : ColorConstants.background,
                      borderRadius: BorderRadius.circular(8),
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
                              opacity: 0.7,
                              child: NoteCard(todo: todo),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: NoteCard(todo: todo),
                          ),
                          child: NoteCard(todo: todo),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NoteCard extends ConsumerWidget {
  final Todo todo;

  const NoteCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(todo.title),
            const SizedBox(height: 6),
            _buildDescription(todo.description),
            const SizedBox(height: 6),
            _buildCreatedAt(todo.createOn),
            const SizedBox(height: 10),
            if (todo.tags.isNotEmpty) _buildTags(todo.tags),
            const SizedBox(height: 10),
            _buildActionButtons(ref, context, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCreatedAt(String createdAt) {
    return Text(
      'Created at: $createdAt',
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) {
        return Chip(
          label: Text(tag, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.blue[100],
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(WidgetRef ref, BuildContext context, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          label: 'Delete',
          backgroundColor: Colors.red[400]!,
          onPressed: () => ref
              .read(todoProvider.notifier)
              .deleteTodo(todo.userId, todo.createOn),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          label: 'Edit',
          backgroundColor: Colors.blue[300]!,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.viewDetails, arguments: {'todo': todo, 'isEditing': true}),
        ),
        if (!isSmallScreen) const SizedBox(width: 8),
        if (!isSmallScreen)
          _buildActionButton(
            label: 'View',
            backgroundColor: Colors.blue[700]!,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.viewDetails, arguments: {'todo': todo, 'isEditing': false}),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(80, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}








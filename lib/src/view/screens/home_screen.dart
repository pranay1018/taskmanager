import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/auth_view_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_app_bar.dart';

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context,WidgetRef ref) {
//
//     final authState = ref.watch(authProvider);
//     final authNotifier = ref.read(authProvider.notifier);
//
//     return  Scaffold(
//       appBar: CustomAppBar(
//         isHomePage: true,
//         onLogOut: () async {
//           final result = await authNotifier.logout();
//           if (result) {
//             const SnackBar(
//                 content: Text("Successfully logged out!"));
//           } else {
//             const SnackBar(
//                 content: Text("Failed to logout Please Try again "));
//           }
//           Navigator.pushNamed(context, AppRoutes.login);
//         },
//         onLoginTap: () {
//         },
//         onSignupTap: () {
//         },
//       ),
//       body: const Text("data"),
//     );
//   }
// }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> todoNotes = ['Task 1', 'Task 2', 'Task 3'];
  final List<String> inProgressNotes = [];
  final List<String> doneNotes = [];


  @override
  Widget build(BuildContext context) {

    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
        appBar: CustomAppBar(
        isHomePage: true,
        onLogOut: () async {
          final result = await authNotifier.logout();
          if (result) {
            const SnackBar(
                content: Text("Successfully logged out!"));
          } else {
            const SnackBar(
                content: Text("Failed to logout Please Try again "));
          }
          Navigator.pushNamed(context, AppRoutes.login);
        },
        onLoginTap: () {
        },
        onSignupTap: () {
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildSection(
              title: 'To-Do',
              notes: todoNotes,
              onAccept: (note) {
                setState(() {
                  todoNotes.add(note);
                });
              },
            ),
            const SizedBox(width: 8),
            _buildSection(
              title: 'In Progress',
              notes: inProgressNotes,
              onAccept: (note) {
                setState(() {
                  inProgressNotes.add(note);
                });
              },
            ),
            const SizedBox(width: 8),
            _buildSection(
              title: 'Done',
              notes: doneNotes,
              onAccept: (note) {
                setState(() {
                  doneNotes.add(note);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> notes,
    required Function(String) onAccept,
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
            child: DragTarget<String>(
              onWillAccept: (data) => true,
              onAccept: (data) {
                // Remove the task from other columns
                setState(() {
                  todoNotes.remove(data);
                  inProgressNotes.remove(data);
                  doneNotes.remove(data);
                  onAccept(data);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Draggable<String>(
                        data: note,
                        feedback: Material(
                          color: Colors.transparent,
                          child: NoteCard(
                            text: note,
                          ),
                        ),
                        childWhenDragging: const Opacity(
                          opacity: 0.5,
                          child: SizedBox.shrink(),
                        ),
                        child: NoteCard(text: note),
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

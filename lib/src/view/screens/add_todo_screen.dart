import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanager/src/view_models/auth_view_model.dart';

import '../../models/todo_model.dart';
import '../../view_models/todo_view_model.dart';


class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  AddTodoScreenState createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for task name and description
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? selectedStatus; // For status dropdown
  List<String> tags = []; // To store selected tags
  final List<String> availableTags = ['Bug', 'Feature', 'Urgent', 'Improvement'];
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField('Task Name', 'Please enter a task name', _taskNameController),
                    SizedBox(height: 10),
                    _buildDescriptionField(),
                    SizedBox(height: 20),
                    _buildStatusDropdown(),
                    SizedBox(height: 20),
                    _buildTagInput(),
                    SizedBox(height: 10),
                    _buildTagsWrap(),
                    SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Create Task', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  TextFormField _buildTextField(String label, String validationMessage, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? validationMessage : null,
    );
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'You can write a description here...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  DropdownButtonFormField<String> _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      onChanged: (newValue) => setState(() => selectedStatus = newValue),
      items: ['To Do', 'In Progress', 'Completed']
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null ? 'Please select a status' : null,
    );
  }

  TextField _buildTagInput() {
    return TextField(
      controller: _tagController,
      decoration: InputDecoration(
        labelText: 'Add Custom Tag',
        suffixIcon: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            if (_tagController.text.trim().isNotEmpty) {
              setState(() {
                tags.add(_tagController.text.trim());
                _tagController.clear();
              });
              print(tags);
            }
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }


  Consumer _buildSubmitButton() {
    return Consumer(builder: (context, ref, child) {
      final auth = ref.watch(authProvider);
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final id = DateTime.now().toString();
            final todo = Todo(
              id: id ?? "",
              title: _taskNameController.text.trim() ?? "",
              description: _descriptionController.text.trim() ?? "",
              status: selectedStatus ?? 'To Do',
              tags: tags ?? [],
              userId: FirebaseAuth.instance.currentUser!.uid ?? "",
              createOn: id ?? "",
            );

            // Call the addTodo method using the TodoViewModel
            ref.read(todoProvider.notifier).addTodo(todo);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task Created')));
            Navigator.of(context).pop();
          }
        },
        child: Center(child: Text('Create Task', style: TextStyle(fontSize: 16, color: Colors.white))),
      );
    },);
  }

  void _handleTagSelection(String tag, bool selected) {
    setState(() {
      if (selected) {
        if (!tags.contains(tag)) {
          tags.add(tag);
          availableTags.remove(tag); // Remove from available tags
        }
      } else {
        tags.remove(tag);
        if (!availableTags.contains(tag)) {
          availableTags.add(tag); // Re-add to available tags
        }
      }
    });
  }

  Wrap _buildTagsWrap() {
    return Wrap(
      spacing: 8.0,
      children: [
        // Default tags available for selection
        ...availableTags.map((tag) => ChoiceChip(
          label: Text(tag),
          selected: false,
          onSelected: (selected) => _handleTagSelection(tag, selected),
        )),
        // Display selected custom tags as chips with delete functionality
        ...tags.map((tag) => Chip(
          label: Text(tag),
          backgroundColor: Colors.blue.shade100,
          onDeleted: () => _handleTagSelection(tag, false), // Remove tag on delete
        )),
      ],
    );
  }
}

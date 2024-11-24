import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanager/src/view_models/todo_view_model.dart';
import '../../models/todo_model.dart';

class ViewDetailScreen extends ConsumerStatefulWidget {
  final Todo todo;
  final bool isEditing;

  const ViewDetailScreen({super.key, required this.todo, this.isEditing = false});

  @override
  ConsumerState<ViewDetailScreen> createState() => _ViewDetailScreenState();
}

class _ViewDetailScreenState extends ConsumerState<ViewDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _createdOnController;

  late bool _isEditing;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;  // Initialize _isEditing from the widget's parameter
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    _createdOnController = TextEditingController(text: widget.todo.createOn);
    _tags = List.from(widget.todo.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _createdOnController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      createOn: _createdOnController.text,
      tags: _tags,
    );

    ref.read(todoProvider.notifier).updateTodo(updatedTodo, updatedTodo.userId, updatedTodo.createOn);

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully!')),
    );
  }

  void _addTag(String tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 5,
        backgroundColor: Colors.teal[700],
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              color: Colors.white,
              shadowColor: Colors.black45,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Task Title'),
                    _buildEditableField(_titleController, enabled: _isEditing),
                    const Divider(height: 30, thickness: 1.2, color: Colors.grey),

                    _buildFieldLabel('Description'),
                    _buildEditableField(_descriptionController, enabled: _isEditing, maxLines: 5),
                    const Divider(height: 30, thickness: 1.2, color: Colors.grey),

                    _buildFieldLabel('Created On'),
                    _buildEditableField(_createdOnController, enabled: _isEditing, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                    const Divider(height: 30, thickness: 1.2, color: Colors.grey),

                    _buildFieldLabel('Tags'),
                    if (_tags.isEmpty)
                      const Text('No tags added', style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8.0,
                        children: _tags
                            .map(
                              (tag) => Chip(
                            label: Text(tag),
                            deleteIcon: _isEditing ? const Icon(Icons.close) : null,
                            onDeleted: _isEditing ? () => _removeTag(tag) : null,
                          ),
                        )
                            .toList(),
                      ),
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onSubmitted: (value) {
                                if (value.isNotEmpty) _addTag(value);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Add a tag',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent[400],
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Save', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, {bool enabled = true, int maxLines = 1, TextStyle? style}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: style ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      decoration: InputDecoration(
        border: enabled ? const OutlineInputBorder() : InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
    );
  }
}

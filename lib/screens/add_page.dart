import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todoData = widget.todo;
    if(todoData != null){
      isEdit = true;
      final title = todoData['title'];
      final description = todoData['description'];

      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Todo":  "Add Todo"
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: "Title"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: "Description"),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
              onPressed: isEdit ? editTodo : submitTodo,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                isEdit ? "Update" : "Submit"
                            ),
              )
          )
        ],
      ),
    );
  }

  Future<void> editTodo() async {
    final todo = widget.todo;
    if (todo == null){
      showMessage("You can't call updated without todo data.");
      return;
    }
    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json"
        }
    );

    if(response.statusCode == 200) {
      titleController.text = '';
      descriptionController.text = '';
      const message = "ToDo updated successfully.";
      showMessage(message);
    }else{
      const message = "Error occurred while updating todo.";
      showMessage(message, messageType: 'failed');
    }
  }

  Future<void> submitTodo() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    const url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json"
        }
    );
    if(response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      const message = "ToDo added successfully.";
      showMessage(message);
    }else{
      const message = "Error occurred while adding todo.";
      showMessage(message, messageType: 'failed');
    }
  }
  void showMessage(String message, {String messageType = "success"}){
    Color color = Colors.white;

    if (messageType != 'success'){
      color = Colors.red;
    }

    final snackBar = SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.black
          ),
        ),

      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

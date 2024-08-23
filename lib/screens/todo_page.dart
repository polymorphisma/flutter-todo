import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_test/screens/add_page.dart';

class TodoListPage extends StatefulWidget {
  const   TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchToDo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List."),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchToDo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                "No ToDo Item",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text("${index+1  }"),),
                    title: Text(item['title'].toString()),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if(value == 'edit'){
                          navigateToEditPage(item);
                        } else if (value == 'delete'){
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context){
                        return [
                          const PopupMenuItem(
                            value: "edit",
                            child: Text("Edit"),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("Delete"),
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          label: const Text("Add Todo")
      ),
    );
  }
  Future <void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });

    fetchToDo();
  }


  Future <void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });

    fetchToDo();
  }
  Future<void> fetchToDo() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=20";
    final uri = Uri.parse(url);

    final response = await http.get(uri);
    if(response.statusCode == 200){
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }else{
      const message = 'Error while fetching data.';
      showMessage(message, messageType: "error");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future <void> deleteById(String id) async{
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);


    if(response.statusCode == 200){
      final filteredItems = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItems;
      });
    }else{
      const message = 'Error while editing.';
      showMessage(message, messageType: "error");
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

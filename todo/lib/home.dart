import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo/firebase/firebase.dart';

class Task extends StatefulWidget {
  Task({super.key});

  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  final Firestore firestore = Firestore();
  final TextEditingController _controller = TextEditingController();
  bool _isInputVisible = false; // To toggle the visibility of the input fields

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text("To-do list"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isInputVisible = !_isInputVisible; // Toggle visibility
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isInputVisible) // Show input fields if visible
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Enter task",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        firestore.addTodo(
                          taskName: _controller.text,
                          time: '12', // Adjust as necessary
                        );
                        _controller.clear();
                        // Optionally show a snackbar or some feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Todo added!")),
                        );
                      }
                    },
                    child: Text("Add"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.getTodos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Walang Laman"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    String todo = document["todo"];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black),
                      ),
                      tileColor: Colors.brown[200],
                      title: Text(todo),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

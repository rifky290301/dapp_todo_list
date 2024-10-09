import 'package:flutter/material.dart';
import 'todo_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TodoService _todoService;
  List<Map<String, dynamic>> tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _todoService = TodoService();
    // ! SEHARUSNYA TIDAK SEPERTI INI
    Future.delayed(const Duration(milliseconds: 2000), () {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    int taskCount = await _todoService.getTaskCount();
    List<Map<String, dynamic>> loadedTasks = [];

    for (int i = 0; i < taskCount; i++) {
      var task = await _todoService.getTask(i);
      loadedTasks.add({
        'task': task[0],
        'isCompleted': task[1],
      });
    }

    setState(() {
      tasks = loadedTasks;
    });
  }

  Future<void> _createTask() async {
    String task = _taskController.text;
    await _todoService.createTask(task);
    _taskController.clear();
    _loadTasks();
  }

  Future<void> _updateTask(int index) async {
    await _todoService.updateTask(index, "Updated Task Name", true);
    _loadTasks();
  }

  Future<void> _deleteTask(int index) async {
    await _todoService.deleteTask(index);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Decentralized Todo List')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _taskController,
                decoration: const InputDecoration(labelText: 'New Task'),
              ),
            ),
            ElevatedButton(
              onPressed: _createTask,
              child: const Text('Add Task'),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: tasks.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(tasks[index]['task']),
            //         trailing: tasks[index]['isCompleted']
            //             ? const Icon(Icons.check, color: Colors.green)
            //             : ElevatedButton(
            //                 onPressed: () => _completeTask(index),
            //                 child: const Text('Complete'),
            //               ),
            //       );
            //     },
            //   ),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task['task']),
                    subtitle: Text(task['isCompleted'] ? "Completed" : "Not Completed"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            // Panggil fungsi updateTask di sini
                            // await _todoService.updateTask(index, "Updated Task Name", true);
                            _updateTask(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Panggil fungsi deleteTask di sini
                            // await _todoService.deleteTask(index);
                            _deleteTask(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

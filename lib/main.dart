import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  tasksRepository = jsonToListOfTask(preferences.getStringList('tasks'));

  runApp(TodoComponent(
    preferences: preferences,
    child: const Application(),
  ));
}

List<String> listOfTaskToJson(List<Task> tasks) {
  return tasks.map((e) => {
    'title': e.title,
    'description': e.description,
    'isComplete': e.isComplete,
  }).map((e) => jsonEncode(e)).toList();
}

List<Task> jsonToListOfTask(List<String>? data) {
  if (data == null) {
    return <Task>[];
  }
  return data.map((task) => jsonDecode(task)).map((task) {
    return Task(
      title: task['title'],
      description: task['description'],
      isComplete: task['isComplete'],
    );
  }).toList();
}

// TODO: НАКИНУЛСЯ!

// TODO: добавь FireStore
// TODO: залей в PlayMarket

class Application extends StatelessWidget {

  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        typography: Typography.material2021(),
      ),
      home: const DefaultTabController(
          length: 2,
          child: MainScreen()
      ),
    );
  }
}

class MainScreen extends StatelessWidget {

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final component = TodoComponent.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VersatileTodo'),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       TODO: create profileScreen
        //     },
        //     icon: const Icon(Icons.person_outline),
        //   )
        // ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Actual',),
            Tab(text: 'Completed',),
          ],
        ),
      ),
      body: TabBarView(
          children: [
            ListTasks(component.actualTasks() ?? <Task>[]),
            ListTasks(component.completedTasks() ?? <Task>[]),
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final route = MaterialPageRoute(
            builder: (context) => CreateTaskScreen(),
          );

          Navigator.push(context, route);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ListTasks extends StatelessWidget {

  final List<Task> tasks;

  const ListTasks(
    this.tasks,
    {
      super.key,
    }
  );

  @override
  Widget build(BuildContext context) {
    final component = TodoComponent.of(context);

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks.elementAt(index);

        return Dismissible(
          key: Key(task.title),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            component.deleteTask(task);
          },
          background: Container(
            color: Colors.red.shade200,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.delete_outline),
          ),
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Checkbox(
              value: task.isComplete,
              onChanged: (value) {
                component.changeTask(task: task, isComplete: value);
              },
            ),
            onTap: () {
              final route = MaterialPageRoute(
                builder: (context) => ChangeTaskScreen(task: task,),
              );
              Navigator.push(context, route);
            },
          ),
        );
      },
    );
  }
}


class CreateTaskScreen extends StatelessWidget {

  const CreateTaskScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final component = TodoComponent.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Title:',
                ),
                onChanged: (value) {
                  component.setDataTask(title: value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Description:',
                ),
                onChanged: (value) {
                  component.setDataTask(description: value);
                },
              ),
            ),
            ElevatedButton(
              onPressed: component.isValid ? () {
                final task = Task(
                  title: component.title,
                  description: component.description,
                );
                component.addTask(task);
                Navigator.pop(context);
              } : null,
              child: const Text('Create task'),
            )
          ],
        ),
      ),
    );
  }
}

class ChangeTaskScreen extends StatelessWidget {

  final Task task;

  const ChangeTaskScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final component = TodoComponent.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
              ),
              child: TextFormField(
                initialValue: task.title,
                decoration: const InputDecoration(
                  labelText: 'Title:',
                ),
                onChanged: (value) {
                  component.setDataTask(title: value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
              ),
              child: TextFormField(
                initialValue: task.description,
                decoration: const InputDecoration(
                  labelText: 'Description:',
                ),
                onChanged: (value) {
                  component.setDataTask(description: value);
                },
              ),
            ),
            ElevatedButton(
              onPressed: component.isValid ? () {
                component.changeTask(
                  task: task,
                  title: component.title,
                  description: component.description,
                );
                Navigator.pop(context);
              } : null,
              child: const Text('Change task'),
            )
          ],
        ),
      ),
    );
  }
}



var tasksRepository = <Task>[];

class Task {

  final String title;
  final String description;
  final bool isComplete;

  const Task({
    required this.title,
    this.description = '',
    this.isComplete = false,
  });

  Task copyWith({
    String? title,
    String? description,
    bool? isComplete,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class TodoComponent extends StatefulWidget {

  final SharedPreferences preferences;
  final Widget child;

  const TodoComponent({
    super.key,
    required this.preferences,
    required this.child,
  });

  static TodoState of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_InheritedTodo>();
    assert(result != null, 'No TodoComponent found in context');
    return result!.state;
  }

  @override
  State<TodoComponent> createState() {
    return TodoState();
  }
}

class TodoState extends State<TodoComponent> {

  var title = '';
  var description = '';

  bool get isValid {
    return title.trim().isNotEmpty;
  }

  void saveTasksRepository() {
    widget.preferences.setStringList('tasks', listOfTaskToJson(tasksRepository));
  }

  void setDataTask({
    String? title,
    String? description,
  }) {
    setState(() {
      this.title = title ?? this.title;
      this.description = description ?? this.description;
    });
  }

  void addTask(Task task) {
    setState(() {
      tasksRepository.add(task);
      saveTasksRepository();
    });
  }

  void deleteTask(Task task) {
    setState(() {
      tasksRepository.remove(task);
      saveTasksRepository();
    });
  }

  void changeTask({
    required Task task,
    String? title,
    String? description,
    bool? isComplete,
  }) {
    setState(() {
      deleteTask(task);
      addTask(task.copyWith(
        title: title,
        description: description,
        isComplete: isComplete,
      ));
    });
  }

  List<Task>? completedTasks() {
    return tasksRepository.where((task) => task.isComplete == true).toList();
  }

  List<Task>? actualTasks() {
    return tasksRepository.where((task) => task.isComplete == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedTodo(
      state: this,
      child: widget.child,
    );
  }
}

class _InheritedTodo extends InheritedWidget {

  final TodoState state;

  const _InheritedTodo({
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedTodo oldWidget) {
    return true;
  }
}
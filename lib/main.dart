import 'package:flutter/material.dart';

void main() {
  tasksRepository = [
    Task(
      title: 'Test task 1',
      description: 'Test description',
    ),
    Task(
        title: 'Test task 2',
        description: 'Test description',
        isComplete: true
    ),
    Task(
      title: 'Test task 3',
      description: 'Test description',
    ),
  ];
  runApp(const TodoComponent(
      child: Application()
  ));
}

// TODO: НАКИНУЛСЯ!

// TODO: залей в гитхаб
// TODO: добавь sharedPreferences
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

        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Checkbox(
            value: task.isComplete,
            onChanged: (value) {
              component.changeTask(task: task, isComplete: value);
            },
          ),
        );
      },
    );
  }
}


class CreateTaskScreen extends StatelessWidget {

  const CreateTaskScreen({super.key});

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

  final Widget child;

  const TodoComponent({
    super.key,
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
    });
  }

  void deleteTask(Task task) {
    setState(() {
      tasksRepository.remove(task);
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
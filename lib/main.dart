import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:todo_app_with_persistance/model/todo_item.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<TodoItem>(TodoItemAdapter());
  await Hive.openBox('todoItemBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Todo app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final taskController = TextEditingController();
  var uuid = Uuid();
  Box todoItemBox;
  List<TodoItem> tasks = [];
  List<Widget> get items => tasks.map((item) => format(item)).toList();

  Widget format(TodoItem item) {
    return Dismissible(
      key: Key(item.id.toString()),
      child: FlatButton(
        onPressed: () => _toggleComplete(item),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 6.0),
          color: item.isComplete == '0'
              ? Colors.blueGrey.shade900
              : Colors.green.shade400,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                item.task,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              trailing: Icon(
                item.isComplete == '0'
                    ? Icons.radio_button_unchecked
                    : Icons.radio_button_checked,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      onDismissed: (DismissDirection direction) => _deleteItem(item),
    );
  }

  void _addNewTodo() {
    // add new todo logic here...
    TodoItem newItem =
        TodoItem(id: uuid.v4(), task: taskController.text, isComplete: '0');
    setState(() {
      tasks.add(newItem);
    });
    todoItemBox.put('todos', tasks);
    taskController.clear();
  }

  void _toggleComplete(TodoItem item) {
    setState(() {
      item.isComplete = item.isComplete == '0' ? '1' : '0';
    });
    todoItemBox.put('todos', tasks);
  }

  void _deleteItem(TodoItem item) {
    // delete item logic here
    setState(() {
      tasks.remove(item);
    });
    todoItemBox.put('todos', tasks);
  }

  void _deleteAll() {
    setState(() {
      tasks = [];
    });
    todoItemBox.put('todos', tasks);
  }

  @override
  void initState() {
    super.initState();
    todoItemBox = Hive.box('todoItemBox');
    List<dynamic> results = todoItemBox.get('todos');
    if (results != null) {
      setState(() {
        for (var item in results) {
          tasks.add(item);
        }
      });
    }

    // Hive.registerAdapter(TodoItemAdapter());
    // _openBox();
    // print('todoItemBox: $todoItemBox');
    // var taskList = todoItemBox.get('todos');
    // if (taskList != null) {
    //   print(taskList);
    // }
  }

  // Future _openBox() async {
  //   var dir = await getApplicationDocumentsDirectory();
  //   Hive.init(dir.path);
  //   todoItemBox = await Hive.openBox('todoItemBox');
  //   // tasks = todoItemBox.get('todos');
  //   return;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: tasks.length == 0
            ? Text(
                'No Todos yet...',
                style: TextStyle(fontSize: 36, color: Colors.white),
              )
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return items[index];
                },
              ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // delete all todo
              FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(Icons.delete_sweep),
                onPressed: () {
                  Alert(
                    context: context,
                    type: AlertType.warning,
                    title: 'Delete all todos',
                    desc: "Are you sure you want to delete all todos?",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "SURE",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          _deleteAll();
                          Navigator.pop(context);
                        },
                        color: Colors.blue,
                      ),
                      DialogButton(
                        child: Text(
                          "CANCEL",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.red,
                      )
                    ],
                    closeFunction: () {},
                  ).show();
                },
              ),

              SizedBox(
                height: 16.0,
              ),

              // add new todo
              FloatingActionButton(
                onPressed: () {
                  Alert(
                    context: context,
                    title: "Add new todo...",
                    content: Column(
                      children: <Widget>[
                        TextField(
                          controller: taskController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.assignment_turned_in),
                            labelText: 'enter todo...',
                          ),
                        ),
                      ],
                    ),
                    buttons: [
                      DialogButton(
                        onPressed: () {
                          _addNewTodo();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "SUBMIT",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      )
                    ],
                    closeFunction: () {},
                  ).show();
                },
                tooltip: 'add new todo...',
                child: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

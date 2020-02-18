import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_todoapp_provider/models/todo.dart';
import 'package:flutter_todoapp_provider/providers/edit_mode.dart';
import 'package:flutter_todoapp_provider/providers/todo_pool.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final List<Todo> initialTodos = [
    Todo(done: false, text: 'Buy milk'),
    Todo(done: false, text: 'Watch Netflix'),
    Todo(done: false, text: 'Play Fortnite'),
    Todo(done: false, text: 'Sleep Outside'),
  ];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TodoPool>(create: (context) => TodoPool(initialTodos)),
        ChangeNotifierProvider<EditMode>(create: (context) => EditMode(-1)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.purple,
        ),
        home: IndexScreen(),
      ),
    );
  }
}

class IndexScreen extends StatelessWidget {
  const IndexScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditMode>(
      builder: (context, editMode, children) {
        if (editMode.isActive()) {
          return GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              } 
            },
            child: buildScaffold(),
          );
        } else {
          return buildScaffold();
        }
      },
    );
  }

  Scaffold buildScaffold() {
    return Scaffold(
        appBar: AppBar(
          title: Text('TodoApp'),
        ),
        body: Column(
          children: <Widget>[
            Flexible(child: TodoInput()),
            Expanded(
              child: Consumer<TodoPool>(
                builder: (context, todoPool, children) {
                  return ListView.builder(
                    itemCount: todoPool.todos.length,
                    itemBuilder: (BuildContext context, int idx) {                    
                      return TodoItem(todoPool: todoPool, index: idx);
                    }
                  );
                }
              ),
            ),
          ],
        )
      );
  }
}

class TodoItem extends StatefulWidget {
  const TodoItem({
    Key key,
    @required this.todoPool,
    @required this.index,
  }) : super(key: key);

  final TodoPool todoPool;
  final int index;

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(
      text: widget.todoPool.todos[widget.index].text
    );
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditMode>(
      builder: (context, editMode, child) {
        return editMode.isActive() && editMode.editIndex == widget.index 
          ? buildEditMode(editMode)
          : buildStaticMode(editMode);
      }
    );
  }

  ListItem buildStaticMode(EditMode editMode) {
    Todo currentTodo = widget.todoPool.todos[widget.index];
    return ListItem(
      bottom: widget.index == widget.todoPool.todos.length - 1,
      color: currentTodo.done ? Colors.green[100] : Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () => editMode.editIndex = widget.index,
            child: Text(currentTodo.text)
          ),
          Row(
            children: <Widget>[
              if (!currentTodo.done) SizedBox(
                height: 24.0,
                width: 48.0,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.check_circle_outline),
                  color: Colors.green, 
                  onPressed: () => widget.todoPool.checkTodo(widget.index),
                ),
              ),
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.remove_circle_outline),
                  color: Colors.red, 
                  onPressed: () => widget.todoPool.removeTodo(widget.index),
                ),
              ),
            ],
          )
        ],
      )
    );
  }

  ListItem buildEditMode(EditMode editMode) {
    return ListItem(
      color: Colors.grey[200],
      bottom: widget.index == widget.todoPool.todos.length - 1, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _editingController,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0),
                isDense: true,
                // hintText: widget.todoPool.todos[widget.index]
              ),
              style: TextStyle(fontSize: 14.0),
              onSubmitted: (String value) {
                Todo currentTodo = widget.todoPool.todos[widget.index];
                widget.todoPool.editTodo(
                  widget.index, 
                  currentTodo.copyWith(
                    text: value,
                  )
                );
                editMode.reset();
                // todoPool.addTodo(value);
                // textController.clear();
              },
            ),
          )
        ]
      )
    );
  }
}

class TodoInput extends StatefulWidget {
  const TodoInput({
    Key key,
  }) : super(key: key);

  @override
  _TodoInputState createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoPool = Provider.of<TodoPool>(context);
    return ListItem(
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(0),
          isDense: true,
          hintText: 'Add New Item'
        ),
        style: TextStyle(fontSize: 14.0),
        onSubmitted: (String value) {
          todoPool.addTodo(
            Todo(
              done: false,
              text: value,
            )
          );
          _textController.clear();
        },
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    Key key,
    @required this.child,
    this.bottom = false,
    this.color = Colors.transparent,
  }) : super(key: key);

  final bool bottom;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    BorderSide bottomSideBorder = this.bottom 
      ? BorderSide( color: Colors.transparent ) 
      : BorderSide( width: 1.0, color: Colors.grey[300] );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        border: Border(
          bottom: bottomSideBorder
        )
      ),
      child: this.child,
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_todoapp_provider/models/todo.dart';

class TodoPool with ChangeNotifier {
  List<Todo> _todos;

  TodoPool(this._todos);

  List<Todo> get todos => _todos;

  set todos(List<Todo> newTodos) {
    _todos = newTodos;
    notifyListeners();
  }

  void addTodo(Todo todo) {
    todos = _todos..add(todo);
  }

  void checkTodo(int idx) {
    if (idx < 0 || idx >= _todos.length) {
      throw Exception();
    }

    editTodo(idx, _todos[idx].copyWith(
      done: true,
    ));
  } 

  void editTodo(int idx, Todo todo) {
    if (idx < 0 || idx >= _todos.length) {
      throw Exception();
    }
    
    todos = _todos..[idx] = todo;
  }

  void removeTodo(int idx) {
    todos = _todos..removeAt(idx);
  }
}
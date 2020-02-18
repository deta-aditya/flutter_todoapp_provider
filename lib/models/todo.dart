
import 'package:flutter/widgets.dart';

@immutable
class Todo {
  final bool done;
  final String text;

  Todo({ this.done, this.text });

  Todo copyWith({bool done, String text}) {
    return Todo(
      done: done ?? this.done,
      text: text ?? this.text
    );
  }
}
import 'package:flutter/widgets.dart';

class EditMode with ChangeNotifier {
  int _editIndex;

  EditMode(this._editIndex);

  int get editIndex => _editIndex;

  set editIndex(int newEditIndex) {
    _editIndex = newEditIndex;
    notifyListeners();
  }

  void reset() {
    editIndex = -1;
  }

  bool isActive() {
    return _editIndex >= 0;
  }
}

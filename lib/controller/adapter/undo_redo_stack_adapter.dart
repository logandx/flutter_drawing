import 'package:flutter/material.dart';

abstract class UndoRedoStackAdapter {
  const UndoRedoStackAdapter();

  void undo();

  void redo();

  ValueNotifier<bool> get canRedo;
}
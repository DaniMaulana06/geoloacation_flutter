import 'dart:typed_data';
import 'package:crud_app/features/todo/domain/entities/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();

  Future<void> addTodo(Todo todo, {Uint8List? signatureBytes});

  Future<void> updateTodo(Todo todo, {Uint8List? signatureBytes});

  Future<void> deleteTodo(int id);

  Future<void> exportToPdf(List<Todo> todos);
}

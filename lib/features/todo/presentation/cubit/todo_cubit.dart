import 'dart:typed_data';
import 'package:crud_app/features/todo/domain/entities/todo.dart';
import 'package:crud_app/features/todo/domain/repositories/todo_repository.dart';
import 'package:crud_app/features/todo/domain/usecases/export_pdf.dart';
import 'package:crud_app/features/todo/presentation/cubit/todo_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository repository;
  final ExportPdf exportPdf;

  TodoCubit(this.repository, this.exportPdf) : super(TodoInitial());

  /// Mengubah exception mentah menjadi pesan yang ramah untuk user
  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('ClientException') ||
        msg.contains('Connection refused') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Network is unreachable') ||
        msg.contains('Connection timed out')) {
      return 'Tidak ada sinyal. Periksa koneksi internet Anda.';
    }
    return msg;
  }

  Future<void> getTodos({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(TodoLoading());
    }
    try {
      final todos = await repository.getTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: _friendlyError(e)));
    }
  }

  Future<void> refreshTodos() async {
    await getTodos(isRefresh: true);
  }

  Future<void> addTodo(Todo todo, {Uint8List? signatureBytes}) async {
    try {
      if (todo.title.trim().isEmpty) {
        final currentState = state;
        emit(TodoError(message: "Title tidak boleh kosong"));
        if (currentState is TodoLoaded) {
          emit(currentState);
        } else {
          getTodos();
        }
        return;
      }

      emit(TodoLoading());
      try {
        await repository.addTodo(todo, signatureBytes: signatureBytes);
        final todos = await repository.getTodos();
        emit(TodoLoaded(todos: todos));
      } catch (e) {
        emit(TodoError(message: _friendlyError(e)));
      }
    } catch (e, stack) {
      print("CUBIT ERROR: $e");
      print("STACK: $stack");
      emit(TodoError(message: "Gagal menyimpan: ${e.toString()}"));
    }
  }

  Future<void> updateTodo(Todo todo, {Uint8List? signatureBytes}) async {
    emit(TodoLoading());
    try {
      await repository.updateTodo(todo, signatureBytes: signatureBytes);
      final todos = await repository.getTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: _friendlyError(e)));
    }
  }

  Future<void> deleteTodo(int id) async {
    emit(TodoLoading());
    try {
      await repository.deleteTodo(id);
      final todos = await repository.getTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: _friendlyError(e)));
    }
  }

  Future<void> exportTodos() async {
    try {
      if (state is TodoLoaded) {
        final todos = (state as TodoLoaded).todos;
        await exportPdf(todos);
      }
    } catch (e) {
      emit(TodoError(message: "Gagal Export PDF"));
    }
  }
}

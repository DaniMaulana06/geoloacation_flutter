import 'package:crud_app/features/todo/domain/entities/todo.dart';
import 'package:crud_app/features/todo/domain/repositories/todo_repository.dart';

class ExportPdf {
  final TodoRepository repository;

  ExportPdf(this.repository);

  Future<void> call(List<Todo> todos) async{
    await repository.exportToPdf(todos);
  }
}
import 'dart:typed_data';
import 'package:crud_app/features/todo/data/datasource/todo_remote_datasource.dart';
import 'package:crud_app/features/todo/data/services/pdf_services.dart';
import 'package:crud_app/features/todo/domain/entities/todo.dart';
import 'package:crud_app/features/todo/domain/repositories/todo_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDatasource datasource;
  final PdfService pdfServices;

  TodoRepositoryImpl(this.datasource, this.pdfServices);

  @override
  Future<List<Todo>> getTodos() {
    return datasource.getTodos();
  }

  @override
  Future<void> addTodo(Todo todo, {Uint8List? signatureBytes}) async {
    // return datasource.addTodo(todo.title, signatureBytes);
    try {
      print("DATA YANG AKAN DIKIRIM: title: ${todo.title}, coords: ${todo.longitude} ${todo.latitude}");
      final Map<String, dynamic> dataToInsert = {
        'title': todo.title,
        'created_at': todo.createdAt.toIso8601String(),
      };
      if (todo.latitude != null && todo.longitude != null) {
        dataToInsert['coordinates'] =
            'POINT(${todo.longitude} ${todo.latitude})';
      }

      if (signatureBytes != null) {
        final filename =
            'signature_${DateTime.now().millisecondsSinceEpoch}.png';
        await datasource.client.storage
            .from('signatures')
            .uploadBinary(
              filename,
              signatureBytes,
              fileOptions: FileOptions(contentType: 'image/png'),
            );
        final signatureUrl = datasource.client.storage
            .from('signatures')
            .getPublicUrl(filename);
        dataToInsert['signatures_url'] = signatureUrl;
      }

      await datasource.client.from('todos').insert(dataToInsert);
    } catch (e) {
      print("LOG REPO ERROR: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateTodo(Todo todo, {Uint8List? signatureBytes}) async {
    String? signatureUrl;
    if (signatureBytes != null) {
      final filename = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      await datasource.client.storage
          .from('signatures')
          .uploadBinary(
            filename,
            signatureBytes,
            fileOptions: FileOptions(contentType: 'image/png'),
          );
      signatureUrl = datasource.client.storage
          .from('signatures')
          .getPublicUrl(filename);
    } else {
      // Tidak ada tanda tangan baru → pertahankan URL lama
      signatureUrl = todo.signatureUrl;
    }
    return datasource.updateTodo(todo.id, todo.title, signatureUrl);
  }

  @override
  Future<void> deleteTodo(int id) {
    return datasource.deleteTodo(id);
  }

  @override
  Future<void> exportToPdf(List<Todo> todos) {
    // TODO: implement exportToPdf
    return pdfServices.generatePdf(todos);
  }
}

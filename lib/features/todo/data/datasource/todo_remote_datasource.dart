import 'dart:typed_data';

import 'package:crud_app/features/todo/data/models/todo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoRemoteDatasource {
  final SupabaseClient client;

  TodoRemoteDatasource(this.client);

  Future<List<TodoModel>> getTodos() async {
    final response = await client.from('todos').select().order('id', ascending: false);
    if (response.isNotEmpty) {
      print('=== DEBUG API RESPONSE FIRST ITEM: ${response.first} ===');
    }
    return (response as List).map((e) => TodoModel.fromJson(e)).toList();
  }

  Future<TodoModel> addTodo(String title, Uint8List? signatureBytes) async {
    String? signatureUrl;

    try {
      if (signatureBytes != null) {
        final String filename =
            'signature_${DateTime.now().millisecondsSinceEpoch}.png';

        await client.storage
            .from('signatures')
            .uploadBinary(
              filename,
              signatureBytes,
              fileOptions: const FileOptions(contentType: 'image/png'),
            );

        signatureUrl = client.storage.from('signatures').getPublicUrl(filename);
      }

      final response = await client
          .from('todos')
          .insert({'title': title, 'signatures_url': signatureUrl})
          .select()
          .single();
      return TodoModel.fromJson(response);

    } catch (e) {
      print('=== ERROR KETIKA ADD TODO: $e ===');
      throw Exception(e.toString());
    }
  }

  Future<void> updateTodo(int id, String title, String? signatureUrl) async {
    await client.from('todos').update({'title': title, 'signatures_url': signatureUrl}).eq('id', id);
  }

  Future<void> deleteTodo(int id) async {
    await client.from('todos').delete().eq('id', id);
  }
}

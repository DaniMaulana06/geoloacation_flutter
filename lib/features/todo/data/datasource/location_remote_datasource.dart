
import 'package:crud_app/features/todo/data/models/location_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> updateLocation(LocationModel model) async {
  final supabase = Supabase.instance.client;
  await supabase
      .from('locations')
      .update(model.toJson()) // Menggunakan toJson yang sudah ada format POINT-nya
      .eq('id', model.id);
}

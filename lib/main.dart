import 'package:crud_app/features/todo/data/datasource/todo_remote_datasource.dart';
import 'package:crud_app/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:crud_app/features/todo/data/services/pdf_services.dart';
import 'package:crud_app/features/todo/domain/usecases/export_pdf.dart';
import 'package:crud_app/features/todo/presentation/cubit/todo_cubit.dart';
import 'package:crud_app/features/todo/presentation/pages/todo_page.dart'
    show TodoPage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://aimewulxlzebndwyfxzl.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpbWV3dWx4bHplYm5kd3lmeHpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxNzI4MzgsImV4cCI6MjA4ODc0ODgzOH0.hxvuFAO_RfInq0nHL13Jau1h4-vzOZGt9gsxgrIMNE0',
  );

  final client = Supabase.instance.client;
  final datasource = TodoRemoteDatasource(client);
  final pdfServices = PdfService();
  final repository = TodoRepositoryImpl(datasource, pdfServices);
  final exportPdf = ExportPdf(repository);
  runApp(BlocProvider(
    create: (_) => TodoCubit(repository, exportPdf),
    child: MyApp(repository, exportPdf),
  ));
}

class MyApp extends StatelessWidget {
  final TodoRepositoryImpl repository;
  final ExportPdf exportPdf;

  MyApp(this.repository, this.exportPdf);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => TodoCubit(repository, exportPdf)..getTodos(),
        child: TodoPage(),
      ),
    );
  }
}

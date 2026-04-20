import 'package:crud_app/features/todo/presentation/cubit/todo_cubit.dart';
import 'package:crud_app/features/todo/presentation/cubit/todo_state.dart';
import 'package:crud_app/features/todo/presentation/pages/add_page.dart';
import 'package:crud_app/features/todo/presentation/pages/edit_page.dart';
import 'package:crud_app/features/todo/presentation/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Survei", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 41, 58, 114),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              final cubit = context.read<TodoCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BlocProvider.value(value: cubit, child: const AddPage()),
                ),
              );
            },
            backgroundColor: const Color.fromARGB(255, 41, 58, 114),
            heroTag: 'add_todo',
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10,),     
          FloatingActionButton(
            onPressed: () => context.read<TodoCubit>().exportTodos(),
            backgroundColor: const Color.fromARGB(255, 190, 4, 4),
            foregroundColor: Colors.white,
            heroTag: 'export_pdf',
            child: const Icon(Icons.picture_as_pdf),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16,),
          Expanded(
            child: BlocConsumer<TodoCubit, TodoState>(
              listener: (context, state) {
                if (state is TodoError) {
                  ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(
                      content: Text(state.message),
                      backgroundColor: Colors.red[100],
                      actions: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(
                              context,
                            ).hideCurrentMaterialBanner();
                          },
                          child: const Text('TUTUP'),
                        ),
                      ],
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TodoLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is TodoError) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<TodoCubit>().refreshTodos(),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tarik ke bawah untuk mencoba lagi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is TodoLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<TodoCubit>().refreshTodos(),
                    child: ListView.builder(
                      itemCount: state.todos.length,
                      itemBuilder: (context, index) {
                        final todo = state.todos[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          color: Colors.white,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(todo: todo),
                                ),
                              );
                            },
                            title: Text(todo.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (todo.signatureUrl != null &&
                                    todo.signatureUrl!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tanda Tangan:',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    color: Colors.grey[100],
                                    child: Image.network(
                                      todo.signatureUrl!,
                                      height: 60,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const SizedBox(
                                              height: 60,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text(
                                                'Gagal memuat gambar',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(todo.createdAt),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    final todoCubit = context.read<TodoCubit>();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Konfirmasi Hapus'),
                                          backgroundColor: Colors.white,
                                          shadowColor: Colors.grey,
                                          content: Text(
                                            'Apakah anda yakin ingin menghapus "${todo.title}" ?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                todoCubit.deleteTodo(todo.id);
                                              },
                                              child: Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.amber),
                                  onPressed: () {
                                    final cubit = context.read<TodoCubit>();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlocProvider.value(
                                              value: cubit,
                                              child: EditPage(todo: todo),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

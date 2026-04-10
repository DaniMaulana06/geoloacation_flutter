import 'package:crud_app/features/todo/domain/entities/todo.dart';
import 'package:crud_app/features/todo/presentation/cubit/todo_cubit.dart';
import 'package:crud_app/features/todo/presentation/cubit/todo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class EditPage extends StatefulWidget {
  final Todo todo;

  const EditPage({super.key, required this.todo});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController titleController;
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    titleController.dispose();
    signatureController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    Uint8List? signatureBytes;
    if (signatureController.isNotEmpty) {
      signatureBytes = await signatureController.toPngBytes();
    }

    final updateTodo = Todo(
      id: widget.todo.id,
      title: title,
      createdAt: widget.todo.createdAt,
      signatureUrl: widget.todo.signatureUrl,
    );

    context.read<TodoCubit>().updateTodo(
      updateTodo,
      signatureBytes: signatureBytes,
    );
    // Tidak ada Navigator.pop() di sini — diurus oleh BlocListener
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoCubit, TodoState>(
      listener: (context, state) {
        if (state is TodoLoaded) {
          Navigator.pop(context);
        } else if (state is TodoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Edit Todo", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 41, 58, 114),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Judul Tugas",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Tanggal Dibuat",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm').format(widget.todo.createdAt),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Tanda Tangan Lama",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.todo.signatureUrl != null &&
                      widget.todo.signatureUrl!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        widget.todo.signatureUrl!,
                        height: 150,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 80,
                              child: Center(
                                child: Text(
                                  'Gagal memuat gambar tanda tangan',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                      ),
                    )
                  else
                    const Text(
                      "Tidak ada tanda tangan terlampir",
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    "Tanda Tangan Baru (opsional)",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Signature(
                        controller: signatureController,
                        height: 200,
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => signatureController.clear(),
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text("Hapus Tanda Tangan"),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

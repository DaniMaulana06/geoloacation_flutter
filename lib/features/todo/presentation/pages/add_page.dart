import 'dart:typed_data';
import 'package:crud_app/features/todo/domain/entities/todo.dart';
import 'package:crud_app/features/todo/presentation/cubit/todo_cubit.dart';
import 'package:crud_app/features/todo/presentation/cubit/todo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signature/signature.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController titleController = TextEditingController();
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  bool _isGettingLocation = false;
  double? _latitude;
  double? _longitude;

  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // 1. Cek apakah GPS aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'GPS Anda nonaktif. Silakan aktifkan GPS terlebih dahulu.';
      }

      // 2. Cek Izin
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Minta izin ke user (Munculkan Pop-up)
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Silakan ubah di pengaturan HP.';
      }

      // 3. Ambil Posisi (Hanya jika diizinkan)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi berhasil diambil!')));
    } catch (e) {
      setState(() => _isGettingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    signatureController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      final title = titleController.text.trim();
      if (title.isEmpty) return;

      Uint8List? signatureBytes;
      if (signatureController.isNotEmpty) {
        signatureBytes = await signatureController.toPngBytes();
      }

      final todo = Todo(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        createdAt: DateTime.now(),
        latitude: _latitude,
        longitude: _longitude,
      );

      if (!mounted) return;

      context.read<TodoCubit>().addTodo(todo, signatureBytes: signatureBytes);
    } catch (e) {
      print("LOG UI ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoCubit, TodoState>(
      listener: (context, state) {
        if (state is TodoLoaded) {
          print("Berhasil simpan, menutup halaman...");
          Navigator.pop(context); // kembali hanya jika berhasil
        } else if (state is TodoError) {
          print('Error dari cubit: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Tambah Todo',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 41, 58, 114),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Judul Tugas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan judul tugas...',
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tanda Tangan',
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

                // ... setelah bagian Container Signature ...
                const SizedBox(height: 24),
                const Text(
                  'Lokasi (Koordinat)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Area untuk menampilkan koordinat & Tombol Ambil Lokasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _latitude != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _latitude != null && _longitude != null
                                      ? 'Lat: $_latitude'
                                      : 'Garis Lintang: -',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  _latitude != null && _longitude != null
                                      ? 'Long: $_longitude'
                                      : 'Garis Bujur: -',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (_isGettingLocation)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            OutlinedButton(
                              onPressed: _getLocation,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 41, 58, 114),
                                ),
                              ),
                              child: const Text('Ambil Lokasi'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32), // Jarak ke tombol simpan
                // ... Tombol Simpan ...
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => signatureController.clear(),
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Hapus Tanda Tangan'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 58, 114),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

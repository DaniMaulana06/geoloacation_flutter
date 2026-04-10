import 'package:crud_app/features/todo/domain/entities/todo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  final Todo todo;

  const DetailPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Tugas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 41, 58, 114),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            Text(
              todo.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Koordinat",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (todo.latitude != null && todo.longitude != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Latitude : ${todo.latitude}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Longitude: ${todo.longitude}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${todo.latitude},${todo.longitude}');
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tidak dapat membuka Google Maps'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Buka di Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      elevation: 0,
                    ),
                  ),
                ],
              )
            else
              const Text(
                "Tidak ada data koordinat",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
              DateFormat('dd MMMM yyyy, HH:mm').format(todo.createdAt),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              "Tanda Tangan",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (todo.signatureUrl != null && todo.signatureUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  todo.signatureUrl!,
                  height: 200,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 100,
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
          ],
        ),
      ),
    );
  }
}

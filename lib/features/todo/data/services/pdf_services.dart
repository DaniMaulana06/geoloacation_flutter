import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../../domain/entities/todo.dart';
import 'package:file_saver/file_saver.dart';

class PdfService {
  Future<void> generatePdf(List<Todo> todos) async {
    try {
      final pdf = pw.Document();

      pw.Font? ttf;
      try {
        final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
        ttf = pw.Font.ttf(font);
      } catch (e) {
        print("Font gagal load, pakai default");
      }

      final tableData = await Future.wait(
        todos.map((todo) async {
          pw.Widget imageWidget = pw.Text('-');

          //image pakai http
          if (todo.signatureUrl != null && todo.signatureUrl!.isNotEmpty) {
            try {
              final response = await http.get(Uri.parse(todo.signatureUrl!));

              if (response.statusCode == 200) {
                final image = pw.MemoryImage(response.bodyBytes);

                imageWidget = pw.Image(
                  image,
                  width: 100,
                  height: 100,
                  fit: pw.BoxFit.contain,
                );
              } else {
                imageWidget = pw.Text('Gagal load');
              }
            } catch (e) {
              print("ERROR IMAGE: $e");
              imageWidget = pw.Text('Error img');
            }
          }

          return [
            todo.title ?? '-',
            todo.createdAt.toString() ?? '-',
            imageWidget,
          ];
        }),
      );

      pdf.addPage(
        pw.MultiPage(
          theme: ttf != null ? pw.ThemeData.withFont(base: ttf) : null,
          build: (context) => [
            pw.Text('Laporan Todo', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),

            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                //  header table
                pw.TableRow(
                  children: [
                    _cellHeader('Title'),
                    _cellHeader('Tanggal'),
                    _cellHeader('Signature'),
                  ],
                ),

                // data table
                ...tableData.map(
                  (row) => pw.TableRow(
                    children: row.map((cell) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: cell is pw.Widget
                            ? cell
                            : pw.Text(cell.toString()),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      try {
        final path = await FileSaver.instance.saveFile(
          name: 'todo_${DateTime.now().millisecondsSinceEpoch}',
          bytes: pdfBytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
        
        await Printing.sharePdf(bytes: pdfBytes, filename: 'todo.pdf');

        await OpenFilex.open(path);

        print("File tersimpan di: $path");
      } catch (e) {
        print("ERROR SAVE FILE: $e");
      }
      print("PDF berhasil dibuat");
    } catch (e, stack) {
      print("ERROR PDF: $e");
      print("STACK: $stack");
    }
  }

  pw.Widget _cellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }
}

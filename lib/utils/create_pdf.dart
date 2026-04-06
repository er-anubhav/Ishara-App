import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CreatePdf {
  var pdf = pw.Document();
  Future<File> createPdfFile(List<XFile> images) async {
    List<Uint8List> pdfImages = [];
    for (var i = 0; i < images.length; i++) {
      pdfImages.add(await images[i].readAsBytes());
    }
    pdf.addPage(pw.MultiPage(
      margin: const pw.EdgeInsets.all(10),
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pdfImages
            .map(
              (e) => pw.Container(
                height: 800,
                padding: const pw.EdgeInsets.all(20),
                width: double.infinity,
                child: pw.Center(
                  child: pw.Image(
                      pw.MemoryImage(
                        e,
                      ),
                      fit: pw.BoxFit.cover),
                ),
              ),
            )
            .toList();
      },
    ));
    File pdffile = await savePdfFile();
    return pdffile;
  }

  Future<File> savePdfFile() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    String id = DateTime.now().toString();

    File file = File("$documentPath/$id.pdf");

    file.writeAsBytesSync(await pdf.save());

    return file;
  }
}

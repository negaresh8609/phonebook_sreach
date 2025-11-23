import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';

class SampleFilesPage extends StatelessWidget {
  const SampleFilesPage({super.key});

  Future<void> _loadAndSaveSample(
      BuildContext context, String assetPath, String outputFileName) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // این بخش که خطا می‌داد، با این مقادیر صحیح است
      await FileSaver.instance.saveFile(
        name: outputFileName,
        bytes: bytes,
        ext: 'xlsx',
        mimeType: MimeType.OPEN_XML_SPREADSHEET, // این مقدار صحیح است
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فایل "$outputFileName.xlsx" آماده ذخیره‌سازی است.')),
      );

    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در بارگذاری فایل نمونه: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دانلود فایل‌های نمونه'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.blue),
                title: const Text('دانلود نمونه اکسل پرسنل'),
                onTap: () {
                  _loadAndSaveSample(
                    context,
                    'assets/samples/phone.xlsx',
                    'sample_personnel',
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.school_outlined, color: Colors.green),
                title: const Text('دانلود نمونه اکسل مدارس'),
                onTap: () {
                  _loadAndSaveSample(
                    context,
                    'assets/samples/school.xlsx',
                    'sample_schools',
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.article_outlined, color: Colors.orange),
                title: const Text('دانلود نمونه اکسل ابلاغ‌ها'),
                onTap: () {
                  _loadAndSaveSample(
                    context,
                    'assets/samples/order.xlsx',
                    'sample_orders',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

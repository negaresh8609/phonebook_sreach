import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

class SampleFilesPage extends StatelessWidget {
  const SampleFilesPage({super.key});

  // متد اصلی برای ساخت و ذخیره فایل اکسل
  Future<void> _generateAndSaveSample(
      BuildContext context, String fileName, List<String> headers) async {
    try {
      // ۱. یک فایل اکسل جدید ایجاد کن
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // ۲. هدرها (عنوان ستون‌ها) را در ردیف اول قرار بده
      sheetObject.appendRow(headers.map((header) => TextCellValue(header)).toList());
      
      // تنظیمات ظاهری برای هدر
      for(int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: '#FFC0C0C0' // خاکستری روشن
        );
      }

      // ۳. فایل را به بایت تبدیل کن
      var fileBytes = excel.save();

      // ۴. با استفاده از file_saver فایل را به کاربر برای ذخیره ارائه بده
      if (fileBytes != null) {
        MimeType type = MimeType.MICROSOFT_EXCEL;
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: fileBytes,
          ext: 'xlsx',
          mimeType: type,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فایل "$fileName.xlsx" آماده ذخیره‌سازی است.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ایجاد فایل: $e')),
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
                title: const Text('نمونه اکسل شماره تماس‌ها', style: TextStyle(fontSize: 16)),
                subtitle: const Text('فایلی با ستون‌های مورد نیاز بخش پرسنل.'),
                onTap: () {
                  final headers = [
                    'کد پرسنلی', 'نام و نام خانوادگی', 'نام پدر', 
                    'کد ملی', 'شماره شناسنامه', 'موبایل'
                  ];
                  _generateAndSaveSample(context, 'sample_personnel', headers);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.school_outlined, color: Colors.green),
                title: const Text('نمونه اکسل مدارس', style: TextStyle(fontSize: 16)),
                subtitle: const Text('فایلی با ستون‌های مورد نیاز بخش مدارس.'),
                onTap: () {
                  final headers = [
                    'کد مدرسه', 'نام مدرسه', 'نوع اداره', 'محل مدرسه', 'جنسیت', 
                    'مقطع', 'شیفت', 'وضعیت استقلال', 'کد واحد اصلی', 
                    'نام واحد اصلی', 'نام شهر یا روستا', 'تعداد کلاس', 'تعداد دانش آموز'
                  ];
                   _generateAndSaveSample(context, 'sample_schools', headers);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.article_outlined, color: Colors.orange),
                title: const Text('نمونه اکسل ابلاغ‌های پرسنل', style: TextStyle(fontSize: 16)),
                subtitle: const Text('فایلی با ستون‌های مورد نیاز بخش ابلاغ‌ها.'),
                onTap: () {
                  final headers = [
                    'کد پرسنلي', 'نام', 'جنسيت', 'کد واحد سازماني', 'نام واحد سازماني', 
                    'نوع تدريس', 'مقطع', 'گروه تدريس', 'نوع واحد سازماني', 'ساعت', 
                    'از تاريخ', 'تا تاريخ', 'رشته تدريس', 'پست'
                  ];
                  _generateAndSaveSample(context, 'sample_orders', headers);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

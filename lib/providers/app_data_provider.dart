import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

// enum برای مدیریت view های مختلف برنامه
enum AppView { personnel, schools, orders }

class AppDataProvider with ChangeNotifier {
  //------------------- STATE MANAGEMENT -------------------//

  // View فعلی که در صفحه اصلی نمایش داده می‌شود
  AppView _currentView = AppView.personnel;
  AppView get currentView => _currentView;

  /// متد برای تغییر View فعلی و اطلاع‌رسانی به ویجت‌ها
  /// این همان متدی است که در main.dart فراخوانی می‌شود
  void setCurrentView(AppView newView) {
    if (_currentView != newView) {
      _currentView = newView;
      notifyListeners(); // به ویجت‌های شنونده خبر می‌دهد که وضعیت تغییر کرده است
    }
  }


  //------------------- DATA STORAGE -------------------//

  // لیست‌هایی برای نگهداری داده‌های خوانده شده از فایل‌های اکسل
  List<Map<String, dynamic>> _personnel = [];
  List<Map<String, dynamic>> _schools = [];
  List<Map<String, dynamic>> _orders = [];

  // Getters عمومی برای دسترسی ایمن به داده‌ها از خارج کلاس
  List<Map<String, dynamic>> get personnel => _personnel;
  List<Map<String, dynamic>> get schools => _schools;
  List<Map<String, dynamic>> get orders => _orders;


  //------------------- DATA LOADING LOGIC -------------------//

  /// متد عمومی برای انتخاب فایل اکسل و بازگرداندن محتوای آن
  Future<Excel?> _pickAndParseExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List bytes = result.files.single.bytes!;
        return Excel.decodeBytes(bytes);
      }
    } catch (e) {
      debugPrint("Error picking or parsing file: $e");
    }
    return null;
  }
  
  /// متد عمومی برای تبدیل شیت اکسل به لیست Map
  List<Map<String, dynamic>> _excelSheetToMap(Sheet sheet) {
    List<Map<String, dynamic>> dataList = [];
    if (sheet.rows.isEmpty) return dataList;

    // استخراج هدرها از ردیف اول
    List<String> headers = sheet.rows.first
        .map((cell) => cell?.value?.toString().trim() ?? '')
        .toList();

    // پردازش سایر ردیف‌ها
    for (int i = 1; i < sheet.rows.length; i++) {
      var row = sheet.rows[i];
      Map<String, dynamic> rowMap = {};
      for (int j = 0; j < headers.length; j++) {
        // اگر تعداد سلول‌های ردیف کمتر از هدر بود، از حلقه خارج شو
        if (j < row.length) {
          rowMap[headers[j]] = row[j]?.value;
        }
      }
      dataList.add(rowMap);
    }
    return dataList;
  }

  //--- Specific Loaders ---//

  Future<void> loadPersonnelData() async {
    final excelFile = await _pickAndParseExcelFile();
    if (excelFile != null && excelFile.tables.keys.isNotEmpty) {
      final sheetName = excelFile.tables.keys.first;
      final sheet = excelFile.tables[sheetName]!;
      _personnel = _excelSheetToMap(sheet);
      notifyListeners(); // اطلاع‌رسانی برای آپدیت UI
    }
  }

  Future<void> loadSchoolsData() async {
    final excelFile = await _pickAndParseExcelFile();
    if (excelFile != null && excelFile.tables.keys.isNotEmpty) {
      final sheetName = excelFile.tables.keys.first;
      final sheet = excelFile.tables[sheetName]!;
      _schools = _excelSheetToMap(sheet);
      notifyListeners();
    }
  }

  Future<void> loadOrdersData() async {
    final excelFile = await _pickAndParseExcelFile();
    if (excelFile != null && excelFile.tables.keys.isNotEmpty) {
      final sheetName = excelFile.tables.keys.first;
      final sheet = excelFile.tables[sheetName]!;
      _orders = _excelSheetToMap(sheet);
      notifyListeners();
    }
  }
}

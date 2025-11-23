import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/personnel.dart';
import '../models/school.dart';
import '../models/order.dart';

// برای مشخص کردن اینکه کدام صفحه فعال است
enum AppView { personnel, schools, orders }

class AppDataProvider with ChangeNotifier {
  // لیست‌های اصلی داده‌ها
  final List<Personnel> _personnelList = [];
  final List<School> _schoolList = [];
  final List<Order> _orderList = [];

  // وضعیت فعلی نمایش
  AppView _currentView = AppView.personnel;

  // Getters برای دسترسی به داده‌ها از بیرون
  List<Personnel> get personnelList => _personnelList;
  List<School> get schoolList => _schoolList;
  List<Order> get orderList => _orderList;
  AppView get currentView => _currentView;

  // متد برای تغییر صفحه فعال
  void setView(AppView view) {
    _currentView = view;
    notifyListeners(); // به ویجت‌ها اطلاع می‌دهد که صفحه باید بازسازی شود
  }

  // متد عمومی برای خواندن داده از اکسل
  Future<List<List<Data?>>?> _loadExcelData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      if (excel.tables.keys.isNotEmpty) {
        var sheet = excel.tables[excel.tables.keys.first]!;
        return sheet.rows;
      }
    }
    return null;
  }

  // متد برای بارگذاری اکسل شماره تماس‌ها
  Future<void> loadPersonnelData() async {
    final rows = await _loadExcelData();
    if (rows != null && rows.length > 1) {
      _personnelList.clear();
      for (int i = 1; i < rows.length; i++) { // از ردیف دوم شروع می‌کنیم
        final row = rows[i];
        if (row.any((cell) => cell?.value != null)) {
          _personnelList.add(Personnel(
            personnelCode: row[0]?.value?.toString() ?? '',
            fullName: row[1]?.value?.toString() ?? '',
            fatherName: row[2]?.value?.toString() ?? '',
            nationalCode: row[3]?.value?.toString() ?? '',
            birthCertId: row[4]?.value?.toString() ?? '',
            mobile: row[5]?.value?.toString() ?? '',
          ));
        }
      }
      notifyListeners();
    }
  }

  // متد برای بارگذاری اکسل مدارس
  Future<void> loadSchoolsData() async {
    final rows = await _loadExcelData();
    if (rows != null && rows.length > 1) {
      _schoolList.clear();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.any((cell) => cell?.value != null)) {
          _schoolList.add(School(
            schoolCode: row[0]?.value?.toString() ?? '',
            schoolName: row[1]?.value?.toString() ?? '',
            adminType: row[2]?.value?.toString() ?? '',
            location: row[3]?.value?.toString() ?? '',
            gender: row[4]?.value?.toString() ?? '',
            level: row[5]?.value?.toString() ?? '',
            shift: row[6]?.value?.toString() ?? '',
            independenceStatus: row[7]?.value?.toString() ?? '',
            mainUnitCode: row[8]?.value?.toString() ?? '',
            mainUnitName: row[9]?.value?.toString() ?? '',
            cityOrVillageName: row[10]?.value?.toString() ?? '',
            classCount: row[11]?.value?.toString() ?? '',
            studentCount: row[12]?.value?.toString() ?? '',
          ));
        }
      }
      notifyListeners();
    }
  }

  // متد برای بارگذاری اکسل ابلاغ‌ها
  Future<void> loadOrdersData() async {
    final rows = await _loadExcelData();
    if (rows != null && rows.length > 1) {
      _orderList.clear();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.any((cell) => cell?.value != null)) {
          _orderList.add(Order(
            personnelCode: row[0]?.value?.toString() ?? '',
            name: row[1]?.value?.toString() ?? '',
            gender: row[2]?.value?.toString() ?? '',
            orgUnitCode: row[3]?.value?.toString() ?? '',
            orgUnitName: row[4]?.value?.toString() ?? '',
            teachingType: row[5]?.value?.toString() ?? '',
            level: row[6]?.value?.toString() ?? '',
            teachingGroup: row[7]?.value?.toString() ?? '',
            orgUnitType: row[8]?.value?.toString() ?? '',
            hours: row[9]?.value?.toString() ?? '',
            fromDate: row[10]?.value?.toString() ?? '',
            toDate: row[11]?.value?.toString() ?? '',
            teachingField: row[12]?.value?.toString() ?? '',
            post: row[13]?.value?.toString() ?? '',
          ));
        }
      }
      notifyListeners();
    }
  }
}

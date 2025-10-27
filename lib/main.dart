// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'database_helper.dart';
import 'person_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Finder',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Person> _allPersons = [];
  List<Person> _filteredPersons = [];
  bool _isLoading = false;
  String _message = "برای شروع، داده‌ها را از طریق منو وارد کنید.";

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPersonsFromDb();
    _firstNameController.addListener(_filterList);
    _lastNameController.addListener(_filterList);
    _schoolController.addListener(_filterList);
    _positionController.addListener(_filterList);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonsFromDb() async {
    setState(() => _isLoading = true);
    _allPersons = await _dbHelper.getAllPersons();
    _filteredPersons = List.from(_allPersons);
     setState(() {
      _isLoading = false;
      if (_allPersons.isEmpty) {
        _message = "دیتابیس خالی است. لطفاً یک فایل اکسل وارد کنید.";
      } else {
        _message = "${_allPersons.length} رکورد در دیتابیس موجود است.";
      }
    });
  }

  void _filterList() {
    List<Person> results = List.from(_allPersons);
    String firstNameQuery = _firstNameController.text.trim().toLowerCase();
    String lastNameQuery = _lastNameController.text.trim().toLowerCase();
    String schoolQuery = _schoolController.text.trim().toLowerCase();
    String positionQuery = _positionController.text.trim().toLowerCase();

    if (firstNameQuery.isNotEmpty) {
      results = results.where((person) => person.firstName.toLowerCase().contains(firstNameQuery)).toList();
    }
    if (lastNameQuery.isNotEmpty) {
      results = results.where((person) => person.lastName.toLowerCase().contains(lastNameQuery)).toList();
    }
    if (schoolQuery.isNotEmpty) {
      results = results.where((person) => person.school.toLowerCase().contains(schoolQuery)).toList();
    }
    if (positionQuery.isNotEmpty) {
      results = results.where((person) => person.position.toLowerCase().contains(positionQuery)).toList();
    }

    setState(() {
      _filteredPersons = results;
    });
  }

  Future<void> _importExcel() async {
    setState(() {
      _isLoading = true;
      _message = "در حال انتخاب فایل اکسل...";
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        List<Person> peopleFromExcel = [];
        var sheet = excel.tables[excel.tables.keys.first];

        for (var i = 1; i < sheet!.rows.length; i++) {
          var row = sheet.rows[i];
          if (row.any((cell) => cell?.value != null)) { // Skip empty rows
            peopleFromExcel.add(Person(
              firstName: row[0]?.value?.toString() ?? '',
              lastName: row[1]?.value?.toString() ?? '',
              school: row[2]?.value?.toString() ?? '',
              position: row[3]?.value?.toString() ?? '',
              phoneNumber: row[4]?.value?.toString() ?? '',
            ));
          }
        }
        
        if (peopleFromExcel.isNotEmpty) {
          setState(() => _message = "در حال ذخیره داده‌ها در دیتابیس...");
          await _dbHelper.clearPersons();
          await _dbHelper.insertPersons(peopleFromExcel);
          _clearFilters();
          await _loadPersonsFromDb(); // Reload all data
          _showSnackBar("${peopleFromExcel.length} رکورد با موفقیت وارد شد.", Colors.green);
        } else {
          _showSnackBar("فایل اکسل خالی یا نامعتبر است.", Colors.orange);
        }
      } else {
        _showSnackBar("هیچ فایلی انتخاب نشد.", Colors.orange);
      }
    } catch (e) {
      _showSnackBar("خطا در پردازش فایل: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _clearFilters() {
    _firstNameController.clear();
    _lastNameController.clear();
    _schoolController.clear();
    _positionController.clear();
    // The listeners will automatically call _filterList
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar('امکان برقراری تماس وجود ندارد.', Colors.red);
    }
  }

  Future<void> _saveContact(Person person) async {
    // 1. Check for permission
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      if (await Permission.contacts.request().isGranted) {
         // Permission granted, proceed
      } else {
         _showSnackBar('برای ذخیره مخاطب، دسترسی لازم است.', Colors.red);
         return;
      }
    }
    
    if (status.isPermanentlyDenied) {
        openAppSettings();
        return;
    }

    // 2. Create and save contact
    try {
      final newContact = Contact(
        givenName: person.firstName,
        familyName: person.lastName,
        phones: [Item(label: 'mobile', value: person.phoneNumber)],
      );
      await ContactsService.addContact(newContact);
      _showSnackBar('مخاطب با موفقیت ذخیره شد.', Colors.green);
    } catch (e) {
      _showSnackBar('خطا در ذخیره مخاطب: $e', Colors.red);
    }
  }
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جستجوی مخاطبین'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') _importExcel();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.black87),
                    SizedBox(width: 8),
                    Text('وارد کردن از اکسل'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildFilterSection(),
            const SizedBox(height: 10),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: _filteredPersons.isEmpty && (_firstNameController.text.isNotEmpty || _lastNameController.text.isNotEmpty || _schoolController.text.isNotEmpty || _positionController.text.isNotEmpty)
                    ? const Center(child: Text("موردی یافت نشد."))
                    : ListView.builder(
                        itemCount: _filteredPersons.length,
                        itemBuilder: (context, index) {
                          final person = _filteredPersons[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${person.lastName}, ${person.firstName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('پست: ${person.position} | مدرسه: ${person.school}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.call, size: 20),
                                        label: const Text('Call'),
                                        onPressed: () => _makePhoneCall(person.phoneNumber),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        icon: const Icon(Icons.save, size: 20),
                                        label: const Text('Save'),
                                        onPressed: () => _saveContact(person),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('پاک کردن فیلترها'),
                onPressed: _clearFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'نام', border: OutlineInputBorder()))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'نام خانوادگی', border: OutlineInputBorder()))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: TextField(controller: _schoolController, decoration: const InputDecoration(labelText: 'مدرسه', border: OutlineInputBorder()))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _positionController, decoration: const InputDecoration(labelText: 'پست', border: OutlineInputBorder()))),
          ],
        ),
      ],
    );
  }
}

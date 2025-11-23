import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school.dart';
import '../providers/app_data_provider.dart';
import '../pages/school_details_page.dart';

class SchoolsView extends StatefulWidget {
  const SchoolsView({super.key});

  @override
  State<SchoolsView> createState() => _SchoolsViewState();
}

class _SchoolsViewState extends State<SchoolsView> {
  final _schoolCodeController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _levelController = TextEditingController();
  List<School> _filteredSchools = [];

  @override
  void initState() {
    super.initState();
    // در ابتدا کل لیست مدارس را نشان می‌دهیم (اگر موجود باشد)
    _filteredSchools = Provider.of<AppDataProvider>(context, listen: false).schoolList;
  }

  void _search() {
    final allSchools = Provider.of<AppDataProvider>(context, listen: false).schoolList;
    
    setState(() {
      _filteredSchools = allSchools.where((s) {
        final schoolCodeMatch = _schoolCodeController.text.isEmpty || s.schoolCode.contains(_schoolCodeController.text);
        final schoolNameMatch = _schoolNameController.text.isEmpty || s.schoolName.contains(_schoolNameController.text);
        final genderMatch = _genderController.text.isEmpty || s.gender.contains(_genderController.text);
        final levelMatch = _levelController.text.isEmpty || s.level.contains(_levelController.text);
        return schoolCodeMatch && schoolNameMatch && genderMatch && levelMatch;
      }).toList();
    });
  }

  void _clear() {
    _schoolCodeController.clear();
    _schoolNameController.clear();
    _genderController.clear();
    _levelController.clear();
    _search(); // بعد از پاک کردن، جستجو را مجدد اجرا می‌کنیم تا کل لیست نمایش داده شود
  }

  @override
  Widget build(BuildContext context) {
    // اطمینان از آپدیت بودن لیست هنگام تغییر داده اصلی
    _filteredSchools = context.watch<AppDataProvider>().schoolList.where((s) {
        final schoolCodeMatch = _schoolCodeController.text.isEmpty || s.schoolCode.contains(_schoolCodeController.text);
        final schoolNameMatch = _schoolNameController.text.isEmpty || s.schoolName.contains(_schoolNameController.text);
        final genderMatch = _genderController.text.isEmpty || s.gender.contains(_genderController.text);
        final levelMatch = _levelController.text.isEmpty || s.level.contains(_levelController.text);
        return schoolCodeMatch && schoolNameMatch && genderMatch && levelMatch;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _schoolCodeController, onChanged: (_) => _search(), decoration: const InputDecoration(labelText: 'کد مدرسه', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _schoolNameController, onChanged: (_) => _search(), decoration: const InputDecoration(labelText: 'نام مدرسه', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _genderController, onChanged: (_) => _search(), decoration: const InputDecoration(labelText: 'جنسیت', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _levelController, onChanged: (_) => _search(), decoration: const InputDecoration(labelText: 'مقطع', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _clear, child: const Text('پاک کردن')),
            const Divider(height: 30),
            Expanded(
              child: _filteredSchools.isEmpty
                  ? const Center(child: Text('هیچ نتیجه‌ای یافت نشد یا داده‌ای بارگذاری نشده است.'))
                  : ListView.builder(
                      itemCount: _filteredSchools.length,
                      itemBuilder: (context, index) {
                        final school = _filteredSchools[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(school.schoolName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('کد: ${school.schoolCode} | نوع اداره: ${school.adminType}'),
                                Text('جنسیت: ${school.gender} | مقطع: ${school.level}'),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SchoolDetailsPage(school: school),
                                        ),
                                      );
                                    },
                                    child: const Text('مشاهده جزئیات'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

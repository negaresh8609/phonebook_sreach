import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/personnel.dart';
import '../providers/app_data_provider.dart';

class PersonnelView extends StatefulWidget {
  const PersonnelView({super.key});

  @override
  State<PersonnelView> createState() => _PersonnelViewState();
}

class _PersonnelViewState extends State<PersonnelView> {
  final _personnelCodeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  List<Personnel> _filteredPersonnel = [];

  void _search() {
    final allPersonnel = Provider.of<AppDataProvider>(context, listen: false).personnelList;
    if (_personnelCodeController.text.isEmpty &&
        _fullNameController.text.isEmpty &&
        _mobileController.text.isEmpty) {
      setState(() {
        _filteredPersonnel = allPersonnel;
      });
      return;
    }

    setState(() {
      _filteredPersonnel = allPersonnel.where((p) {
        final personnelCodeMatch = _personnelCodeController.text.isEmpty ||
            p.personnelCode.contains(_personnelCodeController.text);
        final fullNameMatch = _fullNameController.text.isEmpty ||
            p.fullName.contains(_fullNameController.text);
        final mobileMatch = _mobileController.text.isEmpty ||
            p.mobile.contains(_mobileController.text);
        return personnelCodeMatch && fullNameMatch && mobileMatch;
      }).toList();
    });
  }

  void _clear() {
    _personnelCodeController.clear();
    _fullNameController.clear();
    _mobileController.clear();
    setState(() {
      _filteredPersonnel.clear();
    });
  }
  
  @override
  void didChangeDependencies() {
    // برای اینکه با هر بار تغییر داده‌ها، لیست نتایج هم آپدیت شود
    _filteredPersonnel = Provider.of<AppDataProvider>(context).personnelList;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _personnelCodeController, onChanged: (_) => _search(), decoration: const InputDecoration(labelText: 'کد پرسنلی', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _fullNameController, onChanged: (_) => _search(), decoration: const InputDecoration(labelText: 'نام و نام خانوادگی', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _mobileController, onChanged: (_) => _search(), decoration: const InputDecoration(labelText: 'شماره موبایل', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _clear, child: const Text('پاک کردن')),
            const Divider(height: 30),
            Expanded(
              child: _filteredPersonnel.isEmpty
                  ? const Center(child: Text('هیچ نتیجه‌ای یافت نشد یا داده‌ای بارگذاری نشده است.'))
                  : ListView.builder(
                      itemCount: _filteredPersonnel.length,
                      itemBuilder: (context, index) {
                        final person = _filteredPersonnel[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(person.fullName),
                            subtitle: Text('کد پرسنلی: ${person.personnelCode} - موبایل: ${person.mobile}'),
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

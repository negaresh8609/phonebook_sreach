import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';

class PersonnelView extends StatefulWidget {
  const PersonnelView({super.key});

  @override
  State<PersonnelView> createState() => _PersonnelViewState();
}

class _PersonnelViewState extends State<PersonnelView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // از context.watch برای گوش دادن به تغییرات در provider استفاده می‌کنیم
    final provider = context.watch<AppDataProvider>();
    final allPersonnel = provider.personnel;

    // فیلتر کردن لیست بر اساس جستجو در هر بار بیلد شدن
    final List<Map<String, dynamic>> filteredPersonnel;
    if (_searchQuery.isEmpty) {
      filteredPersonnel = allPersonnel;
    } else {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      filteredPersonnel = allPersonnel.where((person) {
        // جستجو بر اساس کلیدهای ستون (بسیار پایدارتر از ایندکس)
        final name = person['نام']?.toString().toLowerCase() ?? '';
        final familyName = person['نام خانوادگی']?.toString().toLowerCase() ?? '';
        final personnelCode = person['کد پرسنلی']?.toString() ?? '';

        return name.contains(lowerCaseQuery) ||
            familyName.contains(lowerCaseQuery) ||
            personnelCode.contains(lowerCaseQuery);
      }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'جستجو (نام، نام خانوادگی، کد پرسنلی)',
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (allPersonnel.isEmpty)
          const Expanded(
            child: Center(
              child: Text('لطفاً ابتدا فایل اکسل پرسنل را از منو وارد کنید.'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredPersonnel.length,
              itemBuilder: (context, index) {
                final person = filteredPersonnel[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(child: Text((index + 1).toString())),
                    title: Text('${person['نام'] ?? ''} ${person['نام خانوادگی'] ?? ''}'),
                    subtitle: Text('کد پرسنلی: ${person['کد پرسنلی'] ?? 'نامشخص'}'),
                    trailing: Text(person['شماره تماس']?.toString() ?? 'ندارد'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

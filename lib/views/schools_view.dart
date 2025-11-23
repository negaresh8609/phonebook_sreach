import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';

class SchoolsView extends StatefulWidget {
  const SchoolsView({super.key});

  @override
  State<SchoolsView> createState() => _SchoolsViewState();
}

class _SchoolsViewState extends State<SchoolsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final allSchools = provider.schools;

    final List<Map<String, dynamic>> filteredSchools;
    if (_searchQuery.isEmpty) {
      filteredSchools = allSchools;
    } else {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      filteredSchools = allSchools.where((school) {
        final schoolName = school['نام مدرسه']?.toString().toLowerCase() ?? '';
        final schoolCode = school['کد مدرسه']?.toString() ?? '';
        
        return schoolName.contains(lowerCaseQuery) ||
               schoolCode.contains(lowerCaseQuery);
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
              labelText: 'جستجو (نام مدرسه، کد مدرسه)',
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (allSchools.isEmpty)
          const Expanded(
            child: Center(
              child: Text('لطفاً ابتدا فایل اکسل مدارس را از منو وارد کنید.'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredSchools.length,
              itemBuilder: (context, index) {
                final school = filteredSchools[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: Text(school['نام مدرسه']?.toString() ?? 'بدون نام'),
                    subtitle: Text('کد مدرسه: ${school['کد مدرسه'] ?? 'نامشخص'}'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

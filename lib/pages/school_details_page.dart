import 'package:flutter/material.dart';
import '../models/school.dart';

class SchoolDetailsPage extends StatelessWidget {
  final School school;

  const SchoolDetailsPage({super.key, required this.school});

  // یک ویجت کمکی برای نمایش هر ردیف از اطلاعات
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(school.schoolName),
          backgroundColor: Colors.blueGrey,
        ),
        body: ListView(
          children: [
            _buildDetailRow('کد مدرسه:', school.schoolCode),
            _buildDetailRow('نام مدرسه:', school.schoolName),
            const Divider(),
            _buildDetailRow('نوع اداره:', school.adminType),
            _buildDetailRow('محل مدرسه:', school.location),
            _buildDetailRow('جنسیت:', school.gender),
            _buildDetailRow('مقطع:', school.level),
            _buildDetailRow('شیفت:', school.shift),
            _buildDetailRow('وضعیت استقلال:', school.independenceStatus),
            const Divider(),
            _buildDetailRow('کد واحد اصلی:', school.mainUnitCode),
            _buildDetailRow('نام واحد اصلی:', school.mainUnitName),
            _buildDetailRow('نام شهر یا روستا:', school.cityOrVillageName),
            const Divider(),
            _buildDetailRow('تعداد کلاس:', school.classCount),
            _buildDetailRow('تعداد دانش آموز:', school.studentCount),
          ],
        ),
      ),
    );
  }
}

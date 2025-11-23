import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_data_provider.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final allOrders = provider.orders;

    final List<Map<String, dynamic>> filteredOrders;
    if (_searchQuery.isEmpty) {
      filteredOrders = allOrders;
    } else {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      filteredOrders = allOrders.where((order) {
        final fullName = order['نام و نام خانوادگی']?.toString().toLowerCase() ?? '';
        final personnelCode = order['کد پرسنلی']?.toString() ?? '';

        return fullName.contains(lowerCaseQuery) ||
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
              labelText: 'جستجو (نام، کد پرسنلی)',
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (allOrders.isEmpty)
          const Expanded(
            child: Center(
              child: Text('لطفاً ابتدا فایل اکسل ابلاغ‌ها را از منو وارد کنید.'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                // فرض می‌کنیم ستون‌های دیگری هم برای نمایش وجود دارند
                // اینجا فقط موارد اصلی را نمایش می‌دهیم
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(order['نام و نام خانوادگی']?.toString() ?? 'بدون نام'),
                    subtitle: Text('کد پرسنلی: ${order['کد پرسنلی'] ?? 'نامشخص'}'),
                    // می‌توانید اطلاعات بیشتری در اینجا نمایش دهید
                    // مثلا: trailing: Text(order['نام پست']?.toString() ?? ''),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

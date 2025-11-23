import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/app_data_provider.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  // Controllers for personnel search
  final _personnelCodeController = TextEditingController();
  final _personnelNameController = TextEditingController();
  
  // Controllers for school search
  final _schoolCodeController = TextEditingController();
  final _schoolNameController = TextEditingController();

  List<Order> _filteredOrders = [];
  bool _hasSearched = false;

  void _search() {
    final allOrders = Provider.of<AppDataProvider>(context, listen: false).orderList;
    List<Order> results = allOrders;

    setState(() {
       _hasSearched = true;
       
      // فیلتر بر اساس پرسنل
      if (_personnelCodeController.text.isNotEmpty || _personnelNameController.text.isNotEmpty) {
          results = results.where((order) {
              final codeMatch = _personnelCodeController.text.isEmpty || order.personnelCode.contains(_personnelCodeController.text);
              final nameMatch = _personnelNameController.text.isEmpty || order.name.contains(_personnelNameController.text);
              return codeMatch && nameMatch;
          }).toList();
      }

      // فیلتر بر اساس مدرسه
      if (_schoolCodeController.text.isNotEmpty || _schoolNameController.text.isNotEmpty) {
          results = results.where((order) {
              final codeMatch = _schoolCodeController.text.isEmpty || order.orgUnitCode.contains(_schoolCodeController.text);
              final nameMatch = _schoolNameController.text.isEmpty || order.orgUnitName.contains(_schoolNameController.text);
              return codeMatch && nameMatch;
          }).toList();
      }

      _filteredOrders = results;
    });
  }

  void _clear() {
    _personnelCodeController.clear();
    _personnelNameController.clear();
    _schoolCodeController.clear();
    _schoolNameController.clear();
    setState(() {
      _filteredOrders.clear();
      _hasSearched = false; // بازگشت به حالت اولیه
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بخش جستجوی پرسنل
            const Text("جستجو بر اساس پرسنل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(controller: _personnelCodeController, decoration: const InputDecoration(labelText: 'کد پرسنلی', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _personnelNameController, decoration: const InputDecoration(labelText: 'نام و نام خانوادگی', border: OutlineInputBorder())),
            
            const SizedBox(height: 20),
            
            // بخش جستجوی مدرسه
            const Text("جستجو بر اساس مدرسه", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(controller: _schoolCodeController, decoration: const InputDecoration(labelText: 'کد واحد سازمانی (مدرسه)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _schoolNameController, decoration: const InputDecoration(labelText: 'نام واحد سازمانی (مدرسه)', border: OutlineInputBorder())),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _search, child: const Text('جستجو')),
                ElevatedButton(onPressed: _clear, style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]), child: const Text('پاک کردن همه')),
              ],
            ),
            const Divider(height: 30),

            Expanded(
              child: !_hasSearched
                  ? const Center(child: Text('برای مشاهده نتایج، فیلدها را پر کرده و دکمه جستجو را بزنید.'))
                  : _filteredOrders.isEmpty 
                      ? const Center(child: Text('هیچ نتیجه‌ای برای این جستجو یافت نشد.'))
                      : ListView.builder(
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text('پرسنل: ${order.name} (${order.personnelCode})'),
                                subtitle: Text('مدرسه: ${order.orgUnitName} | پست: ${order.post} | ساعت: ${order.hours}'),
                                isThreeLine: true,
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

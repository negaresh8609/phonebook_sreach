import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_data_provider.dart';
import 'views/personnel_view.dart';
import 'views/schools_view.dart';
import 'views/orders_view.dart';
import 'pages/sample_files_page.dart'; // <--- فایل جدید را import کنید

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppDataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'داشبورد مدیریتی',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Vazirmatn',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  // متد برای نمایش دیالوگ "درباره برنامه"
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AboutDialog(
            applicationName: 'داشبورد مدیریتی',
            applicationVersion: 'نسخه 1.1.0',
            applicationIcon: const Icon(Icons.dashboard_customize_rounded),
            children: const <Widget>[
              SizedBox(height: 20),
              Text('سازنده: ابراهیم نگارش', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('کارشناس فناوری آموزش و پرورش آبادان'),
              SizedBox(height: 8),
              Text('ایمیل: negaresh8609@gmail.com'),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppDataProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('داشبورد مدیریتی'),
          actions: [
            PopupMenuButton<int>(
              onSelected: (value) async {
                final provider = Provider.of<AppDataProvider>(context, listen: false);
                switch (value) {
                  case 1:
                    await provider.loadPersonnelData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فایل اکسل شماره تماس‌ها با موفقیت بارگذاری شد.')),
                    );
                    break;
                  case 2:
                    await provider.loadSchoolsData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فایل اکسل مدارس با موفقیت بارگذاری شد.')),
                    );
                    break;
                  case 3:
                    await provider.loadOrdersData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فایل اکسل ابلاغ‌ها با موفقیت بارگذاری شد.')),
                    );
                    break;
                  case 4: // <--- گزینه دانلود نمونه
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SampleFilesPage()),
                    );
                    break;
                  case 5: // <--- گزینه درباره برنامه
                    _showAboutDialog(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Text('ورود اکسل شماره تماس‌ها'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('ورود اکسل مدارس'),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text('ورود اکسل ردیف‌های ابلاغ'),
                ),
                const PopupMenuDivider(), // <--- جداکننده برای زیبایی
                const PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      Icon(Icons.download_for_offline_outlined, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('دانلود فایل نمونه'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 5,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('درباره برنامه'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavButton(context, 'پرسنل', AppView.personnel),
                  _buildNavButton(context, 'مدارس', AppView.schools),
                  _buildNavButton(context, 'ابلاغ‌ها', AppView.orders),
                ],
              ),
            ),
            Expanded(
              child: _buildCurrentView(appData.currentView),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, AppView view) {
    final provider = Provider.of<AppDataProvider>(context);
    final bool isSelected = provider.currentView == view;

    return ElevatedButton(
      onPressed: () => provider.setView(view),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.indigo : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(title),
    );
  }

  Widget _buildCurrentView(AppView currentView) {
    switch (currentView) {
      case AppView.personnel:
        return const PersonnelView();
      case AppView.schools:
        return const SchoolsView();
      case AppView.orders:
        return const OrdersView();
      default:
        return const Center(child: Text('صفحه‌ای انتخاب نشده است.'));
    }
  }
}

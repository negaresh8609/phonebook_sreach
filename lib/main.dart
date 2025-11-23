import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_data_provider.dart';
import 'views/personnel_view.dart';
import 'views/schools_view.dart';
import 'views/orders_view.dart';
import 'pages/sample_files_page.dart';

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
        useMaterial3: true, // استفاده از طراحی متریال ۳ برای ظاهر مدرن‌تر
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// تبدیل به StatefulWidget برای مدیریت صحیح context در عملیات async
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  // متد برای نمایش دیالوگ "درباره برنامه"
  void _showAboutDialog() {
    showDialog(
      context: context, // استفاده از context متعلق به State
      builder: (BuildContext context) {
        return const Directionality(
          textDirection: TextDirection.rtl,
          child: AboutDialog(
            applicationName: 'داشبورد مدیریتی',
            applicationVersion: 'نسخه 1.1.0',
            applicationIcon: Icon(Icons.dashboard_customize_rounded),
            children: <Widget>[
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

  // متد برای اجرای اکشن‌های منو و نمایش SnackBar به صورت امن
  Future<void> _handleMenuSelection(int value) async {
    // استفاده از listen: false چون فقط قصد فراخوانی متد را داریم
    final provider = Provider.of<AppDataProvider>(context, listen: false);

    switch (value) {
      case 1:
        await provider.loadPersonnelData();
        // بررسی mounted قبل از استفاده از context
        if (!mounted) return; 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فایل اکسل شماره تماس‌ها با موفقیت بارگذاری شد.')),
        );
        break;
      case 2:
        await provider.loadSchoolsData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فایل اکسل مدارس با موفقیت بارگذاری شد.')),
        );
        break;
      case 3:
        await provider.loadOrdersData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فایل اکسل ابلاغ‌ها با موفقیت بارگذاری شد.')),
        );
        break;
      case 4: // دانلود نمونه
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SampleFilesPage()),
        );
        break;
      case 5: // درباره برنامه
        _showAboutDialog();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('داشبورد مدیریتی'),
          actions: [
            PopupMenuButton<int>(
              onSelected: _handleMenuSelection, // فراخوانی متد امن
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
                const PopupMenuDivider(),
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
              // استفاده از Consumer برای بازسازی فقط این بخش در صورت تغییر view
              child: Consumer<AppDataProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavButton(provider, 'پرسنل', AppView.personnel),
                      _buildNavButton(provider, 'مدارس', AppView.schools),
                      _buildNavButton(provider, 'ابلاغ‌ها', AppView.orders),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              // استفاده از context.watch برای خواندن و گوش دادن به تغییرات provider
              child: _buildCurrentView(context.watch<AppDataProvider>().currentView),
            ),
          ],
        ),
      ),
    );
  }

  // متد کمکی برای ساخت دکمه‌های ناوبری
  Widget _buildNavButton(AppDataProvider provider, String title, AppView view) {
    final bool isSelected = provider.currentView == view;

    return ElevatedButton(
      // در provider شما این متد setView نام دارد.
      onPressed: () => provider.setCurrentView(view), 
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.indigo : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isSelected ? 4 : 1,
      ),
      child: Text(title),
    );
  }

  // متد کمکی برای نمایش view فعلی
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

import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:trasheepartner/screens/demo_razerpay_paymnat.dart';
import 'package:trasheepartner/screens/shopkeeper/shop_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:trasheepartner/utils/dependency_injection.dart';
// void main() {
//   runApp( const MyApp());
// }

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Edge-to-Edge for Android 15+
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection().init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
     // home:  DemoRazorpayPayment(),
      home:  ShopSplashScreen(),
    );
  }
}

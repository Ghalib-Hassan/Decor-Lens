import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Provider/home_screen_provider.dart';
import 'package:decor_lens/Provider/product_screen_provider.dart';
import 'package:decor_lens/Services/onboarding_service.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = AppConstants.stripePublishableKey;
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkModeService()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkModeService()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Decor Lens',
        theme: darkModeService.isDarkMode
            ? ThemeData.dark().copyWith(
                scaffoldBackgroundColor: black,
              )
            : ThemeData.light(),
        home: const OnboardingService(),
      ),
    );
  }
}

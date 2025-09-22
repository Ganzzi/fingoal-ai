import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart'; // Disabled for now
// import 'package:firebase_messaging/firebase_messaging.dart'; // Disabled for now
import 'screens/auth_wrapper.dart';
import 'providers/language_provider.dart';
import 'providers/category_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/notification_provider.dart';
import 'services/router_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Handle background messages - DISABLED FOR NOW
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Initialize Firebase if not already initialized
//   await Firebase.initializeApp();

//   print('Handling background message: ${message.messageId}');
//   // Handle background message processing here
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - DISABLED FOR NOW
  // await Firebase.initializeApp();

  // Set background message handler - DISABLED FOR NOW
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize language provider
  final languageProvider = LanguageProvider();
  await languageProvider.initialize();

  runApp(MyApp(languageProvider: languageProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.languageProvider});

  final LanguageProvider languageProvider;

  // Global navigator key for deep linking
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Initialize router service
    RouterService().setNavigatorKey(navigatorKey);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            languageProvider: context.read<LanguageProvider>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'FinGoal AI',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,

            // Localization configuration
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('vi'), // Vietnamese
            ],
            locale: languageProvider.currentLocale,

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6750A4), // Material 3 purple
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              // Additional Material 3 theming
              appBarTheme: const AppBarTheme(
                centerTitle: true,
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

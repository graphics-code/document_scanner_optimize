import 'dart:ui';
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:doc_scanner/image_edit/provider/image_edit_provider.dart';
import 'package:doc_scanner/splash_screen/splash_screen.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:doc_scanner/utils/firebase_messageing.dart';
import 'package:doc_scanner/utils/helper.dart';
import 'package:doc_scanner/utils/local_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'core/local_storage.dart';
import 'camera_screen/provider/camera_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'localaization/language_constant.dart';
import 'firebase_options.dart';

bool bannerReady = false;
bool interstitialReady = false;
InterstitialAd? myInterstitial;
ValueNotifier<bool> interstitialReadyNotifier = ValueNotifier(false);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Future.delayed(const Duration(seconds: 5), () async {


    final localNotificationsService = LocalNotificationsService.instance();
    await localNotificationsService.init();

    final firebaseMessagingService = FirebaseMessagingService.instance();
    await firebaseMessagingService.init(
      localNotificationsService: localNotificationsService,
    );
  });
  MobileAds.instance.initialize();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await LocalStorage().init();
  await AppHelper().createDirectories();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => HomePageProvider()),
        ChangeNotifierProvider(create: (_) => ImageEditProvider()),
      ],
      child: Builder(builder: (context) {
        bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
        double textScaleFactor = isTablet ? 1.3 : 1.0;
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Document Scanner - PDF Scanner',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: _locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    foregroundColor: AppColor.primaryColor),
              ),
            ),
            home: const SplashScreen(),
          ),
        );
      }),
    );
  }
}

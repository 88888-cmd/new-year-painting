import 'package:app/i18n/index.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:app/services/storage.dart';
import 'package:app/store/config.dart';
import 'package:app/store/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Get.putAsync<StorageService>(() => StorageService().init());
  await Get.putAsync<ConfigStore>(() => ConfigStore().init());
  Get.put<PageEventService>(PageEventService());
  Get.put<UserStore>(UserStore());
  Get.put<HttpService>(HttpService());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Project',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFFf3e8d9),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFf3e8d9),
          iconTheme: IconThemeData(color: Color(0xFF5D4037), size: 25),
          titleTextStyle: TextStyle(
            fontSize: 18,
            color: Color(0xFF5D4037),
            // fontWeight: FontWeight.w700,
          ),
          // backgroundColor: Color(0xFF5D4037),
          // iconTheme: IconThemeData(color: Colors.white, size: 25),
          // titleTextStyle: TextStyle(
          //   fontSize: 18,
          //   color: Colors.white,
          //   // fontWeight: FontWeight.w700,
          // ),
        ),
        // datePickerTheme: DatePickerThemeData(
        //   rangePickerHeaderBackgroundColor: Color(0xFF1A56D0),
        //   rangePickerHeaderForegroundColor: Colors.white,
        //   headerBackgroundColor: Color(0xFF1A56D0),
        //   headerForegroundColor: Colors.white,
        //   rangePickerBackgroundColor: Colors.white,
        //   rangePickerElevation: 0,
        // ),
        tabBarTheme: TabBarThemeData(
          labelColor: const Color(0xFF654941),
          indicatorColor: const Color(0xFF654941),
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 14),
        ),
        popupMenuTheme: PopupMenuThemeData(
          textStyle: TextStyle(color: const Color(0xFF654941)),
        ),
      ),
      // initialRoute: Routes.main,
      initialRoute: UserStore.to.isLogin ? Routes.main : Routes.login,
      getPages: Routes.pages,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: Translation.supported,
      fallbackLocale: Translation.fallback,
      locale: ConfigStore.to.locale,
      translations: Translation(),
      builder: EasyLoading.init(
        builder: (context, child) {
          EasyLoading.instance.maskType = EasyLoadingMaskType.clear;
          return ScrollConfiguration(
            behavior: NoShadowScrollBehavior(),
            child: child ?? const Material(),
          );
        },
      ),
    );
  }
}

// Hide shadow
class NoShadowScrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return child;
      case TargetPlatform.android:
        return GlowingOverscrollIndicator(
          showLeading: false,
          showTrailing: false,
          axisDirection: axisDirection,
          color: Theme.of(context).colorScheme.primary,
          child: child,
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return GlowingOverscrollIndicator(
          showLeading: false,
          showTrailing: false,
          axisDirection: axisDirection,
          color: Theme.of(context).colorScheme.primary,
          child: child,
        );
    }
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

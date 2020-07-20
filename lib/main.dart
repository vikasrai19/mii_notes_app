import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/helper/authenticate.dart';
import 'package:notes_app/helper/dark_theme_shared_preference.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/onboard_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'helper/dark_theme_values.dart';
import 'pages/homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  Admob.initialize(getAppId());

  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

String getAppId() {
  return "ca-app-pub-1942646706163703~3847821147";
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();
  bool isViewed;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
    getCurrentAppTheme();
    getOnBoardState();
  }

  getOnBoardState() {
    HelperFunction.getOnBoardPageViewInSharedPreference().then((value) {
      setState(() {
        isViewed = value;
        print(value);
      });
    });
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  getLoggedInState() async {
    HelperFunction.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        isLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            title: 'Notes App',
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
//           darkTheme: ThemeData.dark(),
            home: isViewed == null || isViewed == false
                ? OnBoardScreen()
                : isLoggedIn != null
                    ? isLoggedIn ? HomePage() : Authenticate()
                    : Authenticate(),
//             home: isLoggedIn != null
//                ? isLoggedIn ? HomePage() : Authenticate()
//                : Authenticate(),
          );
        },
      ),
    );
  }
}

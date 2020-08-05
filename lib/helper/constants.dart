import 'package:notes_app/helper/helper_functions.dart';
import 'package:flutter/widgets.dart';

class Constants {
  static String myName = "";
}

class PopUpConstants {
  static const String specialNotes = "Notes From Image";
  static const String normalNotes = "Normal Notes";
  static const String reminder = "Reminder Notes";

  static const List<String> choices = <String>[
    normalNotes,
    specialNotes,
//    reminder
  ];
}

class AssistantLanguages {
  static const String englishIndia = "English India";
  static const String hindiInda = "Hindi";
  static const String englishUS = "English US";
  static const String kannadaIndia = "Kannada";
  static const String gujarathiIndia = "Gujarathi";

  static const List<String> voices = <String>[
    englishIndia,
    hindiInda,
    englishUS,
    kannadaIndia,
    gujarathiIndia,
  ];
}

class SizeConstants {
  bool showAds;
  SizeConstants({this.showAds});
  static double bottomPadding;
  void init(BuildContext context) {
    // HelperFunction.getAdsPrevInSharedPreference().then((value) {
    //   showAds = value;
    // });
    print("The final showAds value is");
    print(showAds);
    bottomPadding = showAds ? 60.0 : 20.0;
  }
}

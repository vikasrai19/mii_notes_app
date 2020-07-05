class Constants {

  static String myName ="";
}

class popUpConstants {
  static const String specialNotes = "Notes From Image";
  static const String normalNotes = "Normal Notes";
  static const String reminder = "Reminder Notes";

  static const List<String> choices = <String> [
    normalNotes,
    specialNotes,
//    reminder
  ];
}

class assistantLanguages {
  static const String englishIndia = "English India";
  static const String hindiInda = "Hindi";
  static const String englishUS = "English US";
  static const String kannadaIndia = "Kannada";
  static const String gujarathiIndia = "Gujarathi";

  static const List<String> voices = <String> [
    englishIndia,
    hindiInda,
    englishUS,
    kannadaIndia,
    gujarathiIndia,
  ];
}
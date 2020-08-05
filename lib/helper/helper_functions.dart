import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserEmailKey = 'USEREMAILKEY';
  static String sharedPreferenceUserUidKey = "USERUIDKEY";
  static String sharedPreferenceNameKey = "NAMEKEY";
  static String sharedPreferenceImageKey = "PROFILEIMAGEKEY";
  static String assistantLangInSharedPreferences = "ASSISTANTLANGKEY";
  static String assistantPitchInSharedPreferences = "ASSISTANRPITCHKEY";
  static String assistantVolumeInSharedPreferences = "ASSISTANTVOLUMEKEY";
  static String darkThemeModeInSharedPreference = "DARKTHEMEMODE";
  static String onBoardPageViewedInSharedPreference = "ONBOARDPAGEVIEW";
  static String isEmailPresent = "EMAILCHECKKEY";
  static String isEmailCorrect = "EMAILCORRECTKEY";
  static String isPasswordCorrect = "PASSWORDCORRECTKEY";
  static String isUserValidAttempt = "VALIDATTEMPTKEY";
  static String notesCountInSharedPreference = "NOTESCOUNTKEY";
  static String specialNotesCountInSharedPreference = "SPECIALNOTESCOUNTKEY";
  static String adsPreveligeInSharedPreference = "ADSPREVKEY";

  //save data in sharedpreference

  static Future<bool> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserUidInSharedPreferences(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(sharedPreferenceUserUidKey, uid);
  }

  static Future<bool> saveUserAdsPrevInSharedPreference(bool isAdShown) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(adsPreveligeInSharedPreference, isAdShown);
  }

  static Future<bool> saveNotesCountInSharedPreference(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(notesCountInSharedPreference, count);
  }

  static Future<bool> saveSpecialNotesCountInSharedPreference(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(specialNotesCountInSharedPreference, count);
  }

  static Future<bool> saveIsValidAttemptState(bool isValidAttempt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isUserValidAttempt, isValidAttempt);
  }

  static Future<bool> saveUserEmailCorrectState(bool isUserEmailCorrect) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isEmailCorrect, isUserEmailCorrect);
  }

  static Future<bool> saveUserPasswordCorrectState(
      bool isUserPasswordCorrect) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isPasswordCorrect, isUserPasswordCorrect);
  }

  static Future<bool> isEmailAlreadyInUse(bool isPresent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isEmailPresent, isPresent);
  }

  static Future<bool> saveOnBoardpageViewInSharePreference(
      bool isViewed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(onBoardPageViewedInSharedPreference, isViewed);
  }

  static Future<bool> saveAssistantVolumeInSharedPreference(
      double volume) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(assistantVolumeInSharedPreferences, volume);
  }

  static Future<bool> saveAssistantPicthInSharedPreference(double pitch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(assistantPitchInSharedPreferences, pitch);
  }

  static Future<bool> saveAssistantLangInSharedPreferences(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(assistantLangInSharedPreferences, lang);
  }

  static Future<bool> saveUserProfileImageInSharedPreference(
      String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceImageKey, imageUrl);
  }

  static Future<bool> saveNameInSharedPreference(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceNameKey, name);
  }

  static Future<bool> saveUserEmailInSharedPreference(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserEmailKey, email);
  }

  // getting data from SharedPreferences
  static Future<bool> getUserLoggedInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String> getUserUidFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserUidKey);
  }

  static Future<bool> getAdsPrevInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getBool(adsPreveligeInSharedPreference);
  }

  static Future<int> getNotesCountFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(notesCountInSharedPreference);
  }

  static Future<int> getSpecialNotesLengthFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(specialNotesCountInSharedPreference);
  }

  static Future<bool> getUserAttemptState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isUserValidAttempt);
  }

  static Future<bool> getUserEmailCorrectState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isEmailCorrect);
  }

  static Future<bool> getUserPasswordCorrectState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isPasswordCorrect);
  }

  static Future<bool> getIsEmailAlreadyInUse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.get(isEmailPresent);
  }

  static Future<bool> getOnBoardPageViewInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onBoardPageViewedInSharedPreference);
  }

  static Future<double> getAssistantVolumeInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(assistantVolumeInSharedPreferences);
  }

  static Future<double> getAssistantPitchInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(assistantPitchInSharedPreferences);
  }

  static Future<String> getAssistantLangInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(assistantLangInSharedPreferences);
  }

  static Future<String> getUserProfileImageInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceImageKey);
  }

  static Future<String> getUserNameFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceNameKey);
  }

  static Future<String> getUserEmailFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserEmailKey);
  }
}

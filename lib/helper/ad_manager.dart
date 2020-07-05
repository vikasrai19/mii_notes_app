import 'dart:io';

class AdManager{

  static String get appId {
    if(Platform.isAndroid){
      return "ca-app-pub-1942646706163703~3847821147";
    }else{
      throw new UnsupportedError("unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if(Platform.isAndroid){
      return "ca-app-pub-1942646706163703/7595494463";
    }else{
      throw new UnsupportedError("unsupported platform");
    }
  }
}
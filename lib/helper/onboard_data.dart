class OnBoardModel{

  String imagePath;
  String title;
  String desc;

  OnBoardModel({this.imagePath,this.title,this.desc});

  void setImagePath(String getImagePath){
    imagePath = getImagePath;
  }

  void setTitle(String getTitle){
    title = getTitle;
  }

  void setDesc(String getDesc){
    desc = getDesc;
  }

  String getimageAssetPath(){
    return imagePath;
  }

  String getTitle(){
    return title;
  }

  String getDesc(){
    return desc;
  }
}

List<OnBoardModel> getSlides(){
  List<OnBoardModel> slides = new List<OnBoardModel>();
  OnBoardModel onBoardModel = new OnBoardModel();

  onBoardModel.setImagePath('assets/onboardscreen/access_account.png');
  onBoardModel.setTitle('Global Account Acces');
  onBoardModel.setDesc('Access your account any time from any device at any place..');
  slides.add(onBoardModel);

  onBoardModel = new OnBoardModel();

  onBoardModel.setImagePath('assets/onboardscreen/add_tasks.png');
  onBoardModel.setTitle('Add tasks easily');
  onBoardModel.setDesc('Add tasks and reminders easily and get notified');
  slides.add(onBoardModel);

  onBoardModel = new OnBoardModel();

  onBoardModel.setImagePath('assets/onboardscreen/dark_mode.png');
  onBoardModel.setTitle('Dark Mode');
  onBoardModel.setDesc('Use app without any strains with the help of in build dark mode');
  slides.add(onBoardModel);
  onBoardModel = new OnBoardModel();

  onBoardModel.setImagePath('assets/onboardscreen/new_notes.png');
  onBoardModel.setTitle('Easy Customization');
  onBoardModel.setDesc('Easily customise your notes with features like edit and delete');
  slides.add(onBoardModel);


  onBoardModel = new OnBoardModel();

  onBoardModel.setImagePath('assets/onboardscreen/add_tasks.png');
  onBoardModel.setTitle('Convert Notes');
  onBoardModel.setDesc('Easily covert any image to notes file in just seconds with a single click');
  slides.add(onBoardModel);

  return slides;
}
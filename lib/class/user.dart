class User {
  String name;
  String email;
  String uid;

  // User({this.name, this.email, this.uid});

  String get getUserUid {
    return this.uid;
  }

  set setUserUid(String uid) {
    this.uid = uid;
  }
}

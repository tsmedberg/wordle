class Web {
  String username = "";
  Web({required this.username});

  static Future<bool> validateUsername(String username) {
    //api to be made
    return Future.value(true);
  }

  static Future<String> getWord() {
    return Future.value("water");
  }
}

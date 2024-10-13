extension ExceptionHandle on Object {
  void logError() {
    print("##-_ ERROR LOGGED _-##"); 
    print(toString()); 
    print("##-_ ERROR LOGGED _-##"); 
  }
}

extension ShortName on String {
  String toShortName() {
    List<String> words = split(' ');

    if (words.isEmpty) {
      return '';
    }

    if (words.length == 1) {
      return this[0].toUpperCase();
    } else {
      return words.map((word) => word[0].toUpperCase()).join();
    }
  }
}

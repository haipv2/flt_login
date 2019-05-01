class ValidatorUtils {

  ///
  /// Check valid length
  ///
  static bool checkLength(String s, int maxLength, int minLength) {
    s ??= '';
    if (s.length == 0 || s.length > maxLength || s.length < minLength) {
      return false;
    }
    return true;
  }

  ///
  /// Check valid string
  static bool validString (String s ) {
    RegExp exp = new RegExp(r"(\w+)");
    return exp.hasMatch(s);
  }
}

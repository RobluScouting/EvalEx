bool isLetter(String ch) {
  if (ch.isEmpty) {
    return false;
  }

  int rune = ch.codeUnitAt(0);
  return (rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A);
}

bool isLetterOrDigit(String ch) {
  return isLetter(ch) || isDigit(ch);
}

// https://github.com/google/quiver-dart/blob/774b7fda30afad7537d779def2e34e47de385286/lib/strings.dart#L102
bool isDigit(String? ch) {
  if (ch == null) {
    return false;
  }

  if (ch.isEmpty) {
    return false;
  }

  int rune = ch.codeUnitAt(0);
  return rune ^ 0x30 <= 9;
}

// https://github.com/google/quiver-dart/blob/774b7fda30afad7537d779def2e34e47de385286/lib/strings.dart#L110
bool isWhitespace(String ch) {
  if (ch.isEmpty) {
    return false;
  }
  int rune = ch.codeUnitAt(0);
  return (rune >= 0x0009 && rune <= 0x000D) ||
      rune == 0x0020 ||
      rune == 0x0085 ||
      rune == 0x00A0 ||
      rune == 0x1680 ||
      rune == 0x180E ||
      (rune >= 0x2000 && rune <= 0x200A) ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202F ||
      rune == 0x205F ||
      rune == 0x3000 ||
      rune == 0xFEFF;
}

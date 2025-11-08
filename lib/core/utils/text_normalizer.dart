/// Normalizes text for search by lower-casing, stripping diacritics, and
/// collapsing common accented or hamza forms to their base characters.
String normalizeText(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final codePoint in lower.runes) {
    if (_arabicDiacritics.contains(codePoint) || _ignoredCodePoints.contains(codePoint)) {
      continue;
    }
    final replacement = _diacriticReplacements[codePoint];
    if (replacement != null) {
      buffer.write(replacement);
    } else {
      buffer.write(String.fromCharCode(codePoint));
    }
  }
  return buffer.toString();
}

const Set<int> _arabicDiacritics = <int>{
  0x064B, // fathatan
  0x064C, // dammatan
  0x064D, // kasratan
  0x064E, // fatha
  0x064F, // damma
  0x0650, // kasra
  0x0651, // shadda
  0x0652, // sukun
  0x0653, // maddah
  0x0654, // hamza above
  0x0655, // hamza below
  0x0656,
  0x0657,
  0x0658,
  0x0659,
  0x065A,
  0x065B,
  0x065C,
  0x065D,
  0x065E,
  0x065F,
  0x0670, // superscript alef
  0x06D6,
  0x06D7,
  0x06D8,
  0x06D9,
  0x06DA,
  0x06DB,
  0x06DC,
  0x06DF,
  0x06E0,
  0x06E1,
  0x06E2,
  0x06E3,
  0x06E4,
  0x06E7,
  0x06E8,
  0x06EA,
  0x06EB,
  0x06EC,
  0x06ED,
};

const Set<int> _ignoredCodePoints = <int>{
  0x0640, // tatweel
};

const Map<int, String> _diacriticReplacements = <int, String>{
  // Latin letters
  0x00E0: 'a', // à
  0x00E1: 'a', // á
  0x00E2: 'a', // â
  0x00E3: 'a', // ã
  0x00E4: 'a', // ä
  0x00E5: 'a', // å
  0x0101: 'a',
  0x0103: 'a',
  0x0105: 'a',
  0x00E6: 'ae', // æ
  0x00E7: 'c', // ç
  0x0107: 'c',
  0x0109: 'c',
  0x010B: 'c',
  0x010D: 'c',
  0x00E8: 'e',
  0x00E9: 'e',
  0x00EA: 'e',
  0x00EB: 'e',
  0x0113: 'e',
  0x0115: 'e',
  0x0117: 'e',
  0x0119: 'e',
  0x011B: 'e',
  0x00EC: 'i',
  0x00ED: 'i',
  0x00EE: 'i',
  0x00EF: 'i',
  0x0129: 'i',
  0x012B: 'i',
  0x012D: 'i',
  0x012F: 'i',
  0x0131: 'i',
  0x00F0: 'd',
  0x010F: 'd',
  0x0111: 'd',
  0x0142: 'l',
  0x013A: 'l',
  0x013C: 'l',
  0x013E: 'l',
  0x0140: 'l',
  0x00F1: 'n',
  0x0144: 'n',
  0x0146: 'n',
  0x0148: 'n',
  0x0149: 'n',
  0x014B: 'n',
  0x00F2: 'o',
  0x00F3: 'o',
  0x00F4: 'o',
  0x00F5: 'o',
  0x00F6: 'o',
  0x00F8: 'o',
  0x014D: 'o',
  0x014F: 'o',
  0x0151: 'o',
  0x0153: 'oe',
  0x00F9: 'u',
  0x00FA: 'u',
  0x00FB: 'u',
  0x00FC: 'u',
  0x0169: 'u',
  0x016B: 'u',
  0x016D: 'u',
  0x016F: 'u',
  0x0171: 'u',
  0x0173: 'u',
  0x00FD: 'y',
  0x00FF: 'y',
  0x0177: 'y',
  0x017A: 'z',
  0x017C: 'z',
  0x017E: 'z',
  0x0155: 'r',
  0x0157: 'r',
  0x0159: 'r',
  0x015B: 's',
  0x015D: 's',
  0x015F: 's',
  0x0161: 's',
  0x0163: 't',
  0x0165: 't',
  0x0167: 't',
  0x0175: 'w',
  0x00DF: 'ss',
  0x011F: 'g',
  0x0137: 'k',
  0x0219: 's',
  0x021B: 't',
  // Arabic variations
  0x0622: 'ا',
  0x0623: 'ا',
  0x0624: 'و',
  0x0625: 'ا',
  0x0626: 'ي',
  0x0629: 'ه',
  0x0649: 'ي',
};

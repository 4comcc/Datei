/// Normalizes text for search: lower-case, Arabic diacritics and tatweel removed,
/// alef forms (أ إ آ ٱ) → ا, ة → ه, ى → ي, ؤ → و, ئ → ي, Arabic-Indic digits → Latin.
/// So "أحمد" matches "احمد", "مدرسة" matches "مدرسه", "مصطفى" matches "مصطفي".
String normalizeForSearch(String input) {
  final b = StringBuffer();
  for (final r in input.toLowerCase().runes) {
    // Harakat, tanween, shadda, sukun, superscript alef, Quranic marks, tatweel.
    if ((r >= 0x064B && r <= 0x065F) || r == 0x0670 || (r >= 0x06D6 && r <= 0x06ED) || r == 0x0640) continue;
    final mapped = switch (r) {
      0x0623 || 0x0625 || 0x0622 || 0x0671 => 0x0627,
      0x0629 => 0x0647,
      0x0649 => 0x064A,
      0x0624 => 0x0648,
      0x0626 => 0x064A,
      >= 0x0660 && <= 0x0669 => r - 0x0660 + 0x30,
      >= 0x06F0 && <= 0x06F9 => r - 0x06F0 + 0x30,
      _ => r,
    };
    b.writeCharCode(mapped);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

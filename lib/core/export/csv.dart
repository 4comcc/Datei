/// Builds RFC 4180 CSV. The UTF-8 BOM makes Excel open Arabic text correctly.
class CsvBuilder {
  CsvBuilder(List<String> header) {
    _row(header);
  }

  static const bom = '\uFEFF';
  final _b = StringBuffer(bom);

  void _row(List<Object?> cells) {
    _b.write(cells.map(_cell).join(','));
    _b.write('\r\n');
  }

  void add(List<Object?> cells) => _row(cells);

  static String _cell(Object? v) {
    final s = v?.toString() ?? '';
    // Neutralize spreadsheet formula injection for text cells.
    final safe = s.isNotEmpty && '=+-@'.contains(s[0]) && double.tryParse(s) == null ? "'$s" : s;
    final needsQuotes = safe.contains(',') || safe.contains('"') || safe.contains('\n') || safe.contains('\r');
    return needsQuotes ? '"${safe.replaceAll('"', '""')}"' : safe;
  }

  @override
  String toString() => _b.toString();
}

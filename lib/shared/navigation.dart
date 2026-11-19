import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

extension SafeNavigation on BuildContext {
  /// Pops when there is a previous page, otherwise goes to [fallback]
  /// (e.g. a screen opened directly from a deep link or notification).
  void popOrGo(String fallback) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}

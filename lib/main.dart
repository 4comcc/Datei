import 'package:material_ui/material_ui.dart';

import 'app/startup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // First frame is drawn immediately; data is opened behind a loading screen.
  runApp(const StartupApp());
}

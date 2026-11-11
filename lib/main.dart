import 'package:flutter/material.dart';

import 'screens/onboarding.dart';
import 'screens/shell.dart';
import 'state.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.load();
  runApp(const DioceseApp());
}

class DioceseApp extends StatelessWidget {
  const DioceseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diocèse de Rabat',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: app,
        builder: (context, _) => app.paroisseId == null ? const OnboardingScreen() : const Shell(),
      ),
    );
  }
}

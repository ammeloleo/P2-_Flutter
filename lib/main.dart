import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'tela_principal.dart';

void main() {
  runApp(const AgendaFatecApp());
}

class AgendaFatecApp extends StatelessWidget {
  const AgendaFatecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Fatec',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
          primary: Colors.redAccent,
        ),
        scaffoldBackgroundColor: const Color(0xff141416),
      ),
      home: const TelaPrincipal(),
    );
  }
}

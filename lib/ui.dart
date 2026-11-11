import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'state.dart';

const brand = Color(0xFF1D3557);
const brand2 = Color(0xFF2C4A75);
const gold = Color(0xFFB8892F);
const paper = Color(0xFFFBF8F3);
const line = Color(0xFFE6DFD3);
const muted = Color(0xFF6B6F7A);
const ink = Color(0xFF1F2430);
const tint = Color(0xFFEEF2F8);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: brand, primary: brand, surface: paper);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: paper,
    appBarTheme: const AppBarTheme(backgroundColor: paper, foregroundColor: ink, elevation: 0, scrolledUnderElevation: 0),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)), side: BorderSide(color: line)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: line)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: line)),
    ),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.white, indicatorColor: tint),
  );
}

/// Reconstruit son contenu à chaque changement de l'état de l'application.
class Watch extends StatelessWidget {
  final WidgetBuilder builder;
  const Watch({super.key, required this.builder});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: app, builder: (c, _) => builder(c));
}

class Titre extends StatelessWidget {
  final String texte;
  final String? sous;
  const Titre(this.texte, {super.key, this.sous});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(texte,
              style: const TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.w600, color: ink)),
          if (sous != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(sous!, style: const TextStyle(color: muted))),
        ]),
      );
}

class Section extends StatelessWidget {
  final String texte;
  const Section(this.texte, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(texte.toUpperCase(),
            style: const TextStyle(fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w600, color: muted)),
      );
}

class Carte extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const Carte({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

class Pastille extends StatelessWidget {
  final String texte;
  const Pastille(this.texte, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(6)),
        child: Text(texte, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: brand)),
      );
}

class Avis extends StatelessWidget {
  final String texte;
  const Avis(this.texte, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2C779)),
        ),
        child: Text(texte, style: const TextStyle(fontSize: 13, color: Color(0xFF6B5414))),
      );
}

Future<void> ouvrir(BuildContext context, String url) async {
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir le lien.")));
  }
}

void info(BuildContext context, String texte) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texte), behavior: SnackBarBehavior.floating));
}

Route<void> page(Widget w) => MaterialPageRoute<void>(builder: (_) => w);

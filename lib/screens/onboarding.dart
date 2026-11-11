import 'package:flutter/material.dart';

import '../state.dart';
import '../ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nom = TextEditingController();
  String _choix = app.paroisses.first.id;

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const Text('✝', style: TextStyle(fontSize: 44, color: gold)),
            const Titre('Archidiocèse de Rabat', sous: 'Choisissez votre paroisse. Vous pourrez en changer à tout moment.'),
            TextField(controller: _nom, decoration: const InputDecoration(labelText: 'Votre prénom (facultatif)')),
            const Section('Ma paroisse'),
            for (final p in app.paroisses)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: p.id == _choix ? brand : line, width: p.id == _choix ? 2 : 1),
                ),
                child: ListTile(
                  leading: Icon(Icons.church_outlined, color: p.id == _choix ? brand : muted),
                  title: Text(p.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(p.ville),
                  trailing: p.id == _choix ? const Icon(Icons.check_circle, color: brand) : null,
                  onTap: () => setState(() => _choix = p.id),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => app.choisir(_choix, _nom.text),
              child: const Text('Commencer'),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('Version de démonstration — données fictives', style: TextStyle(color: muted, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

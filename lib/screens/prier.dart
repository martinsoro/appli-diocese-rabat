import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';

class PrierScreen extends StatelessWidget {
  const PrierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const Titre('Liturgie du jour', sous: '$liturgieDate · $liturgieTemps'),
        Carte(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Saint du jour · couleur liturgique : $liturgieCouleur', style: TextStyle(color: muted, fontSize: 12.5)),
            const SizedBox(height: 4),
            const Text(saintNom, style: TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text(saintBio, style: TextStyle(fontSize: 13.5)),
          ]),
        ),
        for (final l in lectures)
          Carte(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.type, style: const TextStyle(color: muted, fontSize: 12.5)),
              const SizedBox(height: 3),
              Text(l.reference, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(l.resume, style: const TextStyle(fontSize: 13.5)),
            ]),
          ),
        const Avis(
            "Démo : un exemple de jour, avec références et résumés. La version finale affichera chaque jour le texte intégral, sous licence de l'éditeur liturgique, consultable hors connexion."),
        const Section('Prières usuelles'),
        Card(
          child: Column(children: [
            for (final p in prieres)
              ListTile(
                leading: const Icon(Icons.menu_book_outlined, color: brand),
                title: Text(p.titre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, page(PrierePage(p))),
              ),
          ]),
        ),
      ],
    );
  }
}

class PrierePage extends StatelessWidget {
  final Priere priere;
  const PrierePage(this.priere, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(priere.titre)),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          Carte(
            child: Text(priere.texte, style: const TextStyle(fontFamily: 'serif', fontSize: 18, height: 1.55)),
          ),
        ]),
      );
}

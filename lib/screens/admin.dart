import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../ui.dart';

/// Démo du tableau de bord d'un secrétariat paroissial.
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late String _paroisse = app.paroisse.id;
  String _onglet = 'annonce';
  final _titre = TextEditingController();
  final _texte = TextEditingController();
  bool _notifier = true;
  int _jour = 0;
  TimeOfDay _heure = const TimeOfDay(hour: 18, minute: 0);
  String _langue = 'FR';

  @override
  void dispose() {
    _titre.dispose();
    _texte.dispose();
    super.dispose();
  }

  Widget _dropdown<T>(String label, T value, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) => InputDecorator(
        decoration: InputDecoration(labelText: label, isDense: true),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(value: value, isExpanded: true, isDense: true, items: items, onChanged: onChanged),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Watch(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(app.adminMode ? 'Tableau de bord' : 'Espace paroisse')),
        body: app.adminMode ? _tableau(context) : _connexion(context),
      ),
    );
  }

  Widget _connexion(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
        const Text(
            'Accès réservé aux curés et secrétaires. La version finale demandera un compte administrateur avec double authentification.',
            style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        _dropdown<String>('Paroisse gérée', _paroisse, [
          for (final p in app.paroisses) DropdownMenuItem(value: p.id, child: Text('${p.nom} — ${p.ville}')),
        ], (v) => setState(() => _paroisse = v ?? _paroisse)),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => app.setAdmin(true, id: _paroisse), child: const Text('Entrer en mode démo')),
      ]);

  Widget _tableau(BuildContext context) {
    final p = app.paroisse;
    return ListView(padding: const EdgeInsets.all(18), children: [
      Text('${p.nom}, ${p.ville}', style: const TextStyle(color: muted)),
      const SizedBox(height: 12),
      SegmentedButton<String>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: 'annonce', label: Text('Annonce')),
          ButtonSegment(value: 'horaires', label: Text('Horaires')),
          ButtonSegment(value: 'activite', label: Text('Activité')),
        ],
        selected: {_onglet},
        onSelectionChanged: (s) => setState(() => _onglet = s.first),
      ),
      const SizedBox(height: 16),
      if (_onglet == 'annonce') ..._annonce(context),
      if (_onglet == 'horaires') ..._horaires(context, p),
      if (_onglet == 'activite') ..._activite(p),
      const SizedBox(height: 20),
      OutlinedButton(
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        child: const Text("Voir l'appli côté fidèle"),
      ),
    ]);
  }

  List<Widget> _annonce(BuildContext context) => [
        TextField(controller: _titre, decoration: const InputDecoration(labelText: 'Titre', hintText: "Ex. Veillée de l'Avent")),
        const SizedBox(height: 12),
        TextField(
          controller: _texte,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Texte', hintText: 'Date, heure, lieu…'),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _notifier,
          onChanged: (v) => setState(() => _notifier = v ?? true),
          title: const Text('Envoyer une notification aux fidèles de la paroisse'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        FilledButton(
          onPressed: () {
            final t = _titre.text.trim();
            if (t.isEmpty) return;
            app.publier(t, _texte.text.trim());
            _titre.clear();
            _texte.clear();
            info(context, _notifier ? 'Publié. Notification envoyée : « $t » (démo).' : "Publié. L'annonce est visible par les fidèles.");
          },
          child: const Text('Publier'),
        ),
      ];

  List<Widget> _horaires(BuildContext context, Paroisse p) => [
        Card(
          child: Column(children: [
            for (var i = 0; i < p.messes.length; i++)
              ListTile(
                dense: true,
                leading: Text(p.messes[i].heure, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                title: Text('${langues[p.messes[i].langue]} · ${joursLabel(p.messes[i].jours)}'),
                trailing: TextButton(
                  onPressed: () {
                    app.retirerMesse(i);
                    info(context, 'Messe retirée.');
                  },
                  child: const Text('Retirer', style: TextStyle(color: Color(0xFFA02622))),
                ),
              ),
          ]),
        ),
        const Section('Ajouter une messe'),
        Row(children: [
          Expanded(
            flex: 3,
            child: _dropdown<int>('Jour', _jour, [
              for (var i = 0; i < 7; i++) DropdownMenuItem(value: i, child: Text(jours[i])),
            ], (v) => setState(() => _jour = v ?? 0)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _dropdown<String>('Langue', _langue, [
              for (final k in langues.keys) DropdownMenuItem(value: k, child: Text(k)),
            ], (v) => setState(() => _langue = v ?? 'FR')),
          ),
        ]),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.schedule),
          label: Text('Heure : ${_fmt(_heure)}'),
          onPressed: () async {
            final t = await showTimePicker(context: context, initialTime: _heure);
            if (t != null) setState(() => _heure = t);
          },
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () {
            app.ajouterMesse(Messe([_jour], _fmt(_heure), _langue));
            info(context, 'Messe ajoutée. Les fidèles la voient dans Horaires.');
          },
          child: const Text('Ajouter la messe'),
        ),
      ];

  List<Widget> _activite(Paroisse p) => [
        _stat('Annonces publiées', '${app.annonces.where((a) => a.paroisse == p.id).length}'),
        _stat('Messes par semaine', '${p.messes.fold<int>(0, (n, m) => n + m.jours.length)}'),
        _stat('Demandes de messes en attente', '—  (prévu dans une prochaine version)'),
      ];

  Widget _stat(String l, String v) => Carte(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: const TextStyle(color: muted, fontSize: 12.5)),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.w600)),
        ]),
      );

  static String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../ui.dart';
import 'admin.dart';

class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  Widget _tile(BuildContext c, IconData i, String t, String s, Widget dest, {Widget? badge}) => ListTile(
        leading: Icon(i, color: brand),
        title: Row(children: [Text(t), if (badge != null) ...[const SizedBox(width: 8), badge]]),
        subtitle: Text(s),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(c, page(dest)),
      );

  @override
  Widget build(BuildContext context) {
    return Watch(builder: (context) {
      final n = app.nonLues;
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          const Titre('Plus', sous: 'Vie paroissiale et services'),
          Card(
            child: Column(children: [
              _tile(context, Icons.campaign_outlined, 'Annonces', 'Paroisse et diocèse', const AnnoncesPage(),
                  badge: n > 0 ? Badge(label: Text('$n')) : null),
              _tile(context, Icons.groups_outlined, 'Mouvements et chorales', 'Annuaire et contact des responsables',
                  const MouvementsPage()),
              _tile(context, Icons.chat_bubble_outline, 'Assistant', 'Questions pratiques (simulation)', const AssistantPage()),
              _tile(context, Icons.waving_hand_outlined, 'Guide du nouvel arrivant', 'Premiers pas dans le diocèse',
                  const AccueilPage()),
              _tile(context, Icons.person_outline, 'Mon compte', 'Paroisse, prénom, notifications', const ComptePage()),
            ]),
          ),
          const Section('Bientôt'),
          const Card(
            child: Column(children: [
              ListTile(
                enabled: false,
                leading: Icon(Icons.volunteer_activism_outlined),
                title: Text('Dons et denier'),
                subtitle: Text('CMI, Payzone, cartes internationales'),
              ),
              ListTile(
                enabled: false,
                leading: Icon(Icons.edit_calendar_outlined),
                title: Text('Demander une messe'),
                subtitle: Text('Intention, date, validation du secrétariat'),
              ),
            ]),
          ),
          const Section('Administration'),
          Card(
            child: _tile(context, Icons.admin_panel_settings_outlined, 'Espace paroisse',
                'Démo du tableau de bord du secrétariat', const AdminPage()),
          ),
        ],
      );
    });
  }
}

class AnnoncesPage extends StatefulWidget {
  const AnnoncesPage({super.key});
  @override
  State<AnnoncesPage> createState() => _AnnoncesPageState();
}

class _AnnoncesPageState extends State<AnnoncesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => app.marquerLues());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Annonces')),
        body: Watch(
          builder: (context) => ListView(
            padding: const EdgeInsets.all(18),
            children: [
              for (final a in app.annoncesDe(app.paroisseId))
                Carte(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(a.titre, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text(dateCourte(a.date), style: const TextStyle(color: muted, fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Text(a.texte),
                    const SizedBox(height: 6),
                    Text(a.paroisse == '*' ? 'Archidiocèse de Rabat' : (app.byId(a.paroisse)?.nom ?? ''),
                        style: const TextStyle(color: muted, fontSize: 12)),
                  ]),
                ),
            ],
          ),
        ),
      );
}

class MouvementsPage extends StatelessWidget {
  const MouvementsPage({super.key});

  Widget _carte(BuildContext context, Mouvement m) => Carte(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(m.nom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
            Pastille(m.type),
          ]),
          const SizedBox(height: 6),
          Text(m.desc, style: const TextStyle(fontSize: 13.5)),
          const SizedBox(height: 6),
          Text(m.paroisse == '*' ? m.quand : '${m.quand} · ${app.byId(m.paroisse)?.ville ?? ''}',
              style: const TextStyle(color: muted, fontSize: 12.5)),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => info(context, 'Démo : le responsable de « ${m.nom} » serait prévenu, sans afficher son numéro.'),
            child: const Text('Contacter le responsable'),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final mine = app.mouvements.where((m) => m.paroisse == app.paroisseId || m.paroisse == '*');
    final autres = app.mouvements.where((m) => m.paroisse != app.paroisseId && m.paroisse != '*');
    return Scaffold(
      appBar: AppBar(title: const Text('Mouvements')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Section('Ma paroisse'),
        for (final m in mine) _carte(context, m),
        const Section('Ailleurs dans le diocèse'),
        for (final m in autres) _carte(context, m),
      ]),
    );
  }
}

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  Widget _etape(String t, String x) => Carte(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(x, style: const TextStyle(fontSize: 13.5)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Bienvenue au Maroc')),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          const Text("Guide du nouvel arrivant (contenu d'exemple)", style: TextStyle(color: muted)),
          const SizedBox(height: 12),
          _etape('1. Rattachez-vous à une paroisse',
              "Votre paroisse actuelle : ${app.paroisse.nom}. Présentez-vous à l'accueil après la messe."),
          _etape('2. Rejoignez une communauté',
              'Aumôneries étudiantes, communautés anglophones, hispanophones et lusophones : voir les mouvements.'),
          _etape('3. Faites-vous recenser', 'Le formulaire de recensement pastoral arrivera dans une prochaine version.'),
          _etape('4. Vivre sa foi dans le pays', 'Conseils du diocèse pour les nouveaux arrivants (texte à rédiger par le diocèse).'),
          FilledButton(
            onPressed: () => Navigator.pushReplacement(context, page(const MouvementsPage())),
            child: const Text('Voir les mouvements'),
          ),
        ]),
      );
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  void _envoyer(String q) {
    app.ask(q);
    _ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const suggestions = ['Messe en anglais dimanche à Casablanca', 'Confessions à Rabat', 'Baptiser mon enfant', 'Chorale à Rabat'];
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant')),
      body: Watch(
        builder: (context) => Column(children: [
          Expanded(
            child: ListView(controller: _scroll, padding: const EdgeInsets.all(16), children: [
              const Avis(
                  "Simulation : réponses calculées à partir des données de l'application. L'assistant IA réel viendra plus tard, avec des sources validées par le diocèse."),
              for (final m in app.chat)
                Align(
                  alignment: m.moi ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      color: m.moi ? brand : Colors.white,
                      border: m.moi ? null : Border.all(color: line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.texte, style: TextStyle(color: m.moi ? Colors.white : ink, height: 1.4)),
                      if (m.source != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('Source : ${m.source}', style: const TextStyle(color: muted, fontSize: 11.5)),
                        ),
                    ]),
                  ),
                ),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final s in suggestions) ActionChip(label: Text(s), onPressed: () => _envoyer(s)),
              ]),
            ]),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(hintText: 'Votre question…', isDense: true),
                    onSubmitted: _envoyer,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: () => _envoyer(_ctrl.text), icon: const Icon(Icons.send)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class ComptePage extends StatefulWidget {
  const ComptePage({super.key});
  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  late final TextEditingController _nom = TextEditingController(text: app.prenom);
  late String _paroisse = app.paroisse.id;
  bool _notifParoisse = true, _notifDiocese = true;

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mon compte')),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          TextField(controller: _nom, decoration: const InputDecoration(labelText: 'Prénom')),
          const SizedBox(height: 14),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Paroisse de rattachement'),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _paroisse,
                isExpanded: true,
                isDense: true,
                items: [
                  for (final p in app.paroisses) DropdownMenuItem(value: p.id, child: Text('${p.nom} — ${p.ville}')),
                ],
                onChanged: (v) => setState(() => _paroisse = v ?? _paroisse),
              ),
            ),
          ),
          const Section('Notifications'),
          Card(
            child: Column(children: [
              SwitchListTile(
                  title: const Text('Annonces de ma paroisse'),
                  value: _notifParoisse,
                  onChanged: (v) => setState(() => _notifParoisse = v)),
              SwitchListTile(
                  title: const Text('Actualités du diocèse'),
                  value: _notifDiocese,
                  onChanged: (v) => setState(() => _notifDiocese = v)),
            ]),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              app.choisir(_paroisse, _nom.text);
              info(context, 'Vos préférences sont enregistrées.');
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () async {
              Navigator.of(context).popUntil((r) => r.isFirst);
              await app.reset();
            },
            child: const Text('Réinitialiser la démo', style: TextStyle(color: Color(0xFFA02622))),
          ),
          const Text(
              'La version finale proposera la connexion par e-mail, téléphone, Google ou Apple, et la suppression du compte.',
              style: TextStyle(color: muted, fontSize: 12.5)),
        ]),
      );
}

import 'package:flutter/material.dart';

import '../state.dart';
import '../ui.dart';
import 'carte.dart';
import 'home.dart';
import 'horaires.dart';
import 'plus.dart';
import 'prier.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  void _go(int i) => setState(() => _i = i);

  @override
  Widget build(BuildContext context) {
    return Watch(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            if (app.adminMode)
              Container(
                width: double.infinity,
                color: const Color(0xFF2A2016),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  Expanded(
                      child: Text('Mode secrétariat — ${app.paroisse.nom}',
                          style: const TextStyle(color: Color(0xFFF5E6C8), fontSize: 12))),
                  TextButton(
                    onPressed: () => app.setAdmin(false),
                    child: const Text('Quitter', style: TextStyle(color: Color(0xFFF5E6C8))),
                  ),
                ]),
              ),
            Expanded(
              child: IndexedStack(index: _i, children: [
                HomeScreen(onGo: _go),
                const HorairesScreen(),
                const CarteScreen(),
                const PrierScreen(),
                const PlusScreen(),
              ]),
            ),
          ]),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: _go,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
            const NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Horaires'),
            const NavigationDestination(icon: Icon(Icons.place_outlined), selectedIcon: Icon(Icons.place), label: 'Carte'),
            const NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Prier'),
            NavigationDestination(
              icon: Badge(isLabelVisible: app.nonLues > 0, label: Text('${app.nonLues}'), child: const Icon(Icons.more_horiz)),
              label: 'Plus',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/screens/consommateur/accueil.dart';
import 'package:suguconnect_mobile/screens/consommateur/barr_navigation.dart';
import 'package:suguconnect_mobile/screens/consommateur/commandes_page.dart';
import 'package:suguconnect_mobile/screens/consommateur/favoris_page.dart';
import 'package:suguconnect_mobile/screens/consommateur/profil_page.dart';
import 'package:suguconnect_mobile/screens/consommateur/panier_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int pageIndex = 0;

  final List<Widget> pages = const [
    AccueilPage(),
    FavorisPage(),
    PagePanier(),  
   PageCommandes(),
    ProfilPage(),
  ];

  void _changerPage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: BarreNavigation(
        indexActif: pageIndex,
        onItemSelected: _changerPage,
      ),
    );
  }
}

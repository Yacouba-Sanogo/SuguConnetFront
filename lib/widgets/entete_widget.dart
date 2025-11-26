import 'package:flutter/material.dart';
import '../constantes.dart';

class EnteteWidget extends StatelessWidget implements PreferredSizeWidget {
  const EnteteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withValues(alpha: 0.4),
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Image.asset(
        Constantes.logoPath,
        height: 70,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            'SuguConnect',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  // Nécessaire pour utiliser ce widget comme AppBar dans un Scaffold
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


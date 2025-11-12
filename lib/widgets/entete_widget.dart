import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/screens/consommateur/page_notification.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';

class EnteteWidget extends StatelessWidget implements PreferredSizeWidget {
  const EnteteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withValues(alpha: 0.4),
      centerTitle: false,
      title: Image.asset(logoPath, height: 70),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, size: 36),
          tooltip: 'Voir les notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PageNotification()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Nécessaire pour utiliser ce widget comme AppBar dans un Scaffold
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

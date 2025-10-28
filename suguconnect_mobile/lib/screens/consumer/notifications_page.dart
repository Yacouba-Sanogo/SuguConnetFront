import 'package:flutter/material.dart';
import 'messaging_page.dart';
import '../producer/producer_refunds_screen.dart';
import '../producer/producer_payments_screen.dart';
import '../producer/producer_orders_screen.dart';
import 'driver_list_screen.dart';

// Page des notifications avec design moderne et cartes colorées
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Contrôleur pour la barre de recherche
  final TextEditingController _searchController = TextEditingController();
  
  // Liste des notifications
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Commande",
      description: "Nouvelle commande reçue",
      time: "10:20",
      icon: Icons.receipt,
      iconColor: Colors.blue,
      cardColor: const Color(0xFFE8EAF6), // Lavande clair
    ),
    NotificationItem(
      title: "Livraison",
      description: "Commande en cours de livraison",
      time: "Hier",
      icon: Icons.local_shipping,
      iconColor: Colors.orange,
      cardColor: const Color(0xFFFFF3E0), // Orange clair
    ),
    NotificationItem(
      title: "Paiement",
      description: "Nouveau paiement reçu",
      time: "10:20",
      icon: Icons.account_balance_wallet,
      iconColor: Colors.green,
      cardColor: const Color(0xFFE8F5E8), // Vert clair
    ),
    NotificationItem(
      title: "Demandes de remboursement",
      description: "2 nouvelles demandes en attente",
      time: "Maintenant",
      icon: Icons.money_off,
      iconColor: const Color(0xFFFF9800),
      cardColor: const Color(0xFFFFF8E1), // Orange très clair
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFB662F).withOpacity(0.1), // Couleur FB662F avec 10% d'opacité
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bouton de messagerie
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.black54),
            onPressed: () {
              // Navigation vers la page de messagerie
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagingPage(),
                ),
              );
            },
          ),
          // Bouton de notifications (déjà sur la page)
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
            onPressed: () {
              // Déjà sur la page des notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vous êtes déjà sur la page des notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Titre de la section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Liste des notifications
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return GestureDetector(
                  onTap: () {
                    if (notification.title == "Commande") {
                      // Navigation vers la page des commandes du producteur
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProducerOrdersScreen(),
                        ),
                      );
                    } else if (notification.title == "Livraison") {
                      // Navigation vers la page des livreurs
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverListScreen(),
                        ),
                      );
                    } else if (notification.title == "Demandes de remboursement") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProducerRefundsScreen(),
                        ),
                      );
                    } else if (notification.title == "Paiement") {
                      // Pour le producteur : gestion des paiements reçus
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProducerPaymentsScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: notification.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icône de la notification
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: notification.iconColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              notification.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Contenu de la notification
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Timestamp
                          Text(
                            notification.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Modèle de données pour les notifications
class NotificationItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color cardColor;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.cardColor,
  });
}

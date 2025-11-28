import 'package:flutter/material.dart';
import 'notifications_page.dart';
import '../producer/producer_refunds_screen.dart';
import '../producer/producer_payments_screen.dart';
import '../producer/producer_orders_screen.dart';
import '../producer/producer_conversations_screen.dart';
import 'driver_list_screen.dart';

// Page principale de notifications
class MessagingPage extends StatefulWidget {
  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  String _selectedFilter = 'TOUS';
  final TextEditingController _searchController = TextEditingController();

  // Liste des notifications
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Commande",
      description: "Gérer vos commandes",
      time: "10:20",
      icon: Icons.receipt,
      iconColor: Colors.blue,
      cardColor: const Color(0xFFE8EAF6), // Lavande clair
    ),
    NotificationItem(
      title: "Livraison",
      description: "Suivre les livraisons",
      time: "Hier",
      icon: Icons.local_shipping,
      iconColor: Colors.orange,
      cardColor: const Color(0xFFFFF3E0), // Orange clair
    ),
    NotificationItem(
      title: "Paiement",
      description: "Voir les paiements",
      time: "10:20",
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFF8FA31E), // Olive green
      cardColor: const Color(0xFFE8F5E8), // Vert clair
    ),
    NotificationItem(
      title: "Message",
      description: "Voir les messages reçus",
      time: "Maintenant",
      icon: Icons.chat_bubble_outline,
      iconColor: const Color(0xFFFB662F), // Orange principal
      cardColor: const Color(0xFFFFF5F0), // Orange très clair
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildNotificationsTitle(),
          _buildNotificationsList(),
        ],
      ),
    );
  }

  // Construit la barre d'application
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFB662F).withOpacity(0.1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Messages',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  // Construit la barre de recherche
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Rechercher',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // Construit le titre des notifications
  Widget _buildNotificationsTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Text(
        'Notifications',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  // Construit la liste des notifications
  Widget _buildNotificationsList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return GestureDetector(
            onTap: () {
              if (notification.title == "Commande") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProducerOrdersScreen(),
                  ),
                );
              } else if (notification.title == "Livraison") {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProducerPaymentsScreen(),
                  ),
                );
              } else if (notification.title == "Message") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProducerConversationsScreen(),
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notification.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

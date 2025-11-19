import 'package:flutter/material.dart';
import 'chat_page.dart'; // Remplacement de chat_page_simple.dart par chat_page.dart
import 'notifications_page.dart';

// Page principale de messagerie avec liste des conversations
class MessagingPage extends StatefulWidget {
  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  String _selectedFilter = 'TOUS';
  final TextEditingController _searchController = TextEditingController();

  // Liste des conversations
  final List<Map<String, dynamic>> _contacts = [
    {
      'id': '1',
      'name': 'Mamadou Diallo',
      'lastMessage': 'Bonjour, votre commande est prête',
      'time': '14:30',
      'avatar': 'assets/images/improfil.png', // Utiliser une image existante
      'isOnline': true,
      'role': 'Producteur',
    },
    {
      'id': '2',
      'name': 'Aicha Koné',
      'lastMessage': 'Merci pour votre achat !',
      'time': '12:15',
      'avatar': 'assets/images/improfil.png', // Utiliser une image existante
      'isOnline': false,
      'role': 'Producteur',
    },
    {
      'id': '3',
      'name': 'Ibrahim Touré',
      'lastMessage': 'Votre livraison arrive dans 30 min',
      'time': '10:45',
      'avatar': 'assets/images/improfil.png', // Utiliser une image existante
      'isOnline': true,
      'role': 'Livreur',
    },
    {
      'id': '4',
      'name': 'Fatou Diop',
      'lastMessage': 'Pouvez-vous préciser l\'adresse ?',
      'time': '09:20',
      'avatar': 'assets/images/improfil.png', // Utiliser une image existante
      'isOnline': false,
      'role': 'Producteur',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterButtons(),
          _buildConversationsList(),
        ],
      ),
    );
  }

  // Construit la barre d'application
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
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
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black54,
                  size: 24,
                ),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  // Construit les boutons de filtre
  Widget _buildFilterButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterButton('TOUS', _selectedFilter == 'TOUS'),
          const SizedBox(width: 12),
          _buildFilterButton('Non lus', _selectedFilter == 'Non lus'),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            child: Column(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construit un bouton de filtre
  Widget _buildFilterButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFB662F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFB662F) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Construit la liste des conversations
  Widget _buildConversationsList() {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _contacts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation = _contacts[index];
          return _buildConversationItem(conversation);
        },
      ),
    );
  }

  // Construit un élément de conversation
  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(conversation['avatar']),
            child: conversation['avatar'] == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          if (conversation['unread'])
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFB662F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation['name'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        conversation['lastMessage'],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation['time'],
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          if (conversation['isOnline'])
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        // Navigation vers la page de chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              producerId: int.tryParse(conversation['id']) ??
                  1, // Conversion de l'ID en int
              producerName: conversation['name'],
              producerAvatar: conversation['avatar'],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

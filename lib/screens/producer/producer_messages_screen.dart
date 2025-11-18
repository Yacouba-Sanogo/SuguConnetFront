import 'package:flutter/material.dart';

class ProducerMessagesScreen extends StatefulWidget {
  const ProducerMessagesScreen({super.key});

  @override
  State<ProducerMessagesScreen> createState() => _ProducerMessagesScreenState();
}

class _ProducerMessagesScreenState extends State<ProducerMessagesScreen> {
  int _filterIndex = 0; // 0 tous, 1 non lus

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Barre de recherche moderne
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          
          // Filtres modernes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _ModernFilterChip(
                  label: 'TOUS',
                  selected: _filterIndex == 0,
                  onSelected: () => setState(() => _filterIndex = 0),
                ),
                const SizedBox(width: 12),
                _ModernFilterChip(
                  label: 'Non lus',
                  selected: _filterIndex == 1,
                  onSelected: () => setState(() => _filterIndex = 1),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Liste des messages moderne
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final unread = index % 2 == 0;
                if (_filterIndex == 1 && !unread) return const SizedBox.shrink();
                return _ModernMessageCard(
                  name: index % 3 == 0 ? 'Sory Coulibaly' : 'Aminata Traoré',
                  message: 'Lorem ipsum dolor sit amet, elit.',
                  time: index == 0 ? '10:20' : 'Hier',
                  unread: unread,
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernMessageCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const _ModernMessageCard({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Avatar avec indicateur de non-lecture
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  if (unread)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 8,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Contenu du message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _ModernFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFF6B35) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: selected ? 2 : 0,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF6B35) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFFFF6B35) : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../consumer/chat_page.dart';

class ProducerConversationsScreen extends StatefulWidget {
  const ProducerConversationsScreen({super.key});

  @override
  State<ProducerConversationsScreen> createState() => _ProducerConversationsScreenState();
}

class _ProducerConversationsScreenState extends State<ProducerConversationsScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _conversations = [];
  final Map<int, String> _consumerNames = {}; // Cache pour les noms des consommateurs

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final producerId = authProvider.currentUser?.id;

      if (producerId == null || producerId <= 0) {
        throw Exception('Producteur non connecté');
      }

      // Récupérer les conversations du producteur
      final conversations = await _chatService.getProducerConversations(producerId);
      
      // Pour chaque conversation, charger le nom du consommateur
      for (var conversation in conversations) {
        // Le nouvel endpoint peut retourner soit consommateurId soit producteurId
        // Pour un producteur, on cherche les consommateurs avec qui il a échangé
        final consumerId = conversation['consommateurId'];
        final producerIdFromConv = conversation['producteurId'];
        
        // Si c'est un consommateur (consommateurId non null), charger son nom
        if (consumerId != null && !_consumerNames.containsKey(consumerId)) {
          try {
            final consumer = await _userService.getConsumerById(consumerId);
            _consumerNames[consumerId] = '${consumer.prenom} ${consumer.nom}';
          } catch (e) {
            // Si le chargement échoue, utiliser le nom depuis la conversation si disponible
            final nomConsommateur = conversation['nomConsommateur'];
            _consumerNames[consumerId] = nomConsommateur ?? 'Consommateur #$consumerId';
          }
        }
        
        // Si c'est un producteur (producteurId non null et différent du producteur actuel), charger son nom
        if (producerIdFromConv != null && producerIdFromConv != producerId && !_consumerNames.containsKey(producerIdFromConv)) {
          try {
            final producer = await _userService.getProducerById(producerIdFromConv);
            _consumerNames[producerIdFromConv] = '${producer.prenom} ${producer.nom}';
          } catch (e) {
            final nomProducteur = conversation['nomProducteur'];
            _consumerNames[producerIdFromConv] = nomProducteur ?? 'Producteur #$producerIdFromConv';
          }
        }
      }

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des conversations: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des conversations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getConsumerName(Map<String, dynamic> conversation) {
    final consumerId = conversation['consommateurId'];
    final producerIdFromConv = conversation['producteurId'];
    
    if (consumerId != null) {
      return _consumerNames[consumerId] ?? 
             conversation['nomConsommateur'] ?? 
             'Consommateur #$consumerId';
    } else if (producerIdFromConv != null) {
      return _consumerNames[producerIdFromConv] ?? 
             conversation['nomProducteur'] ?? 
             'Producteur #$producerIdFromConv';
    }
    
    return 'Utilisateur inconnu';
  }
  
  int? _getOtherUserId(Map<String, dynamic> conversation) {
    final consumerId = conversation['consommateurId'];
    final producerIdFromConv = conversation['producteurId'];
    
    if (consumerId != null) {
      return consumerId;
    } else if (producerIdFromConv != null) {
      return producerIdFromConv;
    }
    
    return null;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFB662F),
              ),
            )
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun message reçu',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous n\'avez pas encore reçu de messages',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  color: const Color(0xFFFB662F),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final otherUserId = _getOtherUserId(conversation);
                      final otherUserName = _getConsumerName(conversation);
                      final lastMessageDate = conversation['dateDernierMessage']?.toString();
                      final dernierMessage = conversation['dernierMessage']?.toString();
                      
                      return InkWell(
                        onTap: () async {
                          if (otherUserId != null && otherUserId > 0) {
                            // Pour le producteur qui veut parler avec un autre utilisateur
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final producerId = authProvider.currentUser?.id;
                            
                            if (producerId != null && producerId > 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    producerId: otherUserId, // ID de l'autre utilisateur avec qui le producteur veut parler
                                    producerName: otherUserName,
                                    producerAvatar: '',
                                  ),
                                ),
                              ).then((_) {
                                // Rafraîchir la liste après retour du chat
                                _loadConversations();
                              });
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFB662F).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFFFB662F),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Informations
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      otherUserName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dernierMessage ?? 'Cliquez pour voir la conversation',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Date
                              if (lastMessageDate != null)
                                Text(
                                  _formatDate(lastMessageDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


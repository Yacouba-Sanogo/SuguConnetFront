import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

// Page de chat individuel avec un producteur (version avancée)
class ChatPage extends StatefulWidget {
  final int producerId;
  final String producerName;
  final String producerAvatar;

  const ChatPage({
    super.key,
    required this.producerId,
    required this.producerName,
    required this.producerAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final ApiService _apiService = ApiService(); // Ajout de l'instance ApiService
  bool _isRecording = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordingPath;
  bool _isLoading = false;
  Timer? _typingTimer;

  // Messages de la conversation
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  // Charger les messages
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliser l'ID de l'utilisateur connecté
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      // Afficher les IDs pour le débogage
      print('=== Débogage des IDs ===');
      print('User ID: $userId');
      print('Producer ID: ${widget.producerId}');
      print('Is authenticated: ${authProvider.isAuthenticated}');
      print('Current user: ${authProvider.currentUser}');

      // Vérifier que l'utilisateur est connecté
      if (userId == null) {
        print('ERREUR: Utilisateur non connecté');
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier que les IDs sont valides
      if (userId <= 0) {
        print('ERREUR: User ID invalide: $userId');
        throw Exception('User ID invalide: $userId');
      }

      if (widget.producerId <= 0) {
        print('ERREUR: Producer ID invalide: ${widget.producerId}');
        throw Exception('Producer ID invalide: ${widget.producerId}');
      }

      print(
          'Appel de getMessages avec userId1: $userId, userId2: ${widget.producerId}');
      final messages = await _chatService.getMessages(
        userId1: userId,
        userId2: widget.producerId,
      );

      // Construire les messages avec les URLs d'images correctes
      final processedMessages = await Future.wait(messages.map((msg) async {
        // Construire l'URL complète pour les fichiers
        String? fullPath;
        if (msg['filePath'] != null) {
          fullPath = await _apiService.buildImageUrl(msg['filePath']);
        }

        return {
          'id': msg['id'].toString(),
          'text': msg['content'],
          'isMe': msg['senderId'] == userId,
          'time': _formatTimeString(msg['timestamp']),
          'type': msg['type']?.toLowerCase() ?? 'text',
          'path': fullPath ?? msg['filePath'], // Pour les fichiers/images
        };
      }).toList());

      setState(() {
        _messages.clear();
        _messages.addAll(processedMessages);
      });
    } catch (e, stackTrace) {
      print('=== ERREUR DE CHARGEMENT DES MESSAGES ===');
      print('Erreur: $e');
      print('Stack trace: $stackTrace');

      // Même en cas d'erreur, on continue avec une liste vide
      setState(() {
        _messages.clear();
      });

      // Afficher un message à l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Impossible de charger les messages - Affichage d\'une conversation vide'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // Scroll vers le bas de la liste
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Envoyer un message texte
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final message = await _chatService.sendMessage(
        senderId: userId,
        receiverId: widget.producerId,
        content: text,
      );

      setState(() {
        _messages.add({
          'id': message['id'].toString(),
          'text': message['content'],
          'isMe': true,
          'time': _formatTimeString(message['timestamp']),
          'type': message['type']?.toLowerCase() ?? 'text',
        });
        _messageController.clear();
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Envoyer une image
  Future<void> _sendImage() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Permission de stockage requise');
      }

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        final message = await _chatService.sendImage(
          senderId: userId,
          receiverId: widget.producerId,
          imageFile: imageFile,
        );

        setState(() {
          _messages.add({
            'id': message['id'].toString(),
            'text': message['content'],
            'isMe': true,
            'time': _formatTimeString(message['timestamp']),
            'type': message['type']?.toLowerCase() ?? 'image',
            'path': message['filePath'],
          });
        });

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi d\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Démarrer l'enregistrement vocal
  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw Exception('Permission microphone requise');
      }

      // TODO: Implémenter l'enregistrement vocal
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de démarrage d\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Arrêter l'enregistrement vocal
  Future<void> _stopRecording() async {
    try {
      if (_isRecording && _recordingPath != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        final audioFile = File(_recordingPath!);
        final message = await _chatService.sendVoiceMessage(
          senderId: userId,
          receiverId: widget.producerId,
          audioFile: audioFile,
        );

        setState(() {
          _messages.add({
            'id': message['id'].toString(),
            'text': message['content'],
            'isMe': true,
            'time': _formatTimeString(message['timestamp']),
            'type': message['type']?.toLowerCase() ?? 'voice',
            'path': message['filePath'],
          });
          _isRecording = false;
          _recordingPath = null;
        });

        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi de message vocal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Formater l'heure
  String _formatTimeString(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  // Jouer un message vocal
  Future<void> _playVoiceMessage(String path) async {
    try {
      final fullPath = await _apiService.buildImageUrl(path);
      await _audioPlayer.play(UrlSource(fullPath));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de lecture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.producerAvatar.isNotEmpty
                  ? AssetImage(widget.producerAvatar)
                  : null,
              child: widget.producerAvatar.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.producerName),
                const Text(
                  'En ligne',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Indicateur de saisie
          // TODO: Implémenter l'indicateur de saisie

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Boutons d'action
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.orange),
                      onPressed: _sendImage,
                    ),
                    IconButton(
                      icon: Icon(
                        _isRecording
                            ? Icons.stop
                            : Icons.mic,
                        color: _isRecording ? Colors.red : Colors.grey,
                      ),
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                    ),
                  ],
                ),

                // Champ de texte
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                        hintText: 'Tapez un message...',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (text) {
                        // TODO: Implémenter l'indicateur de saisie
                      },
                    ),
                  ),
                ),

                // Bouton d'envoi
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construire une bulle de message
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    final type = message['type'] as String? ?? 'text';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.orange[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Contenu du message selon le type
            if (type == 'text')
              Text(message['text'] ?? '')
            else if (type == 'image')
              _buildImageMessage(message)
            else if (type == 'voice')
              _buildVoiceMessage(message)
            else
              Text(message['text'] ?? ''),

            // Heure du message
            const SizedBox(height: 5),
            Text(
              message['time'] ?? '',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Construire un message image
  Widget _buildImageMessage(Map<String, dynamic> message) {
    final path = message['path'] as String?;
    if (path == null || path.isEmpty) {
      return const Text('Image non disponible');
    }

    return FutureBuilder<String>(
      future: _apiService.buildImageUrl(path),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              // TODO: Afficher l'image en plein écran
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                snapshot.data!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 50);
                },
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Icon(Icons.broken_image, size: 50);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  // Construire un message vocal
  Widget _buildVoiceMessage(Map<String, dynamic> message) {
    final path = message['path'] as String?;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.orange),
            onPressed: path != null
                ? () => _playVoiceMessage(path)
                : null,
          ),
          const Text('Message vocal'),
        ],
      ),
    );
  }
}
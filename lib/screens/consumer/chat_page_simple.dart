import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
<<<<<<< HEAD
import 'package:suguconnect_mobile/services/chat_service.dart'; // Ajout de l'import
=======
>>>>>>> f8cdcc2 (commit pour le premier)
import 'dart:io';

// Page de chat individuel avec un producteur (version simplifiée)
class ChatPageSimple extends StatefulWidget {
  final String producerName;
  final String producerAvatar;
<<<<<<< HEAD
  final int producerId; // Ajout de l'ID du producteur
  final int consumerId; // Ajout de l'ID du consommateur
=======
>>>>>>> f8cdcc2 (commit pour le premier)

  const ChatPageSimple({
    super.key,
    required this.producerName,
    required this.producerAvatar,
<<<<<<< HEAD
    required this.producerId,
    required this.consumerId,
=======
>>>>>>> f8cdcc2 (commit pour le premier)
  });

  @override
  State<ChatPageSimple> createState() => _ChatPageSimpleState();
}

class _ChatPageSimpleState extends State<ChatPageSimple> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
<<<<<<< HEAD
  final ChatService _chatService = ChatService(); // Ajout du service de chat
  bool _isRecording = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordingPath;
  bool _isLoading = false; // Ajout d'un indicateur de chargement

  // Messages de la conversation
  final List<Map<String, dynamic>> _messages = [];
=======
  bool _isRecording = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordingPath;

  // Messages de la conversation
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Bonjour ! Comment puis-je vous aider ?',
      'isMe': false,
      'time': '10:30',
      'type': 'text',
    },
    {
      'id': '2',
      'text': 'Je suis intéressé par vos produits locaux',
      'isMe': true,
      'time': '10:32',
      'type': 'text',
    },
    {
      'id': '3',
      'text': 'Parfait ! J\'ai de beaux légumes frais du jardin',
      'isMe': false,
      'time': '10:33',
      'type': 'text',
    },
  ];
>>>>>>> f8cdcc2 (commit pour le premier)

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadMessages(); // Charger les messages depuis le backend
=======
    _scrollToBottom();
>>>>>>> f8cdcc2 (commit pour le premier)
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
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

  // Formater l'heure
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Envoyer un message texte
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': _messageController.text.trim(),
          'isMe': true,
          'time': _formatTime(DateTime.now()),
          'type': 'text',
        });
      });
      _messageController.clear();
      _scrollToBottom();
<<<<<<< HEAD

      // Envoyer le message au backend
      _sendMessageToBackend(_messageController.text.trim());
=======
>>>>>>> f8cdcc2 (commit pour le premier)
    }
  }

  // Démarre l'enregistrement vocal (simulé)
  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        setState(() {
          _isRecording = true;
        });
        HapticFeedback.mediumImpact();
<<<<<<< HEAD

        _recordingPath =
            '/tmp/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

=======
        
        _recordingPath = '/tmp/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
>>>>>>> f8cdcc2 (commit pour le premier)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎤 Enregistrement en cours...'),
            backgroundColor: Color(0xFFFB662F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission microphone refusée'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Arrête l'enregistrement vocal (simulé)
  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
      });
      HapticFeedback.mediumImpact();
<<<<<<< HEAD

=======
      
>>>>>>> f8cdcc2 (commit pour le premier)
      if (_recordingPath != null) {
        _addVoiceMessage(_recordingPath!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Message vocal enregistré'),
            backgroundColor: Color(0xFFFB662F),
          ),
        );
<<<<<<< HEAD

        // Envoyer le message vocal au backend
        _sendMessageToBackend(_recordingPath!, type: 'voice');
=======
>>>>>>> f8cdcc2 (commit pour le premier)
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Annule l'enregistrement vocal
  void _cancelRecording() {
    setState(() {
      _isRecording = false;
      _recordingPath = null;
    });
    HapticFeedback.lightImpact();
<<<<<<< HEAD

=======
    
>>>>>>> f8cdcc2 (commit pour le premier)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Enregistrement annulé'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // Ajouter un message vocal
  void _addVoiceMessage(String path) {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'Message vocal',
        'isMe': true,
        'time': _formatTime(DateTime.now()),
        'type': 'voice',
        'path': path,
      });
    });
    _scrollToBottom();
  }

  // Jouer un message vocal
  Future<void> _playVoiceMessage(String path) async {
    try {
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de lecture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Sélectionner une image
  Future<void> _pickImage(String source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
<<<<<<< HEAD

=======
      
>>>>>>> f8cdcc2 (commit pour le premier)
      if (image != null) {
        _addImageMessage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de sélection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Ajouter un message image
  void _addImageMessage(String path) {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'Image',
        'isMe': true,
        'time': _formatTime(DateTime.now()),
        'type': 'image',
        'path': path,
      });
    });
    _scrollToBottom();
<<<<<<< HEAD

    // Envoyer l'image au backend
    _sendMessageToBackend(path, type: 'image');
=======
>>>>>>> f8cdcc2 (commit pour le premier)
  }

  // Afficher les options d'attachement
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFFFB662F)),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage('camera');
              },
            ),
            ListTile(
<<<<<<< HEAD
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFFB662F)),
=======
              leading: const Icon(Icons.photo_library, color: Color(0xFFFB662F)),
>>>>>>> f8cdcc2 (commit pour le premier)
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage('gallery');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFFFB662F)),
              title: const Text('Vidéo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la sélection de vidéo
              },
            ),
            ListTile(
<<<<<<< HEAD
              leading:
                  const Icon(Icons.insert_drive_file, color: Color(0xFFFB662F)),
=======
              leading: const Icon(Icons.insert_drive_file, color: Color(0xFFFB662F)),
>>>>>>> f8cdcc2 (commit pour le premier)
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la sélection de document
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFFFB662F)),
              title: const Text('Localisation'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter l'envoi de localisation
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/arrièreplandiscussion.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Construire l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(widget.producerAvatar),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.producerName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'En ligne',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Color(0xFFFB662F)),
          onPressed: () {
            // TODO: Implémenter l'appel vidéo
          },
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: Color(0xFFFB662F)),
          onPressed: () {
            // TODO: Implémenter l'appel vocal
          },
        ),
      ],
    );
  }

  // Construire la liste des messages
  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  // Construire une bulle de message
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
<<<<<<< HEAD
        mainAxisAlignment:
            message['isMe'] ? MainAxisAlignment.end : MainAxisAlignment.start,
=======
        mainAxisAlignment: message['isMe'] 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
>>>>>>> f8cdcc2 (commit pour le premier)
        children: [
          if (!message['isMe']) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.producerAvatar),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: message['isMe']
                    ? const Color(0xFFFB662F).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message['isMe']
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: message['isMe']
                      ? const Radius.circular(4)
=======
                color: message['isMe'] 
                    ? const Color(0xFFFB662F).withOpacity(0.9) 
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message['isMe'] 
                      ? const Radius.circular(18) 
                      : const Radius.circular(4),
                  bottomRight: message['isMe'] 
                      ? const Radius.circular(4) 
>>>>>>> f8cdcc2 (commit pour le premier)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(message),
            ),
          ),
          if (message['isMe']) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFB662F),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  // Construire le contenu du message
  Widget _buildMessageContent(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'image':
        return _buildImageMessage(message);
      case 'voice':
        return _buildVoiceMessage(message);
      default:
        return Text(
          message['text'],
          style: TextStyle(
            color: message['isMe'] ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        );
    }
  }

  // Construire un message image
  Widget _buildImageMessage(Map<String, dynamic> message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(message['path']),
            width: 200,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message['text'],
          style: TextStyle(
            color: message['isMe'] ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Construire un message vocal
  Widget _buildVoiceMessage(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () => _playVoiceMessage(message['path']),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: message['isMe'] ? Colors.white : const Color(0xFFFB662F),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Message vocal',
            style: TextStyle(
              color: message['isMe'] ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Construire la zone de saisie de message
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFFFB662F)),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Tapez votre message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: _cancelRecording,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
<<<<<<< HEAD
                        color:
                            _isRecording ? Colors.red : const Color(0xFFFB662F),
=======
                        color: _isRecording ? Colors.red : const Color(0xFFFB662F),
>>>>>>> f8cdcc2 (commit pour le premier)
                        size: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFB662F)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  // Charger les messages depuis le backend
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _chatService.getMessages(
        producerId: widget.producerId,
        consumerId: widget.consumerId,
      );

      setState(() {
        _messages.addAll(messages);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Envoyer un message au backend
  Future<void> _sendMessageToBackend(String message,
      {String type = 'text'}) async {
    try {
      await _chatService.sendMessage(
        producerId: widget.producerId,
        consumerId: widget.consumerId,
        message: message,
        type: type,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'envoi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
=======
>>>>>>> f8cdcc2 (commit pour le premier)
}

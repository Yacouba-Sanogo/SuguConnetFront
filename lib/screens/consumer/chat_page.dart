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

  Timer? _refreshTimer; // Timer pour rafraîchir les messages automatiquement

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Démarrer le rafraîchissement automatique toutes les 3 secondes (comme WhatsApp)
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _typingTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Démarrer le rafraîchissement automatique des messages
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _refreshMessages();
      }
    });
  }

  // Rafraîchir les messages sans réinitialiser la liste complète
  Future<void> _refreshMessages() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null || userId <= 0 || widget.producerId <= 0) {
        return;
      }

      final messages = await _chatService.getMessages(
        userId1: userId,
        userId2: widget.producerId,
      );

      // Vérifier s'il y a de nouveaux messages
      final currentMessageIds = _messages.map((m) => m['id']).toSet();
      final newMessages = messages.where((msg) => 
        !currentMessageIds.contains(msg['id']?.toString())
      ).toList();

      if (newMessages.isNotEmpty) {
        // Traiter les nouveaux messages
        final processedNewMessages = await Future.wait(newMessages.map((msg) async {
          String? fullPath;
          if (msg['filePath'] != null) {
            fullPath = await _apiService.buildImageUrl(msg['filePath']);
          }

          return {
            'id': msg['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'text': msg['content'] ?? msg['contenu'] ?? '',
            'isMe': (msg['senderId'] ?? msg['expediteurId']) == userId,
            'time': _formatTimeString(msg['timestamp'] ?? msg['dateEnvoi']),
            'type': (msg['type'] ?? msg['typeMessage'] ?? 'TEXT').toString().toLowerCase(),
            'path': fullPath ?? msg['filePath'] ?? msg['cheminFichier'],
          };
        }).toList());

        if (mounted) {
          setState(() {
            _messages.addAll(processedNewMessages);
            // Trier par timestamp pour maintenir l'ordre chronologique
            _messages.sort((a, b) {
              final timeA = a['time'] ?? '00:00';
              final timeB = b['time'] ?? '00:00';
              return timeA.compareTo(timeB);
            });
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement pour ne pas perturber l'utilisateur
      print('Erreur lors du rafraîchissement: $e');
    }
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
        final filePath = msg['filePath'] ?? msg['cheminFichier'];
        if (filePath != null && filePath.toString().isNotEmpty) {
          fullPath = await _apiService.buildImageUrl(filePath.toString());
        }

        // Gérer différents formats de réponse (DTO ou Entity directe)
        final messageId = msg['id'] ?? msg['idMessage'];
        final content = msg['content'] ?? msg['contenu'] ?? '';
        final senderId = msg['senderId'] ?? msg['expediteurId'];
        final timestamp = msg['timestamp'] ?? msg['dateEnvoi'];
        final type = msg['type'] ?? msg['typeMessage'] ?? 'TEXT';

        return {
          'id': messageId?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'text': content,
          'isMe': senderId == userId,
          'time': _formatTimeString(timestamp?.toString()),
          'type': type.toString().toLowerCase(),
          'path': fullPath ?? filePath?.toString(), // Pour les fichiers/images
          'isRead': msg['isRead'] ?? msg['lu'] ?? false,
        };
      }).toList());

      // Trier les messages par timestamp pour garantir l'ordre chronologique
      processedMessages.sort((a, b) {
        final timeA = a['time'] ?? '00:00';
        final timeB = b['time'] ?? '00:00';
        return timeA.compareTo(timeB);
      });

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

  // Formater l'heure
  String _formatTimeString(String? timestamp) {
    if (timestamp == null) return '00:00';

    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  // Envoyer un message texte
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        // Utiliser l'ID de l'utilisateur connecté
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        // Afficher les IDs pour le débogage
        print('=== Débogage des IDs (envoi) ===');
        print('User ID: $userId');
        print('Producer ID: ${widget.producerId}');
        print('Message content: ${_messageController.text.trim()}');

        // Vérifier que l'utilisateur est connecté
        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        final message = await _chatService.sendMessage(
          senderId: userId,
          receiverId: widget.producerId,
          content: _messageController.text.trim(),
        );

        // Ajouter le message à la liste localement
        final messageContent = _messageController.text.trim();
        _messageController.clear();

        setState(() {
          _messages.add({
            'id': message['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'text': message['content'] ?? messageContent,
            'isMe': true,
            'time': _formatTimeString(message['timestamp'] ?? DateTime.now().toString()),
            'type': 'text',
            'isRead': false,
          });
        });

        // Recharger les messages pour obtenir la version complète du serveur
        await _refreshMessages();
        _scrollToBottom();
      } catch (e) {
        print('=== ERREUR D\'ENVOI DE MESSAGE ===');
        print('Erreur: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Démarre l'enregistrement vocal
  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        setState(() {
          _isRecording = true;
        });
        HapticFeedback.mediumImpact();

        // TODO: Implémenter l'enregistrement audio réel
        _recordingPath =
            '/tmp/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

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

  // Arrête l'enregistrement vocal
  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
      });
      HapticFeedback.mediumImpact();

      if (_recordingPath != null) {
        // Utiliser l'ID de l'utilisateur connecté
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        // Vérifier que l'utilisateur est connecté
        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        // Envoyer le message vocal
        final File audioFile = File(_recordingPath!);
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
            'type': 'voice',
            'path': _recordingPath,
          });
        });

        _scrollToBottom();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Message vocal envoyé'),
            backgroundColor: Color(0xFFFB662F),
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

  // Annule l'enregistrement vocal
  void _cancelRecording() {
    setState(() {
      _isRecording = false;
      _recordingPath = null;
    });
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Enregistrement annulé'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // Sélectionner une image
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        // Utiliser l'ID de l'utilisateur connecté
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        // Vérifier que l'utilisateur est connecté
        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        // Envoyer l'image
        final File imageFile = File(image.path);
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
            'type': 'image',
            'path': image.path,
          });
        });

        _scrollToBottom();
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

  // Sélectionner un fichier
  Future<void> _pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        // Utiliser l'ID de l'utilisateur connecté
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id;

        // Vérifier que l'utilisateur est connecté
        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        // Envoyer le fichier
        final File selectedFile = File(file.path);
        final message = await _chatService.sendFile(
          senderId: userId,
          receiverId: widget.producerId,
          file: selectedFile,
        );

        setState(() {
          _messages.add({
            'id': message['id'].toString(),
            'text': message['content'],
            'isMe': true,
            'time': _formatTimeString(message['timestamp']),
            'type': 'file',
            'path': file.path,
          });
        });

        _scrollToBottom();
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
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFFB662F)),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.insert_drive_file, color: Color(0xFFFB662F)),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMessagesList(),
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun message pour le moment',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Soyez le premier à envoyer un message !',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

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
        mainAxisAlignment:
            message['isMe'] ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                color: message['isMe']
                    ? const Color(0xFFFB662F).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message['isMe']
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: message['isMe']
                      ? const Radius.circular(4)
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
      case 'file':
        return _buildFileMessage(message);
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
    // Vérifier si le chemin est un fichier local ou une URL
    if (message['path'] != null &&
        (message['path'].startsWith('http://') ||
            message['path'].startsWith('https://'))) {
      // C'est une URL distante
      print('Chargement de l\'image depuis URL: ${message['path']}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message['path'],
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Erreur de chargement de l\'image: $error');
                print('URL de l\'image: ${message['path']}');
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 50, color: Colors.grey),
                );
              },
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
    } else {
      // C'est un fichier local
      print('Chargement de l\'image depuis fichier local: ${message['path']}');
      if (message['path'] == null || message['path'] == '') {
        return Container(
          width: 200,
          height: 150,
          color: Colors.grey[200],
          child: const Icon(Icons.image, size: 50, color: Colors.grey),
        );
      }

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
              errorBuilder: (context, error, stackTrace) {
                print('Erreur de chargement de l\'image locale: $error');
                print('Chemin du fichier: ${message['path']}');
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 50, color: Colors.grey),
                );
              },
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

  // Construire un message fichier
  Widget _buildFileMessage(Map<String, dynamic> message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.insert_drive_file,
          color: message['isMe'] ? Colors.white : const Color(0xFFFB662F),
          size: 24,
        ),
        const SizedBox(width: 8),
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

  // Jouer un message vocal
  Future<void> _playVoiceMessage(String? path) async {
    if (path == null) return;

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
                      onChanged: (text) {
                        // TODO: Implémenter l'indicateur de saisie
                      },
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
                        color:
                            _isRecording ? Colors.red : const Color(0xFFFB662F),
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
}

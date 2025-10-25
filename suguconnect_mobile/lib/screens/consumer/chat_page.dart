import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart'; // Temporairement désactivé
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

// Page de chat individuel avec un producteur
class ChatPage extends StatefulWidget {
  final String producerName;
  final String producerAvatar;
  final bool isOnline;

  const ChatPage({
    super.key,
    required this.producerName,
    required this.producerAvatar,
    required this.isOnline,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  // Variables pour l'enregistrement audio (simplifié)
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordingPath;

  // Messages de la conversation
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Salut tout le monde, comment allez-vous?',
      'isMe': false,
      'time': '10:13',
      'type': 'text',
    },
    {
      'id': '2',
      'text': 'Salut Fatoumata. je vais bien. merci! Et toi ?',
      'isMe': true,
      'time': '12:40',
      'type': 'text',
    },
    {
      'id': '3',
      'text': 'Je voulais te parler d\'une dépense qu\'on pourrait partager ensemble.',
      'isMe': false,
      'time': '10:13',
      'type': 'text',
    },
    {
      'id': '4',
      'text': 'Salut Fatoumata. je vais bien. merci! Et toi ?',
      'isMe': true,
      'time': '12:40',
      'type': 'text',
    },
  ];

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

  // Construit la barre d'application
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
            child: widget.producerAvatar == null
                ? const Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.producerName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.isOnline ? 'En ligne' : 'Hors ligne',
                  style: TextStyle(
                    color: widget.isOnline ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.black54),
          onPressed: () {
            // Fonctionnalité d'appel vidéo
            _showComingSoonDialog('Appel vidéo');
          },
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.black54),
          onPressed: () {
            // Fonctionnalité d'appel vocal
            _showComingSoonDialog('Appel vocal');
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          onSelected: (value) {
            switch (value) {
              case 'info':
                _showContactInfo();
                break;
              case 'block':
                _showBlockDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Text('Informations du contact'),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Text('Bloquer'),
            ),
          ],
        ),
      ],
    );
  }

  // Construit la liste des messages
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

  // Construit une bulle de message
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message['isMe'] 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message['isMe']) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.producerAvatar),
              child: widget.producerAvatar == null
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                  : null,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenu du message selon le type
                  if (message['type'] == 'image')
                    _buildImageMessage(message)
                  else if (message['type'] == 'video')
                    _buildVideoMessage(message)
                  else if (message['type'] == 'voice')
                    _buildVoiceMessage(message)
                  else if (message['type'] == 'location')
                    _buildLocationMessage(message)
                  else
                    Text(
                      message['text'],
                      style: TextStyle(
                        color: message['isMe'] ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        message['time'],
                        style: TextStyle(
                          color: message['isMe'] 
                              ? Colors.white.withOpacity(0.7) 
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (message['type'] == 'voice' && message['duration'] != null)
                        Text(
                          message['duration'],
                          style: TextStyle(
                            color: message['isMe'] 
                                ? Colors.white.withOpacity(0.7) 
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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

  // Construit la zone de saisie de message
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
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () {
              _showAttachmentOptions();
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'texte...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTapDown: (_) => _startRecording(),
            onTapUp: (_) => _stopRecording(),
            onTapCancel: () => _cancelRecording(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : const Color(0xFFFB662F),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFFB662F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Envoie un message
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
    }
  }

  // Démarre l'enregistrement vocal
  Future<void> _startRecording() async {
    try {
      // Demander la permission microphone
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        if (await _audioRecorder.hasPermission()) {
          setState(() {
            _isRecording = true;
          });
          HapticFeedback.mediumImpact();
          
          // Démarrer l'enregistrement
          await _audioRecorder.start(const RecordConfig(), path: '/tmp/audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
          
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
          content: Text('Erreur d\'enregistrement: $e'),
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
      
      // Arrêter l'enregistrement et récupérer le chemin
      _recordingPath = await _audioRecorder.stop();
      
      if (_recordingPath != null) {
        // Ajouter le message vocal à la liste
        _addVoiceMessage(_recordingPath!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Enregistrement terminé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'arrêt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Annule l'enregistrement vocal
  Future<void> _cancelRecording() async {
    try {
      setState(() {
        _isRecording = false;
      });
      
      // Arrêter l'enregistrement sans sauvegarder
      await _audioRecorder.stop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrement annulé'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  // Ajoute un message vocal à la conversation
  void _addVoiceMessage(String audioPath) {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': '🎤 Message vocal',
        'isMe': true,
        'time': _formatTime(DateTime.now()),
        'type': 'voice',
        'audioPath': audioPath,
        'duration': '0:15', // Durée simulée
      });
    });
    _scrollToBottom();
  }

  // Affiche les options d'attachement
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
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFB662F)),
              title: const Text('Galerie photos'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFFFB662F)),
              title: const Text('Prendre une vidéo'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo('camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Color(0xFFFB662F)),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFFFB662F)),
              title: const Text('Localisation'),
              onTap: () {
                Navigator.pop(context);
                _sendLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Affiche les informations du contact
  void _showContactInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informations - ${widget.producerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(widget.producerAvatar),
              child: widget.producerAvatar == null
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              widget.producerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isOnline ? 'En ligne' : 'Hors ligne',
              style: TextStyle(
                color: widget.isOnline ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Affiche le dialogue de blocage
  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquer le contact'),
        content: Text('Êtes-vous sûr de vouloir bloquer ${widget.producerName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog('Contact bloqué');
            },
            child: const Text('Bloquer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Sélectionne une image
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Demander la permission caméra si nécessaire
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission caméra refusée'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        // Ajouter le message d'image
        setState(() {
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': '📸 Photo',
            'isMe': true,
            'time': _formatTime(DateTime.now()),
            'type': 'image',
            'imagePath': image.path,
          });
        });
        _scrollToBottom();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Image ajoutée'),
            backgroundColor: Color(0xFFFB662F),
          ),
        );
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

  // Sélectionne une vidéo
  Future<void> _pickVideo(String source) async {
    try {
      // Simuler la sélection de vidéo
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'Vidéo envoyée',
          'isMe': true,
          'time': _formatTime(DateTime.now()),
          'type': 'video',
          'videoPath': null,
        });
      });
      _scrollToBottom();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vidéo envoyée avec succès'),
          backgroundColor: Color(0xFFFB662F),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Sélectionne un document
  Future<void> _pickDocument() async {
    try {
      // Ici vous pouvez implémenter la sélection de documents
      // Pour l'instant, on simule avec un message
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'Document envoyé',
          'isMe': true,
          'time': _formatTime(DateTime.now()),
          'type': 'document',
        });
      });
      _scrollToBottom();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document envoyé avec succès'),
          backgroundColor: Color(0xFFFB662F),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Envoie la localisation
  void _sendLocation() {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': '📍 Localisation partagée',
        'isMe': true,
        'time': _formatTime(DateTime.now()),
        'type': 'location',
      });
    });
    _scrollToBottom();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Localisation partagée'),
        backgroundColor: Color(0xFFFB662F),
      ),
    );
  }

  // Construit un message image
  Widget _buildImageMessage(Map<String, dynamic> message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: message['imagePath'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(message['imagePath']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 50, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.image, size: 50, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          message['text'],
          style: TextStyle(
            color: message['isMe'] ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Construit un message vidéo
  Widget _buildVideoMessage(Map<String, dynamic> message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_circle_filled, size: 50, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          message['text'],
          style: TextStyle(
            color: message['isMe'] ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Construit un message vocal
  Widget _buildVoiceMessage(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () => _playVoiceMessage(message),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: message['isMe'] ? Colors.white : Colors.black,
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
          if (message['duration'] != null) ...[
            const SizedBox(width: 8),
            Text(
              message['duration'],
              style: TextStyle(
                color: message['isMe'] ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Joue un message vocal
  Future<void> _playVoiceMessage(Map<String, dynamic> message) async {
    try {
      if (message['audioPath'] != null) {
        await _audioPlayer.play(DeviceFileSource(message['audioPath']));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎵 Lecture du message vocal'),
            backgroundColor: Color(0xFFFB662F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fichier audio non disponible'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de lecture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Construit un message de localisation
  Widget _buildLocationMessage(Map<String, dynamic> message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          color: message['isMe'] ? Colors.white : Colors.red,
          size: 20,
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

  // Affiche un message "Fonctionnalité à venir"
  void _showComingSoonDialog(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fonctionnalité à venir'),
        backgroundColor: const Color(0xFFFB662F),
      ),
    );
  }

  // Formate l'heure
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Fait défiler vers le bas
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

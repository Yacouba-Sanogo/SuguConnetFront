import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'package:suguconnect_mobile/services/chat_service.dart';

class ChatPageSimple extends StatefulWidget {
  final String producerName;
  final String producerAvatar;
  final int producerId;
  final int consumerId;

  const ChatPageSimple({
    super.key,
    required this.producerName,
    required this.producerAvatar,
    required this.producerId,
    required this.consumerId,
  });

  @override
  State<ChatPageSimple> createState() => _ChatPageSimpleState();
}

class _ChatPageSimpleState extends State<ChatPageSimple> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ChatService _chatService = ChatService();

  bool _isRecording = false;
  String? _recordingPath;
  bool _isLoading = false;

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
    super.dispose();
  }

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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // -----------------------------
  // ENVOI TEXTE
  // -----------------------------
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': message,
        'isMe': true,
        'time': _formatTime(DateTime.now()),
        'type': 'text',
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Envoi backend
    _sendMessageToBackend(message, type: "text");
  }

  // -----------------------------
  // ENREGISTREMENT VOIX
  // -----------------------------
  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission microphone refusée'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isRecording = true);
    HapticFeedback.mediumImpact();

    _recordingPath = '/tmp/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Enregistrement en cours...'),
        backgroundColor: Color(0xFFFB662F),
      ),
    );
  }

  Future<void> _stopRecording() async {
    if (_recordingPath == null) return;
    setState(() => _isRecording = false);
    HapticFeedback.mediumImpact();

    _addVoiceMessage(_recordingPath!);

    _sendMessageToBackend(_recordingPath!, type: 'voice');
  }

  void _cancelRecording() {
    setState(() {
      _isRecording = false;
      _recordingPath = null;
    });
  }

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

  Future<void> _playVoiceMessage(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
  }

  // -----------------------------
  // IMAGE
  // -----------------------------
  Future<void> _pickImage(String source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );

    if (img != null) {
      _addImageMessage(img.path);

      _sendMessageToBackend(img.path, type: 'image');
    }
  }

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
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
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
            leading: const Icon(Icons.photo_library, color: Color(0xFFFB662F)),
            title: const Text('Galerie'),
            onTap: () {
              Navigator.pop(context);
              _pickImage('gallery');
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // UI PRINCIPALE
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/icons/arrièreplandiscussion.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Expanded(child: _buildMessagesList()),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(widget.producerAvatar)),
          const SizedBox(width: 10),
          Text(widget.producerName),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildMessageBubble(_messages[i]),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFB662F) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _buildMessageContent(message),
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'voice':
        return GestureDetector(
          onTap: () => _playVoiceMessage(message['path']),
          child: const Icon(Icons.play_arrow, color: Colors.white),
        );

      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(message['path']), width: 150, fit: BoxFit.cover),
        );

      default:
        return Text(
          message['text'],
          style: TextStyle(
            color: message['isMe'] ? Colors.white : Colors.black,
          ),
        );
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFFFB662F)),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Message',
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: const Color(0xFFFB662F)),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFFB662F)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 🔥 APPELS BACKEND CORRIGÉS
  // -----------------------------
  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final data = await _chatService.getMessages(
        userId1: widget.consumerId,
        userId2: widget.producerId,
      );

      setState(() => _messages.addAll(data));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessageToBackend(String message, {String type = 'text'}) async {
    try {
      await _chatService.sendMessage(
        senderId: widget.consumerId,
        receiverId: widget.producerId,
        content: message,
        // messageType: type,
      );
    } catch (e) {
      debugPrint("Erreur lors de l'envoi du message : $e");
    }
  }
}

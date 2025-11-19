import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class DebugUsersPage extends StatefulWidget {
  const DebugUsersPage({super.key});

  @override
  State<DebugUsersPage> createState() => _DebugUsersPageState();
}

class _DebugUsersPageState extends State<DebugUsersPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<dynamic> _consumers = [];
  List<dynamic> _producers = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Vérifier l'authentification
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      // Récupérer les consommateurs
      final consumers = await _apiService.getConsumers();
      print('Consommateurs récupérés: ${consumers.length}');
      for (var consumer in consumers) {
        print(
            'Consommateur ID: ${consumer['id']}, Nom: ${consumer['nom']} ${consumer['prenom']}');
      }

      // Récupérer les producteurs
      final producers = await _apiService.getProducers();
      print('Producteurs récupérés: ${producers.length}');
      for (var producer in producers) {
        print(
            'Producteur ID: ${producer['id']}, Nom: ${producer['nom']} ${producer['prenom']}');
      }

      setState(() {
        _consumers = consumers;
        _producers = producers;
      });
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
      setState(() {
        _error = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Débogage des Utilisateurs'),
        backgroundColor: const Color(0xFFFB662F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/arrièreplandiscussion.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Liste des Utilisateurs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_error.isNotEmpty) const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadUsers,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB662F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const TabBar(
                            labelColor: Color(0xFFFB662F),
                            unselectedLabelColor: Colors.grey,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                              color: Colors.white,
                            ),
                            tabs: [
                              Tab(text: 'Consommateurs'),
                              Tab(text: 'Producteurs'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildUsersList(_consumers, 'Consommateur'),
                              _buildUsersList(_producers, 'Producteur'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(List<dynamic> users, String userType) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'Aucun $userType trouvé',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              '${user['nom'] ?? ''} ${user['prenom'] ?? ''}'.trim(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${user['id']}'),
                Text('Téléphone: ${user['telephone'] ?? 'Non spécifié'}'),
                if (user['email'] != null) Text('Email: ${user['email']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFB662F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFB662F)),
              ),
              child: Text(
                userType,
                style: const TextStyle(
                  color: Color(0xFFFB662F),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

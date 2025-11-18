import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String adresse;
  final String role;
  final bool actif;
  final DateTime dateCreation;
  final DateTime? dateDerniereConnexion;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.role,
    required this.actif,
    required this.dateCreation,
    this.dateDerniereConnexion,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$prenom $nom';
}

@JsonSerializable()
class Producteur extends User {
  final String nomEntreprise;
  final String description;
  final String specialite;
  final String? siteWeb;
  final String? coordonneesGPS;
  final bool certifieBio;
  final double noteMoyenne;
  final int nombreEvaluations;

  Producteur({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.email,
    required super.telephone,
    required super.adresse,
    required super.role,
    required super.actif,
    required super.dateCreation,
    super.dateDerniereConnexion,
    required this.nomEntreprise,
    required this.description,
    required this.specialite,
    this.siteWeb,
    this.coordonneesGPS,
    required this.certifieBio,
    required this.noteMoyenne,
    required this.nombreEvaluations,
  });

  factory Producteur.fromJson(Map<String, dynamic> json) => _$ProducteurFromJson(json);
  Map<String, dynamic> toJson() => _$ProducteurToJson(this);
}

@JsonSerializable()
class Consommateur extends User {
  final String? preferences;
  final String? allergies;
  final bool notificationsActives;

  Consommateur({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.email,
    required super.telephone,
    required super.adresse,
    required super.role,
    required super.actif,
    required super.dateCreation,
    super.dateDerniereConnexion,
    this.preferences,
    this.allergies,
    required this.notificationsActives,
  });

  factory Consommateur.fromJson(Map<String, dynamic> json) => _$ConsommateurFromJson(json);
  Map<String, dynamic> toJson() => _$ConsommateurToJson(this);
}

@JsonSerializable()
class Admin extends User {
  final String? departement;
  final String? fonction;

  Admin({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.email,
    required super.telephone,
    required super.adresse,
    required super.role,
    required super.actif,
    required super.dateCreation,
    super.dateDerniereConnexion,
    this.departement,
    this.fonction,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  Map<String, dynamic> toJson() => _$AdminToJson(this);
}

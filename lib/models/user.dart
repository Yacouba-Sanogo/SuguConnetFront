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
class Producteur {
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
  final String nomEntreprise;
  final String description;
  final String specialite;
  final String? siteWeb;
  final String? coordonneesGPS;
  final bool certifieBio;
  final double noteMoyenne;
  final int nombreEvaluations;

  Producteur({
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
    required this.nomEntreprise,
    required this.description,
    required this.specialite,
    this.siteWeb,
    this.coordonneesGPS,
    required this.certifieBio,
    required this.noteMoyenne,
    required this.nombreEvaluations,
  });

  factory Producteur.fromJson(Map<String, dynamic> json) =>
      _$ProducteurFromJson(json);
  Map<String, dynamic> toJson() => _$ProducteurToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none)
class Consommateur {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: '')
  final String nom;

  @JsonKey(defaultValue: '')
  final String prenom;

  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: '')
  final String telephone;

  @JsonKey(defaultValue: '')
  final String role;

  @JsonKey(defaultValue: false)
  final bool actif;

  @JsonKey(name: 'dateCreation')
  final DateTime? dateCreation;

  final DateTime? dateDerniereConnexion;

  @JsonKey(defaultValue: '')
  final String localisation;

  @JsonKey(defaultValue: 0.0)
  final double longitude;

  @JsonKey(defaultValue: 0.0)
  final double latitude;

  @JsonKey(defaultValue: '')
  final String preferences;

  final String? allergies;

  @JsonKey(defaultValue: true)
  final bool notificationsActives;

  @JsonKey(defaultValue: 0)
  final int nombreEvaluations;

  Consommateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    required this.actif,
    this.dateCreation,
    this.dateDerniereConnexion,
    required this.localisation,
    required this.longitude,
    required this.latitude,
    required this.preferences,
    this.allergies,
    required this.notificationsActives,
    required this.nombreEvaluations,
  });

  factory Consommateur.fromJson(Map<String, dynamic> json) =>
      _$ConsommateurFromJson(json);
  Map<String, dynamic> toJson() => _$ConsommateurToJson(this);

  String get nomComplet => '$prenom $nom';
  bool get estActif => actif;
}

@JsonSerializable()
class Admin {
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
  final String? departement;
  final String? fonction;

  Admin({
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
    this.departement,
    this.fonction,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  Map<String, dynamic> toJson() => _$AdminToJson(this);
}

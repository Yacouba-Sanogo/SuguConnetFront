// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      adresse: json['adresse'] as String,
      role: json['role'] as String,
      actif: json['actif'] as bool,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateDerniereConnexion: json['dateDerniereConnexion'] == null
          ? null
          : DateTime.parse(json['dateDerniereConnexion'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'telephone': instance.telephone,
      'adresse': instance.adresse,
      'role': instance.role,
      'actif': instance.actif,
      'dateCreation': instance.dateCreation.toIso8601String(),
      'dateDerniereConnexion':
          instance.dateDerniereConnexion?.toIso8601String(),
    };

Producteur _$ProducteurFromJson(Map<String, dynamic> json) => Producteur(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      adresse: json['adresse'] as String,
      role: json['role'] as String,
      actif: json['actif'] as bool,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateDerniereConnexion: json['dateDerniereConnexion'] == null
          ? null
          : DateTime.parse(json['dateDerniereConnexion'] as String),
      nomEntreprise: json['nomEntreprise'] as String,
      description: json['description'] as String,
      specialite: json['specialite'] as String,
      siteWeb: json['siteWeb'] as String?,
      coordonneesGPS: json['coordonneesGPS'] as String?,
      certifieBio: json['certifieBio'] as bool,
      noteMoyenne: (json['noteMoyenne'] as num).toDouble(),
      nombreEvaluations: (json['nombreEvaluations'] as num).toInt(),
    );

Map<String, dynamic> _$ProducteurToJson(Producteur instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'telephone': instance.telephone,
      'adresse': instance.adresse,
      'role': instance.role,
      'actif': instance.actif,
      'dateCreation': instance.dateCreation.toIso8601String(),
      'dateDerniereConnexion':
          instance.dateDerniereConnexion?.toIso8601String(),
      'nomEntreprise': instance.nomEntreprise,
      'description': instance.description,
      'specialite': instance.specialite,
      'siteWeb': instance.siteWeb,
      'coordonneesGPS': instance.coordonneesGPS,
      'certifieBio': instance.certifieBio,
      'noteMoyenne': instance.noteMoyenne,
      'nombreEvaluations': instance.nombreEvaluations,
    };

Consommateur _$ConsommateurFromJson(Map<String, dynamic> json) => Consommateur(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      actif: json['actif'] as bool? ?? false,
      dateCreation: json['dateCreation'] == null
          ? null
          : DateTime.parse(json['dateCreation'] as String),
      dateDerniereConnexion: json['dateDerniereConnexion'] == null
          ? null
          : DateTime.parse(json['dateDerniereConnexion'] as String),
      localisation: json['localisation'] as String? ?? '',
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      preferences: json['preferences'] as String? ?? '',
      allergies: json['allergies'] as String?,
      notificationsActives: json['notificationsActives'] as bool? ?? true,
      nombreEvaluations: (json['nombreEvaluations'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ConsommateurToJson(Consommateur instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'telephone': instance.telephone,
      'role': instance.role,
      'actif': instance.actif,
      'dateCreation': instance.dateCreation?.toIso8601String(),
      'dateDerniereConnexion':
          instance.dateDerniereConnexion?.toIso8601String(),
      'localisation': instance.localisation,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'preferences': instance.preferences,
      'allergies': instance.allergies,
      'notificationsActives': instance.notificationsActives,
      'nombreEvaluations': instance.nombreEvaluations,
    };

Admin _$AdminFromJson(Map<String, dynamic> json) => Admin(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      adresse: json['adresse'] as String,
      role: json['role'] as String,
      actif: json['actif'] as bool,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateDerniereConnexion: json['dateDerniereConnexion'] == null
          ? null
          : DateTime.parse(json['dateDerniereConnexion'] as String),
      departement: json['departement'] as String?,
      fonction: json['fonction'] as String?,
    );

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'telephone': instance.telephone,
      'adresse': instance.adresse,
      'role': instance.role,
      'actif': instance.actif,
      'dateCreation': instance.dateCreation.toIso8601String(),
      'dateDerniereConnexion':
          instance.dateDerniereConnexion?.toIso8601String(),
      'departement': instance.departement,
      'fonction': instance.fonction,
    };

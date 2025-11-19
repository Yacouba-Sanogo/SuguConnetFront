// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

JwtResponse _$JwtResponseFromJson(Map<String, dynamic> json) => JwtResponse(
  token: json['token'] as String,
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$JwtResponseToJson(JwtResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'roles': instance.roles,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      telephone: json['telephone'] as String,
      adresse: json['adresse'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'password': instance.password,
      'telephone': instance.telephone,
      'adresse': instance.adresse,
    };

ProducteurRegisterRequest _$ProducteurRegisterRequestFromJson(
  Map<String, dynamic> json,
) => ProducteurRegisterRequest(
  nom: json['nom'] as String,
  prenom: json['prenom'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  telephone: json['telephone'] as String,
  adresse: json['adresse'] as String,
  nomEntreprise: json['nomEntreprise'] as String,
  description: json['description'] as String,
  specialite: json['specialite'] as String,
  siteWeb: json['siteWeb'] as String?,
  coordonneesGPS: json['coordonneesGPS'] as String?,
  certifieBio: json['certifieBio'] as bool,
);

Map<String, dynamic> _$ProducteurRegisterRequestToJson(
  ProducteurRegisterRequest instance,
) => <String, dynamic>{
  'nom': instance.nom,
  'prenom': instance.prenom,
  'email': instance.email,
  'password': instance.password,
  'telephone': instance.telephone,
  'adresse': instance.adresse,
  'nomEntreprise': instance.nomEntreprise,
  'description': instance.description,
  'specialite': instance.specialite,
  'siteWeb': instance.siteWeb,
  'coordonneesGPS': instance.coordonneesGPS,
  'certifieBio': instance.certifieBio,
};

ConsommateurRegisterRequest _$ConsommateurRegisterRequestFromJson(
  Map<String, dynamic> json,
) => ConsommateurRegisterRequest(
  nom: json['nom'] as String,
  prenom: json['prenom'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  telephone: json['telephone'] as String,
  adresse: json['adresse'] as String,
  preferences: json['preferences'] as String?,
  allergies: json['allergies'] as String?,
  notificationsActives: json['notificationsActives'] as bool,
);

Map<String, dynamic> _$ConsommateurRegisterRequestToJson(
  ConsommateurRegisterRequest instance,
) => <String, dynamic>{
  'nom': instance.nom,
  'prenom': instance.prenom,
  'email': instance.email,
  'password': instance.password,
  'telephone': instance.telephone,
  'adresse': instance.adresse,
  'preferences': instance.preferences,
  'allergies': instance.allergies,
  'notificationsActives': instance.notificationsActives,
};

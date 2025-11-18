import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class JwtResponse {
  final String token;
  final int id;
  final String username;
  final String email;
  final List<String> roles;

  JwtResponse({
    required this.token,
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) => _$JwtResponseFromJson(json);
  Map<String, dynamic> toJson() => _$JwtResponseToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String telephone;
  final String adresse;

  RegisterRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.telephone,
    required this.adresse,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class ProducteurRegisterRequest extends RegisterRequest {
  final String nomEntreprise;
  final String description;
  final String specialite;
  final String? siteWeb;
  final String? coordonneesGPS;
  final bool certifieBio;

  ProducteurRegisterRequest({
    required super.nom,
    required super.prenom,
    required super.email,
    required super.password,
    required super.telephone,
    required super.adresse,
    required this.nomEntreprise,
    required this.description,
    required this.specialite,
    this.siteWeb,
    this.coordonneesGPS,
    required this.certifieBio,
  });

  factory ProducteurRegisterRequest.fromJson(Map<String, dynamic> json) => _$ProducteurRegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ProducteurRegisterRequestToJson(this);
}

@JsonSerializable()
class ConsommateurRegisterRequest extends RegisterRequest {
  final String? preferences;
  final String? allergies;
  final bool notificationsActives;

  ConsommateurRegisterRequest({
    required super.nom,
    required super.prenom,
    required super.email,
    required super.password,
    required super.telephone,
    required super.adresse,
    this.preferences,
    this.allergies,
    required this.notificationsActives,
  });

  factory ConsommateurRegisterRequest.fromJson(Map<String, dynamic> json) => _$ConsommateurRegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ConsommateurRegisterRequestToJson(this);
}

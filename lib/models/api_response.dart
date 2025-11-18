import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
      'error': error,
    };
  }
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int size;
  final bool first;
  final bool last;

  PaginatedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.size,
    required this.first,
    required this.last,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return PaginatedResponse<T>(
      content: (json['content'] as List).map((item) => fromJsonT(item)).toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['number'] as int,
      size: json['size'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
    );
  }
}

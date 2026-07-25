import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_token_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<AuthTokenModel> register(String pubkey);
  Future<void> revoke(String token);
}

@Injectable(as: AuthRemoteDatasource)
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client _client;
  final String _baseUrl;

  AuthRemoteDatasourceImpl({
    required this._client,
    @Named('apiBaseUrl') required this._baseUrl,
  });

  @override
  Future<AuthTokenModel> register(String pubkey) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pubkey': pubkey}),
    );

    if (response.statusCode == 201) {
      return AuthTokenModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw AuthException('Registration failed: ${response.body}');
  }

  @override
  Future<void> revoke(String token) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/auth/revoke'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw AuthException('Revoke failed: ${response.body}');
    }
  }
}

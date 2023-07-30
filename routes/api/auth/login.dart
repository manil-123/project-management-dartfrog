import 'dart:html';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../services/database_service.dart';
import '../../../utils/encrypt_data.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    login(context),
  );
}

Future<Response> login(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'message': 'Method not allowed',
      },
    );
  }

  final contentType = context.request.headers['content-type'];
  if (contentType != 'application/json') {
    return Response.json(
      statusCode: 400,
      body: {
        'message': 'Invalid content type',
      },
    );
  }

  final body = await context.request.json();
  final username = body['username'];
  final password = body['password'];

  if (username == null || password == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'All fields are required',
      },
    );
  }

  final user = await DatabaseService.usersCollection.findOne(
    where.eq(
      'username',
      username,
    ),
  );

  if (user == null) {
    return Response.json(
      statusCode: 401,
      body: {
        'success': false,
        'message': 'Wrong Credentials!',
      },
    );
  }

  final isPasswordValid = verifyPassword(
    password,
    user['password'],
  );
  if (!isPasswordValid) {
    return Response.json(
      statusCode: 401,
      body: {
        'success': false,
        'message': 'Wrong Credentials!',
      },
    );
  }
  user.remove('_id');
  user.remove('password');
  return Response.json(
    statusCode: 200,
    body: {
      'success': true,
      'data': user,
      'message': 'Login successful',
    },
  );
}

bool verifyPassword(String inputPassword, String storedPassword) {
  final decryptedPassword = EncryptData.decryptAES(storedPassword);
  return decryptedPassword == inputPassword;
}

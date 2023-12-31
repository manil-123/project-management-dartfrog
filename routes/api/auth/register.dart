import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/user/user_model.dart';
import '../../../services/database_service.dart';
import '../../../utils/encrypt_data.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    registerUser(context),
  );
}

Future<Response> registerUser(RequestContext context) async {
  //check if the request is a POST request
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'message': 'Method not allowed',
      },
    );
  }

  //check if body is present
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
  try {
    final findExistingUser = await DatabaseService.usersCollection.findOne(
      where.eq(
        'username',
        username,
      ),
    );
    print(findExistingUser);
    if (findExistingUser != null) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'User already exists with the provided username',
        },
      );
    }
    final encryptedPassword = EncryptData.encryptAES(
      body['password'],
    );
    final user = UserModel.fromJson({
      'user_id': ObjectId().toHexString(),
      'username': body['username'],
      'password': encryptedPassword,
      'profilePic': '',
      'isAdmin': false
    });
    await DatabaseService.usersCollection.insert(
      user.toJson(),
    );
    final returnUser = user.toJson();
    returnUser.remove('password');
    return Response.json(
      statusCode: 201,
      body: {
        'success': true,
        'data': returnUser,
        'message': 'User created successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'message': 'Internal Server Error',
      },
    );
  }
}

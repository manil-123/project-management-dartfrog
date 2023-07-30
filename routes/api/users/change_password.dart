import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/user/user_model.dart';
import '../../../services/database_service.dart';
import '../../../utils/encrypt_data.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    changePassword(context),
  );
}

Future<Response> changePassword(RequestContext context) async {
  //check if the request is a PUT request
  if (context.request.method != HttpMethod.put) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'message': 'Method not allowed',
      },
    );
  }

  // Get user id through params
  final params = context.request.uri.queryParameters;
  //check if user has passed id params.
  if (!params.containsKey('id')) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'User id is required',
      },
    );
  }
  final userId = params['id'];
  //check if body is present
  final body = await context.request.json();
  final oldPassword = body['old_password'];
  final newPassword = body['new_password'];
  if (oldPassword == null || newPassword == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'All fields are required',
      },
    );
  }
  try {
    final doc = await DatabaseService.usersCollection.findOne(
      where.eq('user_id', userId),
    );
    if (doc == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'User not found',
        },
      );
    }
    final user = UserModel.fromJson(doc);
    final decryptedPassword = EncryptData.decryptAES(
      user.password,
    );
    if (decryptedPassword != oldPassword) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Old password does not match',
        },
      );
    }
    final encryptedPassword = EncryptData.encryptAES(
      body['new_password'],
    );
    final updatedUser = user.copyWith(password: encryptedPassword);
    await DatabaseService.usersCollection.update(
      where.eq(
        'user_id',
        userId,
      ),
      updatedUser.toJson(),
    );
    final returnUser = updatedUser.toJson();
    returnUser.remove('password');
    return Response.json(
      statusCode: 200,
      body: {
        'success': true,
        'data': returnUser,
        'message': 'Password updated successfully',
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

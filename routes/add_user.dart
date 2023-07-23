import 'dart:developer';

import 'package:dart_frog/dart_frog.dart';

import '../models/user/user_model.dart';
import '../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(context, addUser(context));
}

Future<Response> addUser(RequestContext context) async {
  //check if the request is a POST request
  if (context.request.method == HttpMethod.post) {
    //check if headers is application/json
    final contentType = context.request.headers['content-type'];
    if (contentType == 'application/json') {
      //check if body is present
      final body = await context.request.json();
      if (body['userName'] != null && body['isAdmin'] != null) {
        try {
          final user = UserModel.fromJson({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'userName': body['userName'],
            'isAdmin': body['isAdmin'],
          });
          await DatabaseService.usersCollection.insert(user.toJson());
          return Response.json(
            statusCode: 201,
            body: {'message': 'User created successfully with id: ${user.id}'},
          );
        } catch (e) {
          return Response.json(
            statusCode: 500,
            body: {'message': 'Internal Server Error'},
          );
        }
      } else {
        return Response.json(
          statusCode: 404,
          body: {'message': 'All fields are required'},
        );
      }
    }

    return Response.json(
      statusCode: 404,
      body: {'message': contentType},
    );
  }
  return Response.json(
    statusCode: 404,
    body: {'message': 'Method not allowed'},
  );
}

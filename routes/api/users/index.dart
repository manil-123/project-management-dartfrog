import 'dart:html';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/user/user_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    getUsers(context),
  );
}

Future<Response> getUsers(RequestContext context) async {
  //check if the request is a GET request
  if (context.request.method == HttpMethod.get) {
    //check if user_id is present
    final params = context.request.uri.queryParameters;
    if (!params.containsKey('id')) {
      final docs = await DatabaseService.usersCollection.find().toList();
      final usersList = docs.map(UserModel.fromJson).toList();
      return Response.json(
        body: {
          'success': true,
          'data': usersList,
          'message': 'Users fetched successfully',
        },
      );
    }
    //return user with the id
    final id = params['id'];
    try {
      final doc = await DatabaseService.usersCollection.findOne(
        where.eq('id', id),
      );
      if (doc != null && doc.isNotEmpty) {
        final user = UserModel.fromJson(doc);
        return Response.json(
          body: {
            'success': true,
            'data': user,
            'message': 'User fetched successfully',
          },
        );
      }
    } catch (e) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'User not found',
        },
      );
    }
  }
  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {
      'message': 'Method not allowed',
    },
  );
}

import 'package:dart_frog/dart_frog.dart';
import '../models/user/user_model.dart';
import '../services/database_service.dart';
import '../utils/encrypt_data.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(context, registerUser(context));
}

Future<Response> registerUser(RequestContext context) async {
  //check if the request is a POST request
  if (context.request.method == HttpMethod.post) {
    //check if headers is application/json
    final contentType = context.request.headers['content-type'];
    if (contentType == 'application/json') {
      //check if body is present
      final body = await context.request.json();
      if (body['username'] != null && body['password'] != null) {
        try {
          final encryptedPassword = EncryptData.encryptAES(body['password']);
          final user = UserModel.fromJson({
            'username': body['username'],
            'password': encryptedPassword,
            'profilePic': '',
            'isAdmin': false
          });
          await DatabaseService.usersCollection.insert(user.toJson());
          return Response.json(
            statusCode: 201,
            body: {
              'message': 'User created successfully',
              'user': user.toJson()
            },
          );
        } catch (e) {
          return Response.json(
            statusCode: 500,
            body: {'message': 'Internal Sercer Error'},
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

import 'package:dart_frog/dart_frog.dart';
import '../../models/user/user_model.dart';
import '../../services/database_service.dart';
import '../../utils/encrypt_data.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(context, registerUser(context));
}

Future<Response> registerUser(RequestContext context) async {
  //check if the request is a POST request
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 404,
      body: {'message': 'Method not allowed'},
    );
  }
  //check if headers is application/json
  final contentType = context.request.headers['content-type'];
  if (contentType != 'application/json') {
    return Response.json(
      statusCode: 404,
      body: {'message': contentType},
    );
  }
  //check if body is present
  final body = await context.request.json();
  final username = body['username'];
  final password = body['password'];
  if (username == null || password == null) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'All fields are required'},
    );
  }
  try {
    final encryptedPassword = EncryptData.encryptAES(body['password']);
    final user = UserModel.fromJson({
      'username': body['username'],
      'password': encryptedPassword,
      'profilePic': '',
      'isAdmin': false
    });
    await DatabaseService.usersCollection.insert(user.toJson());
    final returnUser = user.toJson();
    returnUser.remove('password');
    return Response.json(
      statusCode: 201,
      body: {'message': 'User created successfully', 'user': returnUser},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'Internal Server Error'},
    );
  }
}

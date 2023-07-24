import 'package:dart_frog/dart_frog.dart';
import '../constants/constant.dart';

Response onRequest(RequestContext context) {
  if (context.request.method == HttpMethod.get) {
    final params = context.request.uri.queryParameters;
    if (params.containsKey('id')) {
      //return user with the id
      final id = params['id'];
      try {
        final user = usersList.firstWhere((element) => element.id == id);
        return Response.json(
          body: {'data': user},
        );
      } catch (e) {
        return Response.json(
          statusCode: 404,
          body: {'message': 'User not found'},
        );
      }
    }
    return Response.json(
      body: {'data': usersList},
    );
  }
  return Response.json(
    statusCode: 404,
    body: {'message': 'Method not allowed'},
  );
}

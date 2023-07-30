import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final contentType = context.request.headers['content-type'];
    if (contentType != 'application/json') {
      return Response.json(
        statusCode: 400,
        body: {
          'message': 'Invalid content type',
        },
      );
    }
    final response = await handler(context);
    return response;
  };
}

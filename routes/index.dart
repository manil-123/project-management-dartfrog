import 'package:dart_frog/dart_frog.dart';
import '../services/database_service.dart';

Future<Response> onRequest(RequestContext context) {
  return DatabaseService.startConnection(
    context,
    onRequestIndex(context),
  );
}

Future<Response> onRequestIndex(RequestContext context) async {
  return Response(body: 'Welcome to Dart Frog!');
}

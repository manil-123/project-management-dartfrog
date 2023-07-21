import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(context, deleteProject(context));
}

Future<Response> deleteProject(RequestContext context) async {
  //check if the request is a DELETE request
  if (context.request.method == HttpMethod.delete) {
    //check if user_id is present
    final body = await context.request.json();
    final projectId = body['project_id'];
    if (projectId == null) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Project id is missing'},
      );
    }
    try {
      await DatabaseService.projectsCollection
          .remove(where.eq('project_id', projectId));
      return Response.json(
        body: {'message': 'Project deleted successfully'},
      );
    } catch (e) {
      return Response.json(
        statusCode: 404,
        body: {'message': 'Project not found'},
      );
    }
  }
  return Response.json(
    statusCode: 404,
    body: {'message': 'Method not allowed'},
  );
}

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    deleteProject(context),
  );
}

Future<Response> deleteProject(RequestContext context) async {
  //check if the request is a DELETE request
  if (context.request.method == HttpMethod.delete) {
    //check if project_id is present
    final body = await context.request.json();
    final projectId = body['project_id'];
    if (projectId == null) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Project id is missing',
        },
      );
    }
    try {
      final project = await DatabaseService.projectsCollection.findOne(
        where.eq(
          'project_id',
          projectId,
        ),
      );
      if (project == null) {
        return Response.json(
          statusCode: 400,
          body: {
            'success': false,
            'message': 'Project not found',
          },
        );
      }
      await DatabaseService.projectsCollection.remove(
        where.eq(
          'project_id',
          projectId,
        ),
      );
      return Response.json(
        body: {
          'success': true,
          'message': 'Project deleted successfully',
        },
      );
    } catch (e) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'Project not found',
        },
      );
    }
  }
  return Response.json(
    statusCode: 404,
    body: {
      'message': 'Method not allowed',
    },
  );
}

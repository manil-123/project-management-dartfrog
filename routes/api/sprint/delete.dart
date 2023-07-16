import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';
import 'package:collection/collection.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    deleteSprint(context),
  );
}

Future<Response> deleteSprint(RequestContext context) async {
  //check if the request is a DELETE request
  if (context.request.method == HttpMethod.delete) {
    //check if project_id is present
    final params = context.request.uri.queryParameters;
    final body = await context.request.json();
    final sprintId = body['sprint_id'];

    //check if user has passed id params.
    if (!params.containsKey('id')) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'Project id is missing',
        },
      );
    }
    if (sprintId == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'Sprint id is missing',
        },
      );
    }
    //get project with the id
    final id = params['id'];
    final doc = await DatabaseService.projectsCollection.findOne(
      where.eq('project_id', id),
    );
    if (doc == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'Project not found',
        },
      );
    }
    try {
      if (doc.isNotEmpty) {
        final project = ProjectModel.fromJson(doc);
        final existingSprint = project.sprints.firstWhereOrNull(
          (element) => element.id == sprintId,
        );

        if (existingSprint == null) {
          return Response.json(
            statusCode: 404,
            body: {
              'success': false,
              'message': 'Sprint not found in the project',
            },
          );
        }
        project.sprints.removeWhere((element) => element.id == sprintId);
        await DatabaseService.projectsCollection.update(
          where.eq('project_id', id),
          project.toJson(),
        );
        return Response.json(
          body: {
            'success': true,
            'data': project,
            'message': 'Sprint deleted successfully',
          },
        );
      }
    } catch (e) {
      print(e);
      return Response.json(
        statusCode: 500,
        body: {
          'success': false,
          'message': 'Internal Server Error',
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

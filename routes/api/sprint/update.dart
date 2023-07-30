import 'dart:html';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    updateSprint(context),
  );
}

Future<Response> updateSprint(RequestContext context) async {
  //check if the request is a PUT request
  if (context.request.method == HttpMethod.put) {
    //check if project_id is present
    final params = context.request.uri.queryParameters;
    final body = await context.request.json();
    final sprintId = body['sprint_id'];
    final sprintName = body['sprint_name'];

    //check if user has passed id params.
    if (!params.containsKey('id')) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Project id is missing',
        },
      );
    }
    if (sprintId == null || sprintName == null) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'All fields are required',
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
        // Find the index of the existing sprint based on sprintId
        final existingSprintIndex =
            project.sprints.indexWhere((element) => element.id == sprintId);
        if (existingSprintIndex != -1) {
          final existingSprint = project.sprints[existingSprintIndex];
          final updatedSprint = existingSprint.copyWith(name: sprintName);
          project.sprints[existingSprintIndex] = updatedSprint;
          await DatabaseService.projectsCollection.update(
            where.eq('project_id', id),
            project.toJson(),
          );
          return Response.json(
            statusCode: 200,
            body: {
              'success': true,
              'data': project,
              'message': 'Sprint updated successfully',
            },
          );
        } else {
          // Sprint not found, return an error response
          return Response.json(
            statusCode: 404,
            body: {
              'success': false,
              'message': 'Sprint not found in the project',
            },
          );
        }
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
    statusCode: HttpStatus.methodNotAllowed,
    body: {
      'message': 'Method not allowed',
    },
  );
}

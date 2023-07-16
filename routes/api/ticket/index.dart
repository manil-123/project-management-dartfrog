import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    getTickets(context),
  );
}

Future<Response> getTickets(RequestContext context) async {
  //check if the request is a GET request
  if (context.request.method == HttpMethod.get) {
    //check if user_id is present
    final params = context.request.uri.queryParameters;
    if (!params.containsKey('project_id')) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'Project id is missing',
        },
      );
    }
    if (!params.containsKey('sprint_id')) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'Sprint id is missing',
        },
      );
    }
    //get project with the id
    final projectId = params['project_id'];
    final sprintId = params['sprint_id'];
    try {
      final doc = await DatabaseService.projectsCollection.findOne(
        where.eq(
          'project_id',
          projectId,
        ),
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
      if (doc.isNotEmpty) {
        final project = ProjectModel.fromJson(doc);
        final sprintIndex =
            project.sprints.indexWhere((element) => element.id == sprintId);
        if (sprintIndex == -1) {
          return Response.json(
            statusCode: 404,
            body: {
              'success': false,
              'message': 'Sprint not found in the project',
            },
          );
        } else {
          return Response.json(
            body: {
              'success': true,
              'data': {
                "project_id": projectId,
                "project_name": project.name,
                "sprint_id": project.sprints[sprintIndex].id,
                "sprint_name": project.sprints[sprintIndex].name,
                "tickets": project.sprints[sprintIndex].tickets,
              },
              'message': 'Tickets fetched successfully'
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
    statusCode: 404,
    body: {
      'message': 'Method not allowed',
    },
  );
}

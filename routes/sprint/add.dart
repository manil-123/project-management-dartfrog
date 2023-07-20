import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/project/project_model.dart';
import '../../models/sprint/sprint_model.dart';
import '../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(context, addSprint(context));
}

Future<Response> addSprint(RequestContext context) async {
  //check if the request is a POST request
  if (context.request.method == HttpMethod.post) {
    //check if project_id is present
    final params = context.request.uri.queryParameters;
    final body = await context.request.json();
    final sprintName = body['sprint_name'];
    final sprintTickets = body['tickets'];

    //check if user has passed id params.
    if (!params.containsKey('id')) {
      return Response.json(
        statusCode: 404,
        body: {'message': 'Project id is missing'},
      );
    }
    if (sprintName == null || sprintTickets == null) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'All fields are required'},
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
        body: {'message': 'Project not found'},
      );
    }
    try {
      if (doc.isNotEmpty) {
        final project = ProjectModel.fromJson(doc);
        final newSprint = SprintModel(
          id: ObjectId().toHexString(),
          name: sprintName,
          tickets: [],
        );
        final newProject =
            project.copyWith(sprints: [...project.sprints, newSprint]);

        await DatabaseService.projectsCollection.update(
          where.eq('project_id', id),
          newProject.toJson(),
        );
        return Response.json(
          body: {
            'data': newProject,
            'message': 'Sprint added successfully',
          },
        );
      }
    } catch (e) {
      print(e);
      return Response.json(
        statusCode: 500,
        body: {'message': 'Internal Server Error'},
      );
    }
  }
  return Response.json(
    statusCode: 404,
    body: {'message': 'Method not allowed'},
  );
}

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/project/project_model.dart';
import '../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(context, getSprints(context));
}

Future<Response> getSprints(RequestContext context) async {
  //check if the request is a GET request
  if (context.request.method == HttpMethod.get) {
    //check if user_id is present
    final params = context.request.uri.queryParameters;
    if (!params.containsKey('id')) {
      return Response.json(
        statusCode: 404,
        body: {'message': 'Project id is missing'},
      );
    }
    //return user with the id
    final id = params['id'];
    try {
      final doc = await DatabaseService.projectsCollection
          .findOne(where.eq('project_id', id));
      if (doc == null) {
        return Response.json(
          statusCode: 404,
          body: {'message': 'Project not found'},
        );
      }
      if (doc.isNotEmpty) {
        final project = ProjectModel.fromJson(doc);
        return Response.json(
          body: {
            'data': project.sprints,
            'message': 'Sprints fetched successfully'
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

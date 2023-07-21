import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/project/project_model.dart';
import '../../models/user/user_model.dart';
import '../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(context, getProjects(context));
}

Future<Response> getProjects(RequestContext context) async {
  //check if the request is a GET request
  if (context.request.method == HttpMethod.get) {
    //check if user_id is present
    final params = context.request.uri.queryParameters;
    if (!params.containsKey('id')) {
      final docs = await DatabaseService.projectsCollection.find().toList();
      final projectsList = docs.map(ProjectModel.fromJson).toList();
      return Response.json(
        body: {'data': projectsList},
      );
    }
    //return user with the id
    final id = params['id'];
    try {
      final doc = await DatabaseService.projectsCollection
          .findOne(where.eq('project_id', id));
      if (doc != null && doc.isNotEmpty) {
        final project = ProjectModel.fromJson(doc);
        return Response.json(
          body: {'data': project},
        );
      }
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

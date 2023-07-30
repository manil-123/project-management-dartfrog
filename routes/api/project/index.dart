import 'dart:html';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    getProjects(context),
  );
}

Future<Response> getProjects(RequestContext context) async {
  //check if the request is a GET request
  if (context.request.method == HttpMethod.get) {
    //check if project is present
    final params = context.request.uri.queryParameters;
    if (!params.containsKey('id')) {
      final docs = await DatabaseService.projectsCollection.find().toList();
      final projectsList = docs.map(ProjectModel.fromJson).toList();
      return Response.json(
        statusCode: 200,
        body: {
          'success': true,
          'data': projectsList,
          'message': 'Projects fetched successfully',
        },
      );
    }
    //return project with the id
    final id = params['id'];
    try {
      final doc = await DatabaseService.projectsCollection.findOne(
        where.eq(
          'project_id',
          id,
        ),
      );
      if (doc != null && doc.isNotEmpty) {
        final project = ProjectModel.fromJson(doc);
        return Response.json(
          statusCode: 200,
          body: {
            'success': true,
            'data': project,
            'message': 'Project fetched successfully',
          },
        );
      }
    } catch (e) {
      print(' Project list error $e');
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

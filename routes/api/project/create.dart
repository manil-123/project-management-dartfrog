import 'dart:html';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    createProject(context),
  );
}

Future<Response> createProject(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'message': 'Method not allowed',
      },
    );
  }

  final body = await context.request.json();
  final projectName = body['project_name'];

  if (projectName == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'Project name is missing',
      },
    );
  }
  final project = await DatabaseService.projectsCollection.findOne(
    where.eq(
      'project_name',
      projectName,
    ),
  );
  if (project != null) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'Project name is already taken',
      },
    );
  }
  try {
    final newProject = ProjectModel.fromJson({
      'project_id': ObjectId().toHexString(),
      'project_name': projectName,
      'sprints': [],
      'members': []
    });
    await DatabaseService.projectsCollection.insert(
      newProject.toJson(),
    );
    return Response.json(
      statusCode: 201,
      body: {
        'success': true,
        'data': newProject,
        'message': 'Project created successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'message': 'Internal Server Error',
      },
    );
  }
}

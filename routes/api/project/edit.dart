import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    editProject(context),
  );
}

Future<Response> editProject(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'message': 'Method not allowed',
      },
    );
  }

  final body = await context.request.json();
  final projectId = body['project_id'];
  final projectName = body['project_name'];
  final projectSprints = body['sprints'];
  final projectMembers = body['members'];

  if (projectId == null ||
      projectName == null ||
      projectSprints == null ||
      projectMembers == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'All fields are required',
      },
    );
  }
  final project = await DatabaseService.projectsCollection.findOne(
    where.eq(
      'project_id',
      projectId,
    ),
  );
  if (project == null) {
    return Response.json(
      statusCode: 404,
      body: {
        'success': false,
        'message': 'Project not found',
      },
    );
  }
  try {
    final updatedProject = ProjectModel.fromJson(
      {
        'project_id': projectId,
        'project_name': projectName,
        'sprints': projectSprints,
        'members': projectMembers
      },
    );
    await DatabaseService.projectsCollection.update(
      where.eq(
        'project_id',
        projectId,
      ),
      updatedProject.toJson(),
    );
    return Response.json(
      statusCode: 200,
      body: {
        'success': true,
        'data': updatedProject,
        'message': 'Project updated successfully',
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

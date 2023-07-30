import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    removeMember(context),
  );
}

Future<Response> removeMember(RequestContext context) async {
  if (context.request.method != HttpMethod.delete) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'message': 'Method not allowed',
      },
    );
  }

  final body = await context.request.json();
  final projectId = body['project_id'];
  final memberId = body['user_id'];

  if (projectId == null || memberId == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'All fields are required',
      },
    );
  }
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
  try {
    final project = ProjectModel.fromJson(doc);
    final memberIndex =
        project.members.indexWhere((element) => element.id == memberId);
    if (memberIndex == -1) {
      return Response.json(
        statusCode: 404,
        body: {
          'success': false,
          'message': 'Member not found in the project',
        },
      );
    }
    project.members.removeWhere(
      (element) => element.id == memberId,
    );
    await DatabaseService.projectsCollection.update(
      where.eq(
        'project_id',
        projectId,
      ),
      project.toJson(),
    );
    return Response.json(
      statusCode: 200,
      body: {
        'success': true,
        'data': project,
        'message': 'Member deleted successfully',
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

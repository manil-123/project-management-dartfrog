import 'dart:html';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../models/user/user_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    addMember(context),
  );
}

Future<Response> addMember(RequestContext context) async {
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
  final member = body['member'];

  if (projectId == null || member == null) {
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
    final newMember = UserModel.fromJson(member);
    project.members.add(newMember);
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
        'message': 'Member added successfully',
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

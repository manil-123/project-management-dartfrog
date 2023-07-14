import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../models/ticket/ticket_model.dart';
import '../../../models/user/user_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    createTicket(context),
  );
}

Future<Response> createTicket(RequestContext context) async {
  //check if the request is a POST request
  if (context.request.method == HttpMethod.post) {
    //check if user_id is present
    final params = context.request.uri.queryParameters;
    final body = await context.request.json();
    final title = body['title'];
    final weight = body['weight'];
    final assignedTo = body['assignedTo'];
    if (!params.containsKey('project_id')) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Project id is missing',
        },
      );
    }
    if (!params.containsKey('sprint_id')) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Sprint id is missing',
        },
      );
    }
    if (title == null) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Title field is required',
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
          final ticketModel = TicketModel(
              id: ObjectId().toHexString(),
              title: title,
              logs: null,
              weight: (weight as int?) ?? 1,
              createdAt: DateTime.now().toString(),
              closedAt: null,
              assignedTo: (assignedTo as Map<String, dynamic>?) != null
                  ? UserModel.fromJson(assignedTo!)
                  : null);
          project.sprints[sprintIndex].tickets.add(ticketModel);
          await DatabaseService.projectsCollection.update(
            where.eq('project_id', projectId),
            project.toJson(),
          );
          return Response.json(
            statusCode: 201,
            body: {
              'success': true,
              'data': {
                "project_id": projectId,
                "project_name": project.name,
                "sprint": project.sprints[sprintIndex],
              },
              'message': 'Ticket created successfully',
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

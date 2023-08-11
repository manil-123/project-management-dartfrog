import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
import '../../../models/ticket/ticket_model.dart';
import '../../../models/user/user_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    updateTicket(context),
  );
}

Future<Response> updateTicket(RequestContext context) async {
  //check if the request is a PUT request
  if (context.request.method == HttpMethod.put) {
    //check if user_id is present
    final params = context.request.uri.queryParameters;
    final body = await context.request.json();
    final ticketId = body['id'];
    final title = body['title'];
    final logs = body['logs'];
    final weight = body['weight'];
    final closedAt = body['closedAt'];
    final assignedTo = body['assignedTo'];
    final ticketStatus = body['ticketStatus'];
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
    if (ticketId == null) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Ticket id is required',
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
          final ticketIndex = project.sprints[sprintIndex].tickets
              .indexWhere((element) => element.id == ticketId);
          if (ticketIndex == -1) {
            return Response.json(
              statusCode: 404,
              body: {
                'success': false,
                'message': 'Ticket not found in the sprint',
              },
            );
          } else {
            final ticketModel =
                project.sprints[sprintIndex].tickets[ticketIndex];
            final updatedTicket = ticketModel.copyWith(
              title: title ?? ticketModel.title,
              logs: logs ?? ticketModel.logs,
              weight: weight ?? ticketModel.weight,
              closedAt: closedAt != null
                  ? DateTime.now().toString()
                  : ticketModel.closedAt,
              assignedTo: assignedTo != null
                  ? UserModel.fromJson((assignedTo as Map<String, dynamic>?)!)
                  : ticketModel.assignedTo,
              ticketStatus: ticketStatus ?? ticketModel.ticketStatus,
            );
            project.sprints[sprintIndex].tickets[ticketIndex] = updatedTicket;
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
    statusCode: HttpStatus.methodNotAllowed,
    body: {
      'message': 'Method not allowed',
    },
  );
}

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../models/project/project_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    getAllTickets(context),
  );
}

Future<Response> getAllTickets(RequestContext context) async {
  //check if the request is a GET request
  if (context.request.method == HttpMethod.get) {
    try {
      List<Map<String, dynamic>> allTickets = [];
      final docs = await DatabaseService.projectsCollection.find().toList();
      final projectsList = docs.map(ProjectModel.fromJson).toList();

      projectsList.forEach((project) {
        // Calculate total tickets
        project.sprints.forEach((sprint) {
          sprint.tickets.forEach((ticket) {
            final ticketData = ticket.toJson();
            ticketData['project_id'] = project.id;
            ticketData['project_name'] = project.name;
            ticketData['sprint_id'] = sprint.id;
            ticketData['sprint_name'] = sprint.name;
            allTickets.add(ticketData);
          });
        });
      });

      return Response.json(
        statusCode: 200,
        body: {
          'success': true,
          'data': allTickets,
          'message': 'Projects fetched successfully',
        },
      );
    } catch (e) {
      print(' Dashboard error $e');
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

import 'package:go_router/go_router.dart';

import 'tasks_screen.dart';

/// Route of the task list.
abstract final class TasksRoutes {
  static const String tasksName = 'tasks';
  static const String tasksPath = '/tasks';
}

/// The app's home branch. It lives in the app rather than in a feature package
/// because the queue is assembled from several features at once, and a feature
/// package that reached into its siblings would invert the dependency.
List<RouteBase> tasksRoutes() => [
  GoRoute(
    name: TasksRoutes.tasksName,
    path: TasksRoutes.tasksPath,
    builder: (context, state) => const TasksScreen(),
  ),
];

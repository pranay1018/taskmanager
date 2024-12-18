import 'package:flutter/material.dart';
import 'package:taskmanager/src/view/screens/home_screen.dart';
import 'package:taskmanager/src/view/screens/signup_screen.dart';
import 'package:taskmanager/src/view/screens/add_todo_screen.dart';
import 'package:taskmanager/src/view/screens/view_todo_details_screen.dart';
import '../models/todo_model.dart';
import '../view/screens/login_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.addToDo:
        return MaterialPageRoute(builder: (_) => const AddTodoScreen());
      case AppRoutes.viewDetails:
      // Ensure the arguments are passed correctly
        if (args is Map<String, dynamic>) {
          final Todo todo = args['todo'] as Todo;
          final bool isEditing = args['isEditing'] as bool;

          return MaterialPageRoute(
            builder: (_) => ViewDetailScreen(todo: todo, isEditing: isEditing),
          );
        } else {
          return _errorRoute();
        }
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0); // Start from left to right
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}

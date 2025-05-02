import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ErrorHandler {
  // Handle HTTP errors and return appropriate exception
  static Exception handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return Exception('Bad request. Please check your input.');
      case 401:
        return Exception('Unauthorized. Authentication required.');
      case 403:
        return Exception('Forbidden. Access denied.');
      case 404:
        return Exception('Resource not found.');
      case 500:
      case 502:
      case 503:
      case 504:
        return Exception('Server error. Please try again later.');
      default:
        return Exception('HTTP error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Handle general exceptions with a message
  static Exception handleException(String message, dynamic error) {
    debugPrint('$message: $error');
    return Exception('$message: ${error.toString()}');
  }

  // Show error dialog
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
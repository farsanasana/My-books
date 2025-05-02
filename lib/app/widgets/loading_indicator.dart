import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    Key? key,
    this.message = AppConstants.loadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            message,
            style: AppConstants.bodyStyle,
          ),
        ],
      ),
    );
  }
}

// Bottom loading indicator for pagination
class BottomLoadingIndicator extends StatelessWidget {
  const BottomLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
        ),
      ),
    );
  }
}

// Error widget with retry option
class ErrorWithRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWithRetry({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppConstants.errorColor,
            size: 60,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            message,
            style: AppConstants.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:gcoin/api_service/api_service.dart';
import 'package:gcoin/utils/custom_snackbar.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;

  Future<void> registerUser({
    required String name,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    String? referBy,
    required String recaptchaToken, // <--- Add this parameter for the Turnstile token
  }) async {
    try {
      isLoading(true);

      final response = await _apiService.registerUser(
        name: name,
        email: email,
        username: username,
        password: password,
        passwordConfirmation: confirmPassword,
        referBy: referBy,
        recaptchaToken: recaptchaToken, // <--- Pass the token to the API service
      );

      if (response != null && response.data['success'] == true) {
        CustomSnackBar.success(response.data['message']);
        Get.offNamed('/sign_in'); // Navigate to sign in after successful registration
      } else {
        // Handle API error messages from your backend if available
        CustomSnackBar.error(response?.data['message'] ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      print('Registration error: $e');
      CustomSnackBar.error('An error occurred during registration.');
    } finally {
      isLoading(false);
    }
  }
}
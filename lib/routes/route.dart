import 'package:gcoin/screens/auth/forget_password/reset_password_screen.dart';
import 'package:gcoin/screens/auth/signup/signup.dart';
import 'package:gcoin/screens/homescreen/homescreen.dart';
import 'package:get/get.dart';

import '../screens/auth/signin/signin.dart';
import '../screens/onbroading/onbroading.dart';

class RouteHelper {
  static const String onboardScreen = '/onboard_screen';
  static const String sign = '/sign_in';
  static const String signup = '/sign_up';
  static const String resetPassword = '/reset-password';
  static const String homeScreen = '/home-screen';


  static List<GetPage> routes = [
    GetPage(
      name: homeScreen,
      page: () => const PiNetworkHomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: onboardScreen,
      page: () => const GCoinOnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: sign,
      page: () => const GCoinSignInScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: signup,
      page: () => const GCoinSignUpScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: resetPassword,
      page: () => ResetPasswordScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
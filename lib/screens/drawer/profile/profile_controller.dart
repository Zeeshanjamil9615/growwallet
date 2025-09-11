// profile_controller.dart
import 'package:gcoin/utils/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api_service/api_service.dart';


class ProfileController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  var isLoading = true.obs;
  var userProfile = <String, dynamic>{}.obs;
  var hideRealName = false.obs;
  var hideBalance = false.obs;
  var pushNotifications = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      final response = await _apiService.getProfile();
      if (response != null && response.data['success'] == true) {
        userProfile.value = response.data['user'];
      }
    } finally {
      isLoading(false);
    }
  }

  // Add this method to refresh profile data
  Future<void> refreshProfile() async {
    try {
      print('Refreshing profile data...');
      final response = await _apiService.getProfile();
      if (response != null && response.data['success'] == true) {
        userProfile.value = response.data['user'];
        print('Profile data refreshed successfully');
      }
    } catch (e) {
      print('Error refreshing profile: $e');
    }
  }

  String getInitials(String? name) {
    if (name == null || name.isEmpty) return 'US';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void toggleHideRealName(bool value) {
    hideRealName(value);
    // CustomSnackBar.success('Soon it will be workable');
  }

  void toggleHideBalance(bool value) {
    hideBalance(value);
    // CustomSnackBar.success('Soon it will be workable');
  }

  void togglePushNotifications(bool value) {
    pushNotifications(value);
    // CustomSnackBar.success('Soon it will be workable');
  }

  void handleVerificationAction(String type) {
    CustomSnackBar.success('$type verification functionality coming soon');
  }

  void handleAccountAction(String type) {
    // CustomSnackBar.success('$type functionality coming soon');
    shareReferralCode();
  }

  Future<void> shareReferralCode() async {
    try {
      final userName = userProfile['name'] ?? 'Your Friend';
      final referralCode = userProfile['username'] ?? '';

      // Create beautiful WhatsApp message
      final message = '''
🌟 *Join Grow Network!* 🌟

Hey! I'm ${hideRealName.value ? '' : userName} inviting you to join the revolutionary Grow Network! 

💰 *Earn Gaming Coins daily* by gaming & inviting friends
🚀 *Free to start* - No investment required
🔗 *Global community* of gamers earning together
📱 *Simple mobile gaming* - Just tap to mine!

*Your Referral Code:* `$referralCode`

📲 *Download Grow Network App:*
https://play.google.com/store/apps/details?id=pro.gnetwork.grownetwork&hl=en

Join thousands of users already earning Gaming Coins! 
Don't miss out on this opportunity! 🎯

#GrowNetwork #GamingCoin #EarnDaily
      '''.trim();

      // // Create WhatsApp URL
      // final whatsappUrl = 'https://wa.me/$senderNumber?text=${Uri.encodeComponent(message)}';


        // Fallback to general share
        final generalShareUrl = 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}';
        if (await canLaunchUrl(Uri.parse(generalShareUrl))) {
          await launchUrl(
            Uri.parse(generalShareUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          CustomSnackBar.error('Unable to open WhatsApp. Please install WhatsApp first.');
        }

    } catch (e) {
      CustomSnackBar.error('Error sharing referral code: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final response = await _apiService.logoutUser();
    if (response != null && response.statusCode == 200) {
      Get.offAllNamed('/login'); // Adjust based on your routes
    }
  }
}
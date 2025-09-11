import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api_service/api_service.dart';
import '../../../api_service/local_stroge.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/custom_snackbar.dart';
import 'profile_controller.dart';
import 'update_profile.dart';


class ModernProfileScreen extends StatefulWidget {
  ModernProfileScreen({super.key});

  @override
  State<ModernProfileScreen> createState() => _ModernProfileScreenState();
}

class _ModernProfileScreenState extends State<ModernProfileScreen> {
  final ProfileController _controller = Get.put(ProfileController());



  @override
  void initState() {
    super.initState();



  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            // Modern App Bar with Gradient
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyColor.getGCoinGlassColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MyColor.getGCoinGlassBorderColor(),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: MyColor.getTextColor(),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyColor.getGCoinGlassColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MyColor.getGCoinGlassBorderColor(),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.language_rounded,
                      color: MyColor.getTextColor(),
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: MyColor.getGCoinHeroGradient(),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          MyColor.getScreenBgColor().withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),


            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // G Balance Card
                    _buildPiBalanceCard(),
                    const SizedBox(height: 24),

                    // Profile Info Card
                    _buildProfileInfoCard(),
                    const SizedBox(height: 24),

                    // Settings Section
                    _buildSettingsSection(),
                    const SizedBox(height: 24),

                    // Account Verification Section

                    // Account Actions Section

                    // Sign Out Button
                    _buildSignOutButton(),
                    const SizedBox(height: 32),



                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPiBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinPrimaryGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MyColor.gCoinPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.g_mobiledata,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'G Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  _controller.hideBalance.value
                      ? '*****'
                      : '${_controller.userProfile['balance']} G',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: MyColor.getGCoinCardColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyColor.getGCoinDividerColor(),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: MyColor.gCoinPrimary,
                child: Text(
                  _controller.getInitials(_controller.userProfile['name']),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      _controller.hideRealName.value
                          ? 'Hidden Name'
                          : _controller.userProfile['name'] ?? 'No Name',
                      style: TextStyle(
                        color: MyColor.getTextColor(),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: (){ Get.to(()=> UpdateProfileScreen());},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MyColor.gCoinWarning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: MyColor.gCoinWarning.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Tap to Update Profile',
                          style: TextStyle(
                            color: MyColor.gCoinWarning,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Warning Message
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: MyColor.gCoinWarning.withOpacity(0.05),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: MyColor.gCoinWarning.withOpacity(0.2),
          //       width: 1,
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(
          //         Icons.warning_amber_rounded,
          //         color: MyColor.gCoinWarning,
          //         size: 20,
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'Correct spelling is needed to claim G.',
          //               style: TextStyle(
          //                 color: MyColor.getTextColor(),
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //             Text(
          //               'You have 4 days and 07:39:27 to correct name.',
          //               style: TextStyle(
          //                 color: MyColor.getSecondaryTextColor(),
          //                 fontSize: 12,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 20),

          // Username Section
          _buildInfoItem(
            'Username:',
            '@${_controller.userProfile['username']?.split('@')[0] ?? 'username'}',
            Icons.person_outline_rounded,
            showShare: true,

          ),

          const SizedBox(height: 16),

          // Referral Link Section
          // _buildInfoItem(
          //   'Referral code to share:',
          //   '${_controller.userProfile['username']?? ''}',
          //   Icons.link_rounded,
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {bool showShare = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.getGCoinSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MyColor.getGCoinDividerColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MyColor.gCoinPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: MyColor.gCoinPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: MyColor.getSecondaryTextColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: MyColor.getTextColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (showShare)
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _controller.handleAccountAction('Share referral link');
              },
              icon: Icon(
                Icons.share_rounded,
                color: MyColor.gCoinPrimary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: MyColor.getGCoinCardColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyColor.getGCoinDividerColor(),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: MyColor.getTextColor(),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Obx(() => _buildSettingItem(
            'Hide real name',
            'Hide my real name from members of my Referral Team',
            _controller.hideRealName.value,
            _controller.toggleHideRealName,
            Icons.visibility_off_rounded,
          )),
          const SizedBox(height: 16),

          Obx(() => _buildSettingItem(
            'Hide Balance',
            'Hide the balance number shown at the top of the app.\nHiding the balance will not affect your mining rate.',
            _controller.hideBalance.value,
            _controller.toggleHideBalance,
            Icons.account_balance_wallet_outlined,
          )),
          const SizedBox(height: 16),

          Obx(() => _buildSettingItem(
            'Push Notifications',
            'In order to disable notifications, you must go to your phone\'s settings page.',
            _controller.pushNotifications.value,
            _controller.togglePushNotifications,
            Icons.notifications_outlined,
          )),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String description, bool value, Function(bool) onChanged, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.getGCoinSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MyColor.getGCoinDividerColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MyColor.gCoinPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: MyColor.gCoinPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: MyColor.getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: MyColor.getSecondaryTextColor(),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: MyColor.gCoinPrimary,
              activeTrackColor: MyColor.gCoinPrimary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountVerificationSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: MyColor.getGCoinCardColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyColor.getGCoinDividerColor(),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account verification',
            style: TextStyle(
              color: MyColor.getTextColor(),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildVerificationItem(
            'Phone number',
            Icons.phone_android_rounded,
            'Add',
            MyColor.gCoinWarning,
            false,
            onTap: () => _controller.handleVerificationAction('Phone'),
          ),
          const SizedBox(height: 12),

          

          _buildVerificationItem(
            'Email address',
            Icons.email_outlined,
            'Verify',
            MyColor.gCoinWarning,
            false,
            showWarning: true,
            onTap: () => _controller.handleVerificationAction('Email'),
          ),
          const SizedBox(height: 8),
          Text(
            'Add and verify your email as an additional way to recover your G Account in the future.',
            style: TextStyle(
              color: MyColor.getSecondaryTextColor(),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(
      String title,
      IconData icon,
      String action,
      Color actionColor,
      bool isVerified, {
        bool showWarning = false,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MyColor.getGCoinSurfaceColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MyColor.getGCoinDividerColor(),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: actionColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: MyColor.getTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showWarning) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.warning_amber_rounded,
                      color: MyColor.gCoinWarning,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
            if (isVerified)
              Icon(
                Icons.check_circle_rounded,
                color: MyColor.gCoinSuccess,
                size: 20,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: actionColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  action,
                  style: TextStyle(
                    color: actionColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
      String title,
      String description,
      IconData icon,
      Color color,
      String action, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MyColor.getGCoinSurfaceColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MyColor.getGCoinDividerColor(),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: MyColor.getTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: MyColor.getSecondaryTextColor(),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                action,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.gCoinWarning.withOpacity(0.8),
            MyColor.gCoinWarning,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColor.gCoinWarning.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final apiService = ApiService();
            final response = await apiService.logoutUser();
            if (response != null && response.statusCode == 200) {
              await LocalStorage.clear();
              CustomSnackBar.success("Logout Successfully");
              // Navigate to login screen or wherever appropriate
              Get.offAllNamed(
                '/sign_in',
              ); // Adjust this based on your navigation setup
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gcoin/main.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../../../api_service/api_service.dart';
import '../../../utils/app_colors.dart';

class ActivityStatusScreen extends StatefulWidget {
  const ActivityStatusScreen({Key? key}) : super(key: key);

  @override
  State<ActivityStatusScreen> createState() => _ActivityStatusScreenState();
}

class _ActivityStatusScreenState extends State<ActivityStatusScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  ActivityStatusResponse? activityData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // Native Ad variables
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadActivityStatus();
    if(myAds['NatActiveS'] == true){
      _loadNativeAd();
    }
  }
  void _loadNativeAd() {
  String id = myAds['NatActiveSID'] ?? 'ca-app-pub-9756236136807053/8773403080';
  // String id = 'ca-app-pub-3940256099942544/2247696110';
    _nativeAd = NativeAd(
      // adUnitId: kDebugMode ? "ca-app-pub-3940256099942544/2247696110":AdHelper.nativeAdUnitId,
      adUnitId: id,
      factoryId: 'listTile', // Make sure you have a NativeAdFactory configured
      request: const AdRequest(),
      listener: NativeAdListener(
        
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('NativeAd loaded successfully.');
          }
          setState(() {
            _nativeAd = ad as NativeAd;
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (kDebugMode) {
            print('NativeAd failed to load: $error');
          }
          ad.dispose();
          setState(() {
            _isNativeAdLoaded = false;
          });
        },
      ),
    );
    _nativeAd!.load();
  }
  @override
  void dispose() {
    _animationController.dispose();
    _nativeAd?.dispose(); 
    super.dispose();
  }
  Widget _buildNativeAd() {
    if (_isNativeAdLoaded && _nativeAd != null) {
      return Container(
        height: 150, // Adjust the height as needed for your native ad format
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green,width: 2, style: BorderStyle.solid)),
        child: AdWidget(ad: _nativeAd!),
      );
    } else if(myAds['NatActiveS'] == false) {
      return SizedBox.shrink(); // Show an empty box if ad is not loaded
    }
    else{
      return Container(
         decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green,width: 2, style: BorderStyle.solid)),
        height: 150,width: Get.width,child: Center(child: Text("Loading Ads...")),); // Show an empty box if ad is not loaded
    }
  }
  Future<void> _loadActivityStatus() async {
    try {
      final response = await _apiService.getActivityStatus();
      if (response != null && response.statusCode == 200) {
        setState(() {
          activityData = ActivityStatusResponse.fromJson(response.data);
          // Sort data by date in descending order (most recent first)
          activityData!.data.sort((a, b) => b.date.compareTo(a.date));
          isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadActivityStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppBar(
        backgroundColor: MyColor.getAppbarBgColor(),
        elevation: 0,
        title: Text(
          'Activity History',
          style: TextStyle(
            color: MyColor.getAppbarTitleColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: MyColor.getAppbarTitleColor(),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: MyColor.getAppbarTitleColor(),
            ),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : activityData == null
          ? _buildErrorWidget()
          : RefreshIndicator(
        onRefresh: _refreshData,
        color: MyColor.getPrimaryColor(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 20),
                _buildNativeAd(),
                const SizedBox(height: 20),
                _buildActivityList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MyColor.getCardBg(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MyColor.getGCoinShadowColor(),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: MyColor.colorRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load activity data',
            style: TextStyle(
              color: MyColor.getTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: MyColor.getTextColor1(),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.getPrimaryColor(),
              foregroundColor: MyColor.colorWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinHeroGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MyColor.colorWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: MyColor.colorWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '30-Day Summary',
                      style: TextStyle(
                        color: MyColor.colorWhite.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Activity Overview',
                      style: TextStyle(
                        color: MyColor.colorWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Amount',
                  '${activityData!.monthlyAmount}',
                  Icons.savings_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: MyColor.colorWhite.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Inactive Days',
                  '${activityData!.inactiveDays}',
                  Icons.schedule_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: activityData!.monthlyStatus.toLowerCase() == 'active'
                  ? MyColor.colorWhite.withOpacity(0.2)
                  : MyColor.colorWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MyColor.colorWhite.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activityData!.monthlyStatus.toLowerCase() == 'active'
                        ? MyColor.colorWhite
                        : MyColor.colorWhite.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${activityData!.monthlyStatus}',
                  style: TextStyle(
                    color: MyColor.colorWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: MyColor.colorWhite.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: MyColor.colorWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: MyColor.colorWhite.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Activity',
          style: TextStyle(
            color: MyColor.getHeadingTextColor(),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activityData!.data.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = activityData!.data[index];
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _buildActivityCard(activity),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(ActivityData activity) {
    final isActive = activity.status.toLowerCase() == 'active';
    final date = DateTime.parse(activity.date);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == activity.date;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.getGCoinCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? MyColor.getGCoinPrimaryColor().withOpacity(0.3)
              : MyColor.getGCoinDividerColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? MyColor.getGCoinPrimaryColor().withOpacity(0.1)
                  : MyColor.colorGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? MyColor.getGCoinPrimaryColor().withOpacity(0.3)
                    : MyColor.colorGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isActive ? Icons.flash_on : Icons.flash_off,
              color: isActive ? MyColor.getGCoinPrimaryColor() : MyColor.colorGrey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: TextStyle(
                        color: MyColor.getTextColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: MyColor.getGCoinPrimaryColor(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            color: MyColor.colorWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE').format(date),
                  style: TextStyle(
                    color: MyColor.getTextColor1(),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity.amount > 0) ...[
                Text(
                  '${activity.amount}',
                  style: TextStyle(
                    color: isActive
                        ? MyColor.getGCoinPrimaryColor()
                        : MyColor.getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Count: ${activity.count}',
                  style: TextStyle(
                    color: MyColor.getTextColor1(),
                    fontSize: 11,
                  ),
                ),
              ] else ...[
                Text(
                  'No Activity',
                  style: TextStyle(
                    color: MyColor.getTextColor1(),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? MyColor.getGCoinSuccessColor().withOpacity(0.1)
                      : MyColor.colorGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? MyColor.getGCoinSuccessColor()
                            : MyColor.colorGrey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.status,
                      style: TextStyle(
                        color: isActive
                            ? MyColor.getGCoinSuccessColor()
                            : MyColor.colorGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Model classes
class ActivityStatusResponse {
  final bool success;
  final List<ActivityData> data;
  final String monthlyStatus;
  final int monthlyAmount;
  final int inactiveDays;

  ActivityStatusResponse({
    required this.success,
    required this.data,
    required this.monthlyStatus,
    required this.monthlyAmount,
    required this.inactiveDays,
  });

  factory ActivityStatusResponse.fromJson(Map<String, dynamic> json) {
    return ActivityStatusResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
          ?.map((item) => ActivityData.fromJson(item))
          .toList() ??
          [],
      monthlyStatus: json['monthly_status'] ?? '',
      monthlyAmount: json['monthly_amount'] ?? 0,
      inactiveDays: json['inactive_days'] ?? 0,
    );
  }
}

class ActivityData {
  final String date;
  final int count;
  final int amount;
  final String status;

  ActivityData({
    required this.date,
    required this.count,
    required this.amount,
    required this.status,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      date: json['date'] ?? '',
      count: json['mining_count'] ?? 0,
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
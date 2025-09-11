import 'package:get/get.dart';
import '../../../api_service/api_service.dart';
import '../../homescreen/home_controller.dart';

class MineGController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  var isLoading = true.obs;
  var miningData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMiningData();
  }

  Future<void> fetchMiningData() async {
    try {
      isLoading(true);
      final response = await _apiService.mineG();
      if (response != null && response.data['success'] == true) {
        miningData.value = response.data;
      }
    } finally {
      isLoading(false);
    }
  }

  String getBalance() {
    return miningData['balance']?.toString() ?? '0.00';
  }

  String getMiningReward() {
    return miningData['mining_reward']?.toString() ?? '0.00';
  }

  String getPerHourRate() {
    return miningData['per_hour_rate']?.toStringAsFixed(2) ?? '0.00';
  }

  bool isMiningActive() {
    return Get.find<HomeController>().isMining.value;
  }

  String getRemainingTime() {
    return Get.find<HomeController>().formatTime(Get.find<HomeController>().miningTimeLeft.value);
  }
}
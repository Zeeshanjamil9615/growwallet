import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'support_controller.dart';

class ModernSupportScreen extends StatelessWidget {
  ModernSupportScreen({super.key});
  final SupportController _controller = Get.put(SupportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with Gradient Background
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: MyColor.getGCoinHeroGradient(),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MyColor.colorWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: MyColor.colorWhite.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: MyColor.colorWhite,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          'Support Center',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: MyColor.colorWhite,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'re here to help you 24/7',
                          style: TextStyle(
                            fontSize: 16,
                            color: MyColor.colorWhite.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Box
                      Container(
                        decoration: BoxDecoration(
                          color: MyColor.getGCoinCardColor(),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: MyColor.getGCoinShadowColor(),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: MyColor.getGCoinDividerColor(),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          onChanged: _controller.filterArticles,
                          style: TextStyle(
                            color: MyColor.getTextColor(),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search support articles...',
                            hintStyle: TextStyle(
                              color: MyColor.getTextFieldHintColor(),
                              fontSize: 16,
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.search,
                                color: MyColor.getGCoinPrimaryColor(),
                                size: 24,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Search results count
                      Text(
                        '${_controller.filteredArticles.length} articles found',
                        style: TextStyle(
                          color: MyColor.getSecondaryTextColor(),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Articles List
                      if (_controller.filteredArticles.isEmpty)
                        _buildNoResults(),
                      if (_controller.filteredArticles.isNotEmpty)
                        ..._controller.filteredArticles.map((article) =>
                            _buildArticleCard(article)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No articles found',
            style: TextStyle(
              fontSize: 18,
              color: MyColor.getTextColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Try different search terms',
            style: TextStyle(
              fontSize: 14,
              color: MyColor.getSecondaryTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: MyColor.getGCoinCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: MyColor.getGCoinDividerColor(),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          article['title'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MyColor.getTextColor(),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              article['summary'],
              style: TextStyle(
                fontSize: 14,
                color: MyColor.getSecondaryTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                article['category'],
                style: TextStyle(
                  fontSize: 12,
                  color: MyColor.getGCoinPrimaryColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        iconColor: MyColor.getGCoinPrimaryColor(),
        collapsedIconColor: MyColor.getGCoinPrimaryColor(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Last updated: ${article['created_at']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: MyColor.getSecondaryTextColor(),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: article['content'].toString().replaceAll('<p>', '').replaceAll('</p>', ''),
                        style: TextStyle(
                          fontSize: 14,
                          color: MyColor.getTextColor(),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
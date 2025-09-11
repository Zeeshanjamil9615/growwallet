import 'package:flutter/material.dart';
import 'package:gcoin/utils/app_colors.dart';
import 'package:get/get.dart';

import 'faq_controller.dart';
import 'faq_model.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FAQController _faqController = Get.put(FAQController());



  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

  }

  @override
  void dispose() {

    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  void _filterFAQs(String query) {
    _faqController.filterFAQs(query);
  }

  void _toggleExpansion(int index) {
    _faqController.toggleExpansion(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: _buildAppBar(),
      body: Obx(() {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _faqController.isLoading.value
              ? _buildLoadingIndicator()
              : SingleChildScrollView(
            child: Column(
              children: [

                _buildSearchSection(),
                _buildCategoriesFilter(),
                _buildFAQList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: MyColor.getGCoinPrimaryColor(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColor.getAppbarBgColor(),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: MyColor.getAppbarTitleColor(),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'FAQ',
        style: TextStyle(
          color: MyColor.getAppbarTitleColor(),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: MyColor.getGCoinPrimaryGradient(),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How can we help you?',
            style: TextStyle(
              color: MyColor.getHeadingTextColor(),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for answers or browse categories below',
            style: TextStyle(
              color: MyColor.getSecondaryTextColor(),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: MyColor.getGCoinCardColor(),
              borderRadius: BorderRadius.circular(16),
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
            child: Obx(() => TextField(
              controller: _searchController,
              onChanged: _filterFAQs,
              style: TextStyle(color: MyColor.getTextColor()),
              decoration: InputDecoration(
                hintText: 'Search FAQ...',
                hintStyle: TextStyle(color: MyColor.getTextFieldHintColor()),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: MyColor.getGCoinPrimaryColor(),
                ),
                suffixIcon: _faqController.currentSearchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: MyColor.getTextFieldHintColor(),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filterFAQs('');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: Obx(() {
        // Force rebuild when selectedCategory changes
        final selectedCat = _faqController.selectedCategory.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _faqController.categories.length,
          itemBuilder: (context, index) {
            final category = _faqController.categories[index];
            final isSelected = selectedCat == category;
            return _buildCategoryChip(category, isSelected);
          },
        );
      }),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Force immediate update
          _faqController.filterByCategory(category);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150), // Reduced duration for faster response
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? MyColor.getGCoinPrimaryColor()
                : MyColor.getGCoinCardColor(),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? MyColor.getGCoinPrimaryColor()
                  : MyColor.getGCoinDividerColor(),
              width: 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [],
          ),
          child: Text(
            category,
            style: TextStyle(
              color: isSelected
                  ? MyColor.colorWhite
                  : MyColor.getTextColor(),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    return Obx(() {
      if (_faqController.filteredFAQs.isEmpty) {
        return _buildEmptyState();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _faqController.filteredFAQs.length,
          itemBuilder: (context, index) {
            return _buildFAQItem(_faqController.filteredFAQs[index], index);
          },
        ),
      );
    });
  }

  Widget _buildFAQItem(FAQItem faq, int index) {
    return Obx(() {
      final isExpanded = _faqController.expandedIndex.value == index;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: MyColor.getGCoinCardColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? MyColor.getGCoinPrimaryColor()
                : MyColor.getGCoinDividerColor(),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinShadowColor(),
              blurRadius: isExpanded ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => _toggleExpansion(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        faq.category,
                        style: TextStyle(
                          color: MyColor.getGCoinPrimaryColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        faq.question,
                        style: TextStyle(
                          color: MyColor.getHeadingTextColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: MyColor.getGCoinPrimaryColor(),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isExpanded ? null : 0,
              child: isExpanded
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: MyColor.getGCoinDividerColor(),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      faq.answer,
                      style: TextStyle(
                        color: MyColor.getSecondaryTextColor(),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Was this helpful?',
                          style: TextStyle(
                            color: MyColor.getTextFieldHintColor(),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildHelpfulButton(Icons.thumb_up_rounded, true),
                        const SizedBox(width: 8),
                        _buildHelpfulButton(Icons.thumb_down_rounded, false),
                      ],
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHelpfulButton(IconData icon, bool isPositive) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPositive ? 'Thank you for your feedback!' : 'We\'ll improve this answer',
            ),
            backgroundColor: MyColor.getGCoinPrimaryColor(),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 16,
          color: MyColor.getGCoinPrimaryColor(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: MyColor.getGCoinPrimaryColor(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: TextStyle(
                color: MyColor.getHeadingTextColor(),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                color: MyColor.getSecondaryTextColor(),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _faqController.clearSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.getGCoinPrimaryColor(),
                foregroundColor: MyColor.colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Clear Search',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
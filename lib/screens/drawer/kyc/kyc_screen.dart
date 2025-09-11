import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'kyc_controller.dart';

class KYCScreen extends StatelessWidget {
  const KYCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KYCController());

    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: _buildAppBar(controller),
      body: Obx(() => controller.isLoading
          ? _buildLoadingState()
          : _buildMainContent(controller)),
    );
  }

  AppBar _buildAppBar(KYCController controller) {
    return AppBar(
      backgroundColor: MyColor.getAppbarBgColor(),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: MyColor.getTextColor(),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'KYC Verification',
        style: TextStyle(
          color: MyColor.getTextColor(),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        // Skip button
        TextButton(
          onPressed: controller.skipKYC,
          child: Text(
            'Skip for now',
            style: TextStyle(
              color: MyColor.getGCoinPrimaryColor(),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Obx(() => controller.isLoading
            ? Container(
          margin: const EdgeInsets.only(right: 16),
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  MyColor.getGCoinPrimaryColor(),
                ),
                strokeWidth: 2,
              ),
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              MyColor.getGCoinPrimaryColor(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading KYC form...',
            style: TextStyle(
              color: MyColor.getTextColor(),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(KYCController controller) {
    return FadeTransition(
      opacity: controller.fadeAnimation,
      child: SlideTransition(
        position: controller.slideAnimation,
        child: RefreshIndicator(
          onRefresh: controller.loadKYCForm,
          color: MyColor.getGCoinPrimaryColor(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show API message if available
                        if (controller.message.isNotEmpty) ...[
                          _buildMessageCard(controller),
                          const SizedBox(height: 20),
                        ],
                        if (controller.fields.isNotEmpty) ...[
                          _buildFormSection(controller),
                          const SizedBox(height: 32),
                          _buildSubmitButton(controller),
                        ] else
                          _buildEmptyState(),
                        const SizedBox(height: 20), // Extra padding at bottom
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(KYCController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.getGCoinInfoColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MyColor.getGCoinInfoColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: MyColor.getGCoinInfoColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.message,
              style: TextStyle(
                color: MyColor.getTextColor(),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(KYCController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(16),
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
            'Required Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColor.getTextColor(),
            ),
          ),
          const SizedBox(height: 20),
          ...controller.fields.map((field) {
            if (field.type == 'file') {
              return _buildFileField(field, controller);
            } else {
              return _buildTextField(field, controller);
            }
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTextField(KYCField field, KYCController controller) {
    final textController = controller.controllers[field.label];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MyColor.getTextColor(),
                ),
              ),
              if (field.required)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 16,
                    color: MyColor.getErrorColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              gradient: MyColor.getGCoinCardGradient(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MyColor.getFieldEnableBorderColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: textController,
              keyboardType: field.type == 'number' ? TextInputType.number : TextInputType.text,
              style: TextStyle(
                color: MyColor.getTextColor(),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Enter ${field.label.toLowerCase()}',
                hintStyle: TextStyle(
                  color: MyColor.getTextFieldHintColor(),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: MyColor.getCardBg(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: MyColor.getGCoinPrimaryColor(),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileField(KYCField field, KYCController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MyColor.getTextColor(),
                ),
              ),
              if (field.required)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 16,
                    color: MyColor.getErrorColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final selectedFile = controller.selectedFiles[field.label];
            return GestureDetector(
              onTap: () => controller.pickImage(field.label),
              child: Container(
                width: double.infinity,
                height: selectedFile != null ? 200 : 125,
                decoration: BoxDecoration(
                  gradient: MyColor.getGCoinCardGradient(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: selectedFile != null
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        selectedFile,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: MyColor.getGCoinPrimaryColor(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tap to change',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: MyColor.getGCoinPrimaryColor(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload ${field.label}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MyColor.getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to select image',
                      style: TextStyle(
                        fontSize: 14,
                        color: MyColor.getTextFieldHintColor(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(KYCController controller) {
    return Obx(() => Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinPrimaryGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isSubmitting ? null : controller.submitKYC,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: controller.isSubmitting
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Submitting...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        )
            : Text(
          'Submit KYC',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ));
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: MyColor.getTextFieldHintColor(),
          ),
          const SizedBox(height: 16),
          Text(
            'No KYC fields available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: MyColor.getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later or contact support',
            style: TextStyle(
              fontSize: 14,
              color: MyColor.getTextFieldHintColor(),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
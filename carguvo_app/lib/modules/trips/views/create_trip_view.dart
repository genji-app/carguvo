import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';
import 'package:carguvo/widgets/app_text_field.dart';
import 'package:carguvo/widgets/app_button.dart';

class CreateTripView extends StatefulWidget {
  const CreateTripView({super.key});

  @override
  State<CreateTripView> createState() => _CreateTripViewState();
}

class _CreateTripViewState extends State<CreateTripView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tạo chuyến xe', style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXXL),

              AppTextField(
                label: 'Mã chuyến *',
                hint: 'VD: CVO-8821',
                controller: _codeController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã chuyến';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingLG),

              AppTextField(
                label: 'Ghi chú',
                hint: 'Ghi chú cho chuyến xe...',
                controller: _noteController,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.paddingHuge),

              AppButton(
                text: 'Tạo chuyến',
                icon: Icons.add,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final ctrl = Get.find<TripController>();
      ctrl.createTrip(
        code: _codeController.text.trim(),
        note: _noteController.text.trim(),
      );
    }
  }
}

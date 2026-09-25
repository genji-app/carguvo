import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/data/repositories/trip_repository.dart';
import 'package:carguvo/modules/delivery_points/controllers/delivery_point_controller.dart';
import 'package:carguvo/widgets/app_text_field.dart';
import 'package:carguvo/widgets/app_button.dart';

class AddDeliveryPointView extends StatefulWidget {
  const AddDeliveryPointView({super.key});

  @override
  State<AddDeliveryPointView> createState() => _AddDeliveryPointViewState();
}

class _AddDeliveryPointViewState extends State<AddDeliveryPointView> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedTripId;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is String) {
      _selectedTripId = Get.arguments as String;
    }
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripRepo = Get.find<TripRepository>();
    final trips = tripRepo.getAll();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Thêm điểm giao', style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chuyến xe *', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTripId,
                items: trips
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.id,
                        child: Text('#${t.code}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTripId = value),
                decoration: const InputDecoration(hintText: 'Chọn chuyến xe'),
                validator: (value) {
                  if (value == null) return 'Vui lòng chọn chuyến xe';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingLG),

              AppTextField(
                label: 'Tên người nhận *',
                hint: 'VD: Nguyễn Minh Anh',
                controller: _receiverController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên người nhận';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingLG),

              AppTextField(
                label: 'Số điện thoại',
                hint: 'VD: 0901234567',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.paddingLG),

              AppTextField(
                label: 'Địa chỉ',
                hint: 'VD: 123 Lê Lợi, Quận 1',
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.paddingLG),

              AppTextField(
                label: 'Ghi chú',
                hint: 'Ghi chú thêm (nếu có)',
                controller: _noteController,
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.paddingHuge),

              AppButton(
                text: 'Lưu điểm giao',
                icon: Icons.save_outlined,
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
      controller.addDeliveryPoint(
        tripId: _selectedTripId!,
        receiverName: _receiverController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        note: _noteController.text.trim(),
      );
    }
  }

  DeliveryPointController get controller => Get.find<DeliveryPointController>();
}

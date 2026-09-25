import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/data/repositories/trip_repository.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';

class EditTripView extends StatefulWidget {
  const EditTripView({super.key});

  @override
  State<EditTripView> createState() => _EditTripViewState();
}

class _EditTripViewState extends State<EditTripView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _noteController = TextEditingController();
  late String tripId;

  @override
  void initState() {
    super.initState();
    tripId = Get.arguments as String;
    final trip = Get.find<TripRepository>().getById(tripId);
    if (trip != null) {
      _codeController.text = trip.code;
      _noteController.text = trip.note;
    }
  }

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
      appBar: AppBar(title: const Text('Sửa chuyến xe'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã chuyến xe', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'VD: CX001'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã chuyến';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text('Ghi chú', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nhập ghi chú (không bắt buộc)',
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Get.find<TripController>().updateTrip(
        tripId,
        code: _codeController.text.trim(),
        note: _noteController.text.trim(),
      );
    }
  }
}

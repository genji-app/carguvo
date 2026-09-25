import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/modules/delivery_points/controllers/delivery_point_controller.dart';

class EditDeliveryPointView extends StatefulWidget {
  const EditDeliveryPointView({super.key});

  @override
  State<EditDeliveryPointView> createState() => _EditDeliveryPointViewState();
}

class _EditDeliveryPointViewState extends State<EditDeliveryPointView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  late String dpId;
  DeliveryStatus _selectedStatus = DeliveryStatus.pending;

  @override
  void initState() {
    super.initState();
    dpId = Get.arguments as String;
    final dp = Get.find<DeliveryPointRepository>().getById(dpId);
    if (dp != null) {
      _nameController.text = dp.receiverName;
      _phoneController.text = dp.phone;
      _addressController.text = dp.address;
      _noteController.text = dp.note;
      _selectedStatus = dp.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sửa điểm giao'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Tên người nhận', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(
                _phoneController,
                'Số điện thoại',
                Icons.phone,
                isPhone: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _addressController,
                'Địa chỉ chi tiết',
                Icons.business,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Text('Trạng thái', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              _buildStatusDropdown(),
              const SizedBox(height: 24),
              _buildTextField(
                _noteController,
                'Ghi chú',
                Icons.note,
                maxLines: 3,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Không được để trống' : null,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<DeliveryStatus>(
      value: _selectedStatus,
      items: DeliveryStatus.values
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(StatusHelper.deliveryStatusLabel(s)),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _selectedStatus = val!),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.info_outline, size: 20),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Get.find<DeliveryPointController>().updateDeliveryPoint(
        dpId,
        receiverName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        note: _noteController.text.trim(),
        status: _selectedStatus,
      );
    }
  }
}

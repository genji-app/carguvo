import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/data/models/delivery_point_model.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/data/repositories/trip_repository.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/widgets/app_text_field.dart';
import 'package:carguvo/widgets/app_button.dart';
import 'package:carguvo/widgets/app_card.dart';

class CargoFormView extends StatefulWidget {
  const CargoFormView({super.key});

  @override
  State<CargoFormView> createState() => _CargoFormViewState();
}

class _CargoFormViewState extends State<CargoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  // For quick customer selection
  final _receiverNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _cargoId;
  String? _selectedTripId;
  String? _selectedDeliveryPointId;
  CargoStatus _selectedStatus = CargoStatus.pending;

  bool get isEdit => _cargoId != null;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;

    if (args is String) {
      final cargo = Get.find<CargoRepository>().getById(args);
      if (cargo != null) {
        // Edit Mode
        _cargoId = cargo.id;
        _selectedTripId = cargo.tripId;
        _codeController.text = cargo.cargoCode;
        _nameController.text = cargo.cargoName;
        _typeController.text = cargo.cargoType;
        _quantityController.text = cargo.quantity.toString();
        _noteController.text = cargo.note;
        _selectedDeliveryPointId = cargo.deliveryPointId;
        _selectedStatus = cargo.status;
      } else {
        // Add Mode from Trip detail
        _selectedTripId = args;
        _selectedStatus = CargoStatus.loaded;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    _receiverNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onCustomerSelected(DeliveryPointModel customer) {
    setState(() {
      _selectedDeliveryPointId =
          null; // We create a NEW DP for the current trip
      _receiverNameController.text = customer.receiverName;
      _phoneController.text = customer.phone;
      _addressController.text = customer.address;
    });
    Get.back(); // Close bottom sheet
  }

  void _showCustomerHistory() {
    final dpRepo = Get.find<DeliveryPointRepository>();
    final history = dpRepo.getUniqueHistoryCustomers();

    if (history.isEmpty) {
      Get.snackbar('Thông báo', 'Chưa có lịch sử khách hàng');
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Chọn từ khách hàng cũ', style: AppTypography.heading3),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: history.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final c = history[index];
                  return ListTile(
                    title: Text(
                      c.receiverName,
                      style: AppTypography.labelLarge,
                    ),
                    subtitle: Text(
                      '${c.phone}\n${c.address}',
                      style: AppTypography.bodySmall,
                    ),
                    isThreeLine: true,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                    onTap: () => _onCustomerSelected(c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripRepo = Get.find<TripRepository>();
    final trips = tripRepo.getAll();
    final deliveryRepo = Get.find<DeliveryPointRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Sửa hàng hóa' : 'Thêm hàng hóa',
          style: AppTypography.heading3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Chuyến xe & Điểm giao'),
              const SizedBox(height: 12),

              // Trip Selection
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
                onChanged: isEdit
                    ? null
                    : (value) {
                        setState(() {
                          _selectedTripId = value;
                          _selectedDeliveryPointId = null;
                        });
                      },
                decoration: const InputDecoration(
                  labelText: 'Chọn chuyến xe *',
                ),
                validator: (val) =>
                    val == null ? 'Vui lòng chọn chuyến xe' : null,
              ),
              const SizedBox(height: 16),

              // Delivery Point Selection
              if (_selectedTripId != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          final points = deliveryRepo.getByTripId(
                            _selectedTripId!,
                          );
                          return DropdownButtonFormField<String>(
                            value: _selectedDeliveryPointId,
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('-- Tạo mới / Không chọn --'),
                              ),
                              ...points.map(
                                (d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(d.receiverName),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(() {
                              _selectedDeliveryPointId = value;
                              if (value != null && value.isNotEmpty) {
                                _receiverNameController.clear();
                                _phoneController.clear();
                                _addressController.clear();
                              }
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Chọn điểm giao có sẵn',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                if (_selectedDeliveryPointId == null ||
                    _selectedDeliveryPointId!.isEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hoặc nhập thông tin mới:',
                        style: AppTypography.bodySmall,
                      ),
                      TextButton.icon(
                        onPressed: _showCustomerHistory,
                        icon: const Icon(Icons.history, size: 16),
                        label: const Text('Khách hàng cũ'),
                      ),
                    ],
                  ),
                  _buildCustomerFields(),
                ],
              ],

              const SizedBox(height: 24),
              _buildSectionTitle('Chi tiết hàng hóa'),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Mã kiện *',
                hint: 'VD: K001',
                controller: _codeController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Tên hàng *',
                hint: 'VD: Thùng sơn A',
                controller: _nameController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Loại hàng',
                      controller: _typeController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Số lượng',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CargoStatus>(
                value: _selectedStatus,
                items: CargoStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(StatusHelper.cargoStatusLabel(s)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
                decoration: const InputDecoration(labelText: 'Trạng thái'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Ghi chú',
                controller: _noteController,
                maxLines: 2,
              ),

              const SizedBox(height: 40),
              AppButton(
                text: isEdit ? 'Lưu thay đổi' : 'Thêm hàng hóa',
                icon: isEdit ? Icons.check : Icons.add,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
        ),
        const Divider(color: AppColors.primary, thickness: 0.5),
      ],
    );
  }

  Widget _buildCustomerFields() {
    return AppCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Column(
        children: [
          AppTextField(
            label: 'Tên người nhận',
            controller: _receiverNameController,
            hint: 'Nhập tên hoặc chọn từ lịch sử',
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'SĐT',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Địa chỉ',
            controller: _addressController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final ctrl = Get.find<CargoController>();

      if (isEdit) {
        ctrl.updateCargo(
          _cargoId!,
          cargoCode: _codeController.text.trim(),
          cargoName: _nameController.text.trim(),
          cargoType: _typeController.text.trim(),
          quantity: int.tryParse(_quantityController.text) ?? 1,
          deliveryPointId: _selectedDeliveryPointId,
          receiverName: _receiverNameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          note: _noteController.text.trim(),
          status: _selectedStatus,
        );
      } else {
        ctrl.addCargo(
          tripId: _selectedTripId!,
          cargoCode: _codeController.text.trim(),
          cargoName: _nameController.text.trim(),
          cargoType: _typeController.text.trim(),
          quantity: int.tryParse(_quantityController.text) ?? 1,
          deliveryPointId: _selectedDeliveryPointId,
          receiverName: _receiverNameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          note: _noteController.text.trim(),
          initialStatus: _selectedStatus,
        );
      }
    }
  }
}

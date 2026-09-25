import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carguvo/core/theme/app_colors.dart';
import 'package:carguvo/core/theme/app_dimensions.dart';
import 'package:carguvo/core/theme/app_typography.dart';
import 'package:carguvo/core/enums/enums.dart';
import 'package:carguvo/core/helpers/status_helper.dart';
import 'package:carguvo/data/models/trip_model.dart';
import 'package:carguvo/data/repositories/cargo_repository.dart';
import 'package:carguvo/data/repositories/delivery_point_repository.dart';
import 'package:carguvo/data/repositories/timeline_repository.dart';
import 'package:carguvo/modules/trips/controllers/trip_controller.dart';
import 'package:carguvo/modules/cargo/controllers/cargo_controller.dart';
import 'package:carguvo/modules/delivery_points/controllers/delivery_point_controller.dart';
import 'package:carguvo/modules/timeline/controllers/timeline_controller.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/widgets/app_card.dart';
import 'package:carguvo/widgets/status_badge.dart';
import 'package:carguvo/widgets/progress_bar.dart';
import 'package:carguvo/widgets/empty_state.dart';
import 'package:carguvo/core/extensions/date_extensions.dart';

class TripDetailView extends StatefulWidget {
  const TripDetailView({super.key});

  @override
  State<TripDetailView> createState() => _TripDetailViewState();
}

class _TripDetailViewState extends State<TripDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String tripId;

  @override
  void initState() {
    super.initState();
    tripId = Get.arguments as String;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tripCtrl = Get.find<TripController>();
      // Trigger dependency on trips list
      tripCtrl.trips.length;

      final trip = tripCtrl.trips.firstWhereOrNull((t) => t.id == tripId);

      if (trip == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Chuyến xe')),
          body: const Center(child: Text('Không tìm thấy chuyến xe')),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('#${trip.code}', style: AppTypography.heading3),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) => _handleAction(value, trip),
              itemBuilder: (_) => [
                if (trip.status == TripStatus.active)
                  const PopupMenuItem(
                    value: 'complete',
                    child: Text('Hoàn thành'),
                  ),
                if (trip.status == TripStatus.active)
                  const PopupMenuItem(value: 'pause', child: Text('Tạm dừng')),
                if (trip.status == TripStatus.paused)
                  const PopupMenuItem(value: 'resume', child: Text('Tiếp tục')),
                const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Hàng hóa'),
              Tab(text: 'Điểm giao'),
              Tab(text: 'Timeline'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildTripHeader(trip),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CargoTab(tripId: tripId),
                  _DeliveryTab(tripId: tripId),
                  _TimelineTab(tripId: tripId),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton:
            (_tabController.index == 0 || _tabController.index == 1)
            ? FloatingActionButton(
                heroTag: 'fab_trip_detail',
                onPressed: () {
                  if (_tabController.index == 0) {
                    Get.toNamed(AppRoutes.addCargo, arguments: tripId);
                  } else if (_tabController.index == 1) {
                    Get.toNamed(AppRoutes.addDeliveryPoint, arguments: tripId);
                  }
                },
                child: const Icon(Icons.add),
              )
            : null,
      );
    });
  }

  Widget _buildTripHeader(TripModel trip) {
    final tripCtrl = Get.find<TripController>();
    final total = tripCtrl.getTotalCargo(trip.id);
    final delivered = tripCtrl.getDeliveredCargo(trip.id);
    final progress = tripCtrl.getTripProgress(trip.id);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      color: AppColors.card,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                label: StatusHelper.tripStatusLabel(trip.status),
                color: StatusHelper.tripStatusColor(trip.status),
                icon: StatusHelper.tripStatusIcon(trip.status),
              ),
              Text(
                'Ngày tạo: ${trip.createdAt.formatted}',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMD),
          Row(
            children: [
              _miniStat('Tổng', '$total', AppColors.secondary),
              const SizedBox(width: 8),
              _miniStat('Đã giao', '$delivered', AppColors.success),
              const SizedBox(width: 8),
              _miniStat('Còn lại', '${total - delivered}', AppColors.primary),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          AppProgressBar(progress: progress, showLabel: true),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: AppTypography.caption),
            Text(value, style: AppTypography.labelLarge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, TripModel trip) {
    final tripCtrl = Get.find<TripController>();
    switch (action) {
      case 'complete':
        tripCtrl.updateTripStatus(trip.id, TripStatus.completed);
        setState(() {});
        break;
      case 'pause':
        tripCtrl.updateTripStatus(trip.id, TripStatus.paused);
        setState(() {});
        break;
      case 'resume':
        tripCtrl.updateTripStatus(trip.id, TripStatus.active);
        setState(() {});
        break;
      case 'delete':
        Get.defaultDialog(
          title: 'Xóa chuyến xe?',
          middleText: 'Toàn bộ hàng hóa và điểm giao sẽ bị xóa.',
          textCancel: 'Hủy',
          textConfirm: 'Xóa',
          confirmTextColor: Colors.white,
          buttonColor: AppColors.error,
          onConfirm: () {
            Get.back();
            tripCtrl.deleteTrip(trip.id);
            Get.back();
          },
        );
        break;
      case 'edit':
        Get.toNamed(AppRoutes.editTrip, arguments: trip.id);
        break;
    }
  }
}

// ── Cargo Tab ──

class _CargoTab extends StatelessWidget {
  final String tripId;
  const _CargoTab({required this.tripId});

  @override
  Widget build(BuildContext context) {
    final cargoRepo = Get.find<CargoRepository>();
    final deliveryRepo = Get.find<DeliveryPointRepository>();

    return Obx(() {
      Get.find<CargoController>().cargoList.length; // Explicit dependency
      final cargos = cargoRepo.getByTripId(tripId);
      if (cargos.isEmpty) {
        return EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Chưa có hàng hóa',
          subtitle: 'Thêm hàng hóa vào chuyến xe này',
          actionLabel: 'Thêm hàng',
          onAction: () => Get.toNamed(AppRoutes.addCargo, arguments: tripId),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        itemCount: cargos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final cargo = cargos[index];
          final dp = deliveryRepo.getById(cargo.deliveryPointId);

          return InkWell(
            onTap: () =>
                Get.toNamed(AppRoutes.cargoDetail, arguments: cargo.id),
            child: AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${cargo.cargoCode}',
                              style: AppTypography.labelMedium,
                            ),
                            StatusBadge(
                              label: StatusHelper.cargoStatusLabel(
                                cargo.status,
                              ),
                              color: StatusHelper.cargoStatusColor(
                                cargo.status,
                              ),
                              icon: StatusHelper.cargoStatusIcon(cargo.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cargo.cargoName,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SL: ${cargo.quantity}',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            if (dp != null) ...[
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  dp.receiverName,
                                  style: AppTypography.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// ── Delivery Points Tab ──

class _DeliveryTab extends StatelessWidget {
  final String tripId;
  const _DeliveryTab({required this.tripId});

  @override
  Widget build(BuildContext context) {
    final deliveryRepo = Get.find<DeliveryPointRepository>();
    final cargoRepo = Get.find<CargoRepository>();

    return Obx(() {
      Get.find<DeliveryPointController>()
          .deliveryPoints
          .length; // Explicit dependency
      final points = deliveryRepo.getByTripId(tripId);
      if (points.isEmpty) {
        return EmptyState(
          icon: Icons.location_on_outlined,
          title: 'Chưa có điểm giao',
          subtitle: 'Thêm điểm giao cho chuyến xe này',
          actionLabel: 'Thêm điểm giao',
          onAction: () =>
              Get.toNamed(AppRoutes.addDeliveryPoint, arguments: tripId),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        itemCount: points.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final dp = points[index];
          final cargos = cargoRepo.getByDeliveryPointId(dp.id);
          final deliveredCount = cargos
              .where((c) => c.status == CargoStatus.delivered)
              .length;

          return InkWell(
            onTap: () =>
                Get.toNamed(AppRoutes.deliveryPointDetail, arguments: dp.id),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dp.receiverName,
                            style: AppTypography.labelLarge,
                          ),
                        ],
                      ),
                      StatusBadge(
                        label: StatusHelper.deliveryStatusLabel(dp.status),
                        color: StatusHelper.deliveryStatusColor(dp.status),
                      ),
                    ],
                  ),
                  if (dp.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 6),
                        Text(dp.phone, style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                  if (dp.address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dp.address,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng: ${cargos.length} kiện · Đã giao: $deliveredCount',
                        style: AppTypography.caption,
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// ── Timeline Tab ──

class _TimelineTab extends StatelessWidget {
  final String tripId;
  const _TimelineTab({required this.tripId});

  @override
  Widget build(BuildContext context) {
    final timelineRepo = Get.find<TimelineRepository>();
    final cargoRepo = Get.find<CargoRepository>();

    return Obx(() {
      Get.find<TimelineController>()
          .timelineEntries
          .length; // Explicit dependency
      final entries = timelineRepo.getByTripId(tripId);
      if (entries.isEmpty) {
        return const EmptyState(
          icon: Icons.timeline,
          title: 'Chưa có hoạt động',
          subtitle: 'Các thao tác trên hàng hóa sẽ hiển thị ở đây',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        itemCount: entries.length,
        itemBuilder: (_, index) {
          final entry = entries[index];
          final cargo = cargoRepo.getById(entry.cargoId);
          final color = StatusHelper.timelineActionColor(entry.action);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      StatusHelper.timelineActionIcon(entry.action),
                      size: 16,
                      color: color,
                    ),
                  ),
                  if (index < entries.length - 1)
                    Container(width: 2, height: 40, color: AppColors.divider),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StatusHelper.timelineActionLabel(entry.action),
                        style: AppTypography.labelMedium.copyWith(color: color),
                      ),
                      if (cargo != null)
                        Text(
                          '#${cargo.cargoCode} - ${cargo.cargoName}',
                          style: AppTypography.bodySmall,
                        ),
                      Text(
                        entry.createdAt.formattedWithTime,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

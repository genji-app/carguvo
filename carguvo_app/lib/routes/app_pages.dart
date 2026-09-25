import 'package:get/get.dart';
import 'package:carguvo/routes/app_routes.dart';
import 'package:carguvo/modules/splash/bindings/splash_binding.dart';
import 'package:carguvo/modules/splash/views/splash_view.dart';
import 'package:carguvo/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:carguvo/modules/onboarding/views/onboarding_view.dart';
import 'package:carguvo/modules/main/bindings/main_binding.dart';
import 'package:carguvo/modules/main/views/main_view.dart';
import 'package:carguvo/modules/trips/views/trip_detail_view.dart';
import 'package:carguvo/modules/trips/views/create_trip_view.dart';
import 'package:carguvo/modules/trips/views/edit_trip_view.dart';
import 'package:carguvo/modules/cargo/views/cargo_form_view.dart';
import 'package:carguvo/modules/cargo/views/cargo_detail_view.dart';
import 'package:carguvo/modules/cargo/views/cargo_on_truck_view.dart';
import 'package:carguvo/modules/delivery_points/views/add_delivery_point_view.dart';
import 'package:carguvo/modules/delivery_points/views/delivery_point_detail_view.dart';
import 'package:carguvo/modules/delivery_points/views/edit_delivery_point_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(name: AppRoutes.createTrip, page: () => const CreateTripView()),
    GetPage(name: AppRoutes.editTrip, page: () => const EditTripView()),
    GetPage(name: AppRoutes.tripDetail, page: () => const TripDetailView()),
    GetPage(name: AppRoutes.cargoDetail, page: () => const CargoDetailView()),
    GetPage(name: AppRoutes.addCargo, page: () => const CargoFormView()),
    GetPage(name: AppRoutes.editCargo, page: () => const CargoFormView()),
    GetPage(
      name: AppRoutes.addDeliveryPoint,
      page: () => const AddDeliveryPointView(),
    ),
    GetPage(
      name: AppRoutes.editDeliveryPoint,
      page: () => const EditDeliveryPointView(),
    ),
    GetPage(
      name: AppRoutes.deliveryPointDetail,
      page: () => const DeliveryPointDetailView(),
    ),
    GetPage(name: AppRoutes.cargoOnTruck, page: () => const CargoOnTruckView()),
  ];
}

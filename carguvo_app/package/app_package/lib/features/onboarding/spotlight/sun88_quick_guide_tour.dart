import 'spotlight_core.dart';

const SpotlightTour sun88QuickGuideTour = SpotlightTour(
  id: 'sun88_quick_guide_v1',
  steps: [
    SpotlightStep(
      target: SpotlightTargetId.balanceDeposit,
      title: 'Nạp và thông tin số dư',
      body:
          'Nạp tiền thông qua các hình thức tiện lợi. Số dư luôn được cập nhật khi giao dịch thành công.',
      placement: SpotlightPlacement.bottom,
    ),
    SpotlightStep(
      target: SpotlightTargetId.betSlipButton,
      title: 'Quản lý phiếu cược',
      body:
          'Nơi bạn có thể xem phiếu đang cược, lịch sử cược và thông tin thanh toán.',
      placement: SpotlightPlacement.bottom,
      onEnter: _closeBetSlip,
    ),
    SpotlightStep(
      target: SpotlightTargetId.betSlipPanelTabs,
      title: 'Phiếu cược',
      body:
          'Nơi các lựa chọn cược được thêm vào giỏ. Bạn có thể cược đơn và cược xiên ở đây.',
      placement: SpotlightPlacement.left,
      sceneChange: true,
      onEnter: _openMatchWithBetSlip,
    ),
    SpotlightStep(
      target: SpotlightTargetId.betSlipPanelTabs,
      title: 'Cược của tôi',
      body:
          'Nơi các phiếu cược đã đặt đang chờ xác nhận hoặc chờ nhận kết quả.',
      placement: SpotlightPlacement.left,
      onEnter: _showMyBets,
    ),
    SpotlightStep(
      target: SpotlightTargetId.avatarProfile,
      title: 'Thông tin đăng nhập và cài đặt',
      body:
          'Xác minh tài khoản, thông tin đăng nhập và quản lý cài đặt của ứng dụng.',
      placement: SpotlightPlacement.bottom,
      onEnter: _closeBetSlip,
    ),
    SpotlightStep(
      target: SpotlightTargetId.balanceDeposit,
      title: 'Bắt đầu cược ngay',
      body:
          'Đừng bỏ lỡ tỷ lệ cược tốt nhất đến từ Sun88 – Thương hiệu cá cược thể thao uy tín của Sunwin. Nạp tiền để cược ngay!',
      placement: SpotlightPlacement.bottom,
      sceneChange: true,
      onEnter: _goHome,
    ),
  ],
);

const SpotlightTour sun88QuickGuideTourMobile = SpotlightTour(
  id: 'sun88_quick_guide_mobile_v1',
  steps: [
    SpotlightStep(
      target: SpotlightTargetId.balanceDeposit,
      title: 'Nạp và thông tin số dư',
      body:
          'Nạp tiền thông qua các hình thức tiện lợi. Số dư luôn được cập nhật khi giao dịch thành công.',
      placement: SpotlightPlacement.bottom,
    ),
    SpotlightStep(
      target: SpotlightTargetId.betSlipButton,
      title: 'Quản lý phiếu cược',
      body:
          'Nơi bạn có thể xem phiếu đang cược, lịch sử cược và thông tin thanh toán.',
      placement: SpotlightPlacement.top,
      onEnter: _closeBetSlip,
    ),
    SpotlightStep(
      target: SpotlightTargetId.betSlipTab,
      title: 'Phiếu cược',
      body:
          'Nơi các lựa chọn cược được thêm vào giỏ. Bạn có thể cược đơn và cược xiên ở đây.',
      placement: SpotlightPlacement.bottom,
      sceneChange: true,
      onEnter: _openMatchWithBetSlip,
    ),
    SpotlightStep(
      target: SpotlightTargetId.myBetsTabItem,
      title: 'Cược của tôi',
      body:
          'Nơi các phiếu cược đã đặt đang chờ xác nhận hoặc chờ nhận kết quả.',
      placement: SpotlightPlacement.bottom,
      onEnter: _showMyBets,
    ),
    SpotlightStep(
      target: SpotlightTargetId.avatarProfile,
      title: 'Thông tin đăng nhập và cài đặt',
      body:
          'Xác minh tài khoản, thông tin đăng nhập và quản lý cài đặt của ứng dụng.',
      placement: SpotlightPlacement.bottom,
      onEnter: _closeBetSlip,
    ),
    SpotlightStep(
      target: SpotlightTargetId.balanceDeposit,
      title: 'Bắt đầu cược ngay',
      body:
          'Đừng bỏ lỡ tỷ lệ cược tốt nhất đến từ Sun88 – Thương hiệu các cược thể thao uy tín của Sunwin. Nạp tiền để cược ngay!',
      placement: SpotlightPlacement.bottom,
      sceneChange: true,
      onEnter: _goHome,
    ),
  ],
);

const SpotlightTour searchQuickGuideTour = SpotlightTour(
  id: 'search_quick_guide_v1',
  steps: [
    SpotlightStep(
      target: SpotlightTargetId.searchButton,
      title: 'Tìm kiếm nhanh',
      body: 'Tìm kiếm giải đấu, trận đấu và casino games',
      placement: SpotlightPlacement.bottom,
    ),
  ],
);

Future<void> _openMatchWithBetSlip(SpotlightNavigator nav) =>
    nav.openSampleMatchWithBetSlip();

Future<void> _showMyBets(SpotlightNavigator nav) => nav.showMyBets();

Future<void> _closeBetSlip(SpotlightNavigator nav) => nav.closeBetSlip();

Future<void> _goHome(SpotlightNavigator nav) => nav.goHome();

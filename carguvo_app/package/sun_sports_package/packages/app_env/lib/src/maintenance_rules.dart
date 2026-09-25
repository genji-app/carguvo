library;

const int kSbMaintenanceCode = 418;

bool isSbUnavailableStatus(int statusCode) =>
    statusCode == kSbMaintenanceCode ||
    (statusCode >= 500 && statusCode < 600);

const String kSbMaintenanceDebugQueryParam = 'sb_maintain';

const String kSbMaintenanceDefaultMessage =
    'Hệ thống đang bảo trì.\nVui lòng quay lại sau!';

const String kSbMaintenanceShortMessage =
    'Hệ thống đang bảo trì. Vui lòng quay lại sau!';

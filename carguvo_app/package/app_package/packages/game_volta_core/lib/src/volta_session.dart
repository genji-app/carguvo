import 'volta_http.dart';
import 'volta_user_api.dart';

void voltaReleaseSession() {
  VoltaUserService.instance.reset();
  VoltaHttp.onUnauthorized = null;
}

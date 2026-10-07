import 'volta_http.dart';
import 'volta_platform.dart';

class VoltaAgent {
  const VoltaAgent._();

  static const int fallbackId = 32;

  static int get id {
    if (VoltaDebugOverrides.active) {
      final int? fromDebugToken = agentOfToken(VoltaDebugOverrides.token);
      if (fromDebugToken != null) return fromDebugToken;
    }

    final int? override = _toInt(
      VoltaPlatform.instance.mainConfig('volta_agent_id'),
    );
    if (override != null && override > 0) return override;

    final int brandAgent = VoltaPlatform.instance.agentId;
    if (brandAgent > 0) return brandAgent;

    return agentOfToken(VoltaPlatform.instance.userToken) ?? fallbackId;
  }

  static int? agentOfToken(String token) {
    final int dash = token.indexOf('-');
    if (dash <= 0) return null;
    return int.tryParse(token.substring(0, dash));
  }

  static int? _toInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

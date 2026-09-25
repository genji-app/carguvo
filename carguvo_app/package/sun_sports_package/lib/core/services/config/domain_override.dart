class DomainOverride {
  final String? hostDomain;
  final String? apiDomain;
  final String? sportDomain;
  final String? wsSportDomain;
  final String? mainWsUrl;

  const DomainOverride({
    this.hostDomain,
    this.apiDomain,
    this.sportDomain,
    this.wsSportDomain,
    this.mainWsUrl,
  });

  factory DomainOverride.fromBrandConfig(Map<String, dynamic> raw) {
    return DomainOverride(
      hostDomain: raw['host_domain'] as String?,
      apiDomain: raw['api_domain'] as String?,
      sportDomain: raw['sport_domain'] as String?,
      wsSportDomain: raw['ws_sport_domain'] as String?,
      mainWsUrl: raw['main_ws_url'] as String?,
    );
  }

  Map<String, dynamic> toMainConfigPatch() => {
    if (apiDomain?.isNotEmpty == true) 'api_domain': apiDomain,
    if (sportDomain?.isNotEmpty == true) 'sport_domain': sportDomain,
    if (wsSportDomain?.isNotEmpty == true) 'ws_sport_domain': wsSportDomain,
    if (mainWsUrl?.isNotEmpty == true) 'main_ws_url': mainWsUrl,
  };

  bool get hasHostDomainOverride =>
      hostDomain != null && hostDomain!.isNotEmpty;

  bool get hasMainConfigOverrides => toMainConfigPatch().isNotEmpty;
}

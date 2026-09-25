
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use payloadDescriptor instead')
const Payload$json = {
  '1': 'Payload',
  '2': [
    {
      '1': 'channel',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'channel',
      '17': true
    },
    {'1': 'type', '3': 2, '4': 1, '5': 9, '9': 2, '10': 'type', '17': true},
    {
      '1': 'time_range',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'timeRange',
      '17': true
    },
    {
      '1': 'league',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.app.proto.LeagueResponse',
      '9': 0,
      '10': 'league'
    },
    {
      '1': 'event',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '9': 0,
      '10': 'event'
    },
    {
      '1': 'hot_event',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.app.proto.HotEventsResponse',
      '9': 0,
      '10': 'hotEvent'
    },
    {
      '1': 'outright_event',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OutrightEventResponse',
      '9': 0,
      '10': 'outrightEvent'
    },
    {
      '1': 'bet_slip_status',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.app.proto.BetSlipStatusResponse',
      '9': 0,
      '10': 'betSlipStatus'
    },
    {
      '1': 'popular_leagues',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.app.proto.PopularLeaguesResponse',
      '9': 0,
      '10': 'popularLeagues'
    },
  ],
  '8': [
    {'1': 'data'},
    {'1': '_channel'},
    {'1': '_type'},
    {'1': '_time_range'},
  ],
};

final $typed_data.Uint8List payloadDescriptor = $convert.base64Decode(
    'CgdQYXlsb2FkEh0KB2NoYW5uZWwYASABKAlIAVIHY2hhbm5lbIgBARIXCgR0eXBlGAIgASgJSA'
    'JSBHR5cGWIAQESIgoKdGltZV9yYW5nZRgDIAEoBUgDUgl0aW1lUmFuZ2WIAQESMwoGbGVhZ3Vl'
    'GAQgASgLMhkuYXBwLnByb3RvLkxlYWd1ZVJlc3BvbnNlSABSBmxlYWd1ZRIwCgVldmVudBgFIA'
    'EoCzIYLmFwcC5wcm90by5FdmVudFJlc3BvbnNlSABSBWV2ZW50EjsKCWhvdF9ldmVudBgGIAEo'
    'CzIcLmFwcC5wcm90by5Ib3RFdmVudHNSZXNwb25zZUgAUghob3RFdmVudBJJCg5vdXRyaWdodF'
    '9ldmVudBgHIAEoCzIgLmFwcC5wcm90by5PdXRyaWdodEV2ZW50UmVzcG9uc2VIAFINb3V0cmln'
    'aHRFdmVudBJKCg9iZXRfc2xpcF9zdGF0dXMYCCABKAsyIC5hcHAucHJvdG8uQmV0U2xpcFN0YX'
    'R1c1Jlc3BvbnNlSABSDWJldFNsaXBTdGF0dXMSTAoPcG9wdWxhcl9sZWFndWVzGAkgASgLMiEu'
    'YXBwLnByb3RvLlBvcHVsYXJMZWFndWVzUmVzcG9uc2VIAFIOcG9wdWxhckxlYWd1ZXNCBgoEZG'
    'F0YUIKCghfY2hhbm5lbEIHCgVfdHlwZUINCgtfdGltZV9yYW5nZQ==');

@$core.Deprecated('Use leagueResponseDescriptor instead')
const LeagueResponse$json = {
  '1': 'LeagueResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '10': 'events'
    },
    {
      '1': 'sport_id',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'sportId',
      '17': true
    },
    {
      '1': 'sport_name',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'sportName',
      '17': true
    },
    {
      '1': 'league_id',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'leagueId',
      '17': true
    },
    {
      '1': 'league_name',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'leagueName',
      '17': true
    },
    {
      '1': 'league_name_en',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'leagueNameEn',
      '17': true
    },
    {
      '1': 'league_logo',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'leagueLogo',
      '17': true
    },
    {
      '1': 'league_order',
      '3': 8,
      '4': 1,
      '5': 5,
      '9': 6,
      '10': 'leagueOrder',
      '17': true
    },
    {
      '1': 'league_priority_order',
      '3': 9,
      '4': 1,
      '5': 5,
      '9': 7,
      '10': 'leaguePriorityOrder',
      '17': true
    },
    {'1': 'type', '3': 10, '4': 1, '5': 5, '9': 8, '10': 'type', '17': true},
    {
      '1': 'is_parlay',
      '3': 11,
      '4': 1,
      '5': 8,
      '9': 9,
      '10': 'isParlay',
      '17': true
    },
    {
      '1': 'is_cash_out',
      '3': 12,
      '4': 1,
      '5': 8,
      '9': 10,
      '10': 'isCashOut',
      '17': true
    },
    {
      '1': 'is_pin',
      '3': 13,
      '4': 1,
      '5': 8,
      '9': 11,
      '10': 'isPin',
      '17': true
    },
    {
      '1': 'sport_type',
      '3': 14,
      '4': 1,
      '5': 9,
      '9': 12,
      '10': 'sportType',
      '17': true
    },
    {
      '1': 'sport_type_id',
      '3': 15,
      '4': 1,
      '5': 5,
      '9': 13,
      '10': 'sportTypeId',
      '17': true
    },
  ],
  '8': [
    {'1': '_sport_id'},
    {'1': '_sport_name'},
    {'1': '_league_id'},
    {'1': '_league_name'},
    {'1': '_league_name_en'},
    {'1': '_league_logo'},
    {'1': '_league_order'},
    {'1': '_league_priority_order'},
    {'1': '_type'},
    {'1': '_is_parlay'},
    {'1': '_is_cash_out'},
    {'1': '_is_pin'},
    {'1': '_sport_type'},
    {'1': '_sport_type_id'},
  ],
};

final $typed_data.Uint8List leagueResponseDescriptor = $convert.base64Decode(
    'Cg5MZWFndWVSZXNwb25zZRIwCgZldmVudHMYASADKAsyGC5hcHAucHJvdG8uRXZlbnRSZXNwb2'
    '5zZVIGZXZlbnRzEh4KCHNwb3J0X2lkGAIgASgFSABSB3Nwb3J0SWSIAQESIgoKc3BvcnRfbmFt'
    'ZRgDIAEoCUgBUglzcG9ydE5hbWWIAQESIAoJbGVhZ3VlX2lkGAQgASgFSAJSCGxlYWd1ZUlkiA'
    'EBEiQKC2xlYWd1ZV9uYW1lGAUgASgJSANSCmxlYWd1ZU5hbWWIAQESKQoObGVhZ3VlX25hbWVf'
    'ZW4YBiABKAlIBFIMbGVhZ3VlTmFtZUVuiAEBEiQKC2xlYWd1ZV9sb2dvGAcgASgJSAVSCmxlYW'
    'd1ZUxvZ2+IAQESJgoMbGVhZ3VlX29yZGVyGAggASgFSAZSC2xlYWd1ZU9yZGVyiAEBEjcKFWxl'
    'YWd1ZV9wcmlvcml0eV9vcmRlchgJIAEoBUgHUhNsZWFndWVQcmlvcml0eU9yZGVyiAEBEhcKBH'
    'R5cGUYCiABKAVICFIEdHlwZYgBARIgCglpc19wYXJsYXkYCyABKAhICVIIaXNQYXJsYXmIAQES'
    'IwoLaXNfY2FzaF9vdXQYDCABKAhIClIJaXNDYXNoT3V0iAEBEhoKBmlzX3BpbhgNIAEoCEgLUg'
    'Vpc1BpbogBARIiCgpzcG9ydF90eXBlGA4gASgJSAxSCXNwb3J0VHlwZYgBARInCg1zcG9ydF90'
    'eXBlX2lkGA8gASgFSA1SC3Nwb3J0VHlwZUlkiAEBQgsKCV9zcG9ydF9pZEINCgtfc3BvcnRfbm'
    'FtZUIMCgpfbGVhZ3VlX2lkQg4KDF9sZWFndWVfbmFtZUIRCg9fbGVhZ3VlX25hbWVfZW5CDgoM'
    'X2xlYWd1ZV9sb2dvQg8KDV9sZWFndWVfb3JkZXJCGAoWX2xlYWd1ZV9wcmlvcml0eV9vcmRlck'
    'IHCgVfdHlwZUIMCgpfaXNfcGFybGF5Qg4KDF9pc19jYXNoX291dEIJCgdfaXNfcGluQg0KC19z'
    'cG9ydF90eXBlQhAKDl9zcG9ydF90eXBlX2lk');

@$core.Deprecated('Use eventResponseDescriptor instead')
const EventResponse$json = {
  '1': 'EventResponse',
  '2': [
    {
      '1': 'children',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '10': 'children'
    },
    {
      '1': 'markets',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.app.proto.MarketResponse',
      '10': 'markets'
    },
    {
      '1': 'sport_id',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'sportId',
      '17': true
    },
    {
      '1': 'league_id',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'leagueId',
      '17': true
    },
    {
      '1': 'event_id',
      '3': 5,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'eventId',
      '17': true
    },
    {
      '1': 'start_date',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'startDate',
      '17': true
    },
    {
      '1': 'start_time',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 4,
      '10': 'startTime',
      '17': true
    },
    {
      '1': 'is_suspended',
      '3': 8,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'isSuspended',
      '17': true
    },
    {
      '1': 'is_hidden',
      '3': 9,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'isHidden',
      '17': true
    },
    {
      '1': 'is_parlay',
      '3': 10,
      '4': 1,
      '5': 8,
      '9': 7,
      '10': 'isParlay',
      '17': true
    },
    {
      '1': 'is_cash_out',
      '3': 11,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'isCashOut',
      '17': true
    },
    {'1': 'type', '3': 12, '4': 1, '5': 5, '9': 9, '10': 'type', '17': true},
    {
      '1': 'pin_type',
      '3': 13,
      '4': 1,
      '5': 5,
      '9': 10,
      '10': 'pinType',
      '17': true
    },
    {
      '1': 'special_situation',
      '3': 14,
      '4': 1,
      '5': 9,
      '9': 11,
      '10': 'specialSituation',
      '17': true
    },
    {
      '1': 'event_stats_id',
      '3': 15,
      '4': 1,
      '5': 3,
      '9': 12,
      '10': 'eventStatsId',
      '17': true
    },
    {
      '1': 'sport_type_id',
      '3': 16,
      '4': 1,
      '5': 5,
      '9': 13,
      '10': 'sportTypeId',
      '17': true
    },
    {
      '1': 'sport_type_name',
      '3': 17,
      '4': 1,
      '5': 9,
      '9': 14,
      '10': 'sportTypeName',
      '17': true
    },
    {
      '1': 'home_id',
      '3': 18,
      '4': 1,
      '5': 5,
      '9': 15,
      '10': 'homeId',
      '17': true
    },
    {
      '1': 'away_id',
      '3': 19,
      '4': 1,
      '5': 5,
      '9': 16,
      '10': 'awayId',
      '17': true
    },
    {
      '1': 'home_name',
      '3': 20,
      '4': 1,
      '5': 9,
      '9': 17,
      '10': 'homeName',
      '17': true
    },
    {
      '1': 'away_name',
      '3': 21,
      '4': 1,
      '5': 9,
      '9': 18,
      '10': 'awayName',
      '17': true
    },
    {
      '1': 'home_logo',
      '3': 22,
      '4': 1,
      '5': 9,
      '9': 19,
      '10': 'homeLogo',
      '17': true
    },
    {
      '1': 'away_logo',
      '3': 23,
      '4': 1,
      '5': 9,
      '9': 20,
      '10': 'awayLogo',
      '17': true
    },
    {
      '1': 'market_count',
      '3': 24,
      '4': 1,
      '5': 5,
      '9': 21,
      '10': 'marketCount',
      '17': true
    },
    {'1': 'market_groups', '3': 25, '4': 3, '5': 5, '10': 'marketGroups'},
    {
      '1': 'time_market_groups',
      '3': 26,
      '4': 3,
      '5': 5,
      '10': 'timeMarketGroups'
    },
    {
      '1': 'is_hot',
      '3': 27,
      '4': 1,
      '5': 8,
      '9': 22,
      '10': 'isHot',
      '17': true
    },
    {
      '1': 'is_going_live',
      '3': 28,
      '4': 1,
      '5': 8,
      '9': 23,
      '10': 'isGoingLive',
      '17': true
    },
    {
      '1': 'is_live',
      '3': 29,
      '4': 1,
      '5': 8,
      '9': 24,
      '10': 'isLive',
      '17': true
    },
    {
      '1': 'is_live_stream',
      '3': 30,
      '4': 1,
      '5': 8,
      '9': 25,
      '10': 'isLiveStream',
      '17': true
    },
    {
      '1': 'game_part',
      '3': 31,
      '4': 1,
      '5': 5,
      '9': 26,
      '10': 'gamePart',
      '17': true
    },
    {
      '1': 'game_time',
      '3': 32,
      '4': 1,
      '5': 5,
      '9': 27,
      '10': 'gameTime',
      '17': true
    },
    {
      '1': 'stoppage_time',
      '3': 33,
      '4': 1,
      '5': 5,
      '9': 28,
      '10': 'stoppageTime',
      '17': true
    },
    {
      '1': 'live_score',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.app.proto.ScoreResponse',
      '9': 29,
      '10': 'liveScore',
      '17': true
    },
    {
      '1': 'child_type',
      '3': 35,
      '4': 1,
      '5': 5,
      '9': 30,
      '10': 'childType',
      '17': true
    },
  ],
  '8': [
    {'1': '_sport_id'},
    {'1': '_league_id'},
    {'1': '_event_id'},
    {'1': '_start_date'},
    {'1': '_start_time'},
    {'1': '_is_suspended'},
    {'1': '_is_hidden'},
    {'1': '_is_parlay'},
    {'1': '_is_cash_out'},
    {'1': '_type'},
    {'1': '_pin_type'},
    {'1': '_special_situation'},
    {'1': '_event_stats_id'},
    {'1': '_sport_type_id'},
    {'1': '_sport_type_name'},
    {'1': '_home_id'},
    {'1': '_away_id'},
    {'1': '_home_name'},
    {'1': '_away_name'},
    {'1': '_home_logo'},
    {'1': '_away_logo'},
    {'1': '_market_count'},
    {'1': '_is_hot'},
    {'1': '_is_going_live'},
    {'1': '_is_live'},
    {'1': '_is_live_stream'},
    {'1': '_game_part'},
    {'1': '_game_time'},
    {'1': '_stoppage_time'},
    {'1': '_live_score'},
    {'1': '_child_type'},
  ],
};

final $typed_data.Uint8List eventResponseDescriptor = $convert.base64Decode(
    'Cg1FdmVudFJlc3BvbnNlEjQKCGNoaWxkcmVuGAEgAygLMhguYXBwLnByb3RvLkV2ZW50UmVzcG'
    '9uc2VSCGNoaWxkcmVuEjMKB21hcmtldHMYAiADKAsyGS5hcHAucHJvdG8uTWFya2V0UmVzcG9u'
    'c2VSB21hcmtldHMSHgoIc3BvcnRfaWQYAyABKAVIAFIHc3BvcnRJZIgBARIgCglsZWFndWVfaW'
    'QYBCABKAVIAVIIbGVhZ3VlSWSIAQESHgoIZXZlbnRfaWQYBSABKANIAlIHZXZlbnRJZIgBARIi'
    'CgpzdGFydF9kYXRlGAYgASgJSANSCXN0YXJ0RGF0ZYgBARIiCgpzdGFydF90aW1lGAcgASgDSA'
    'RSCXN0YXJ0VGltZYgBARImCgxpc19zdXNwZW5kZWQYCCABKAhIBVILaXNTdXNwZW5kZWSIAQES'
    'IAoJaXNfaGlkZGVuGAkgASgISAZSCGlzSGlkZGVuiAEBEiAKCWlzX3BhcmxheRgKIAEoCEgHUg'
    'hpc1BhcmxheYgBARIjCgtpc19jYXNoX291dBgLIAEoCEgIUglpc0Nhc2hPdXSIAQESFwoEdHlw'
    'ZRgMIAEoBUgJUgR0eXBliAEBEh4KCHBpbl90eXBlGA0gASgFSApSB3BpblR5cGWIAQESMAoRc3'
    'BlY2lhbF9zaXR1YXRpb24YDiABKAlIC1IQc3BlY2lhbFNpdHVhdGlvbogBARIpCg5ldmVudF9z'
    'dGF0c19pZBgPIAEoA0gMUgxldmVudFN0YXRzSWSIAQESJwoNc3BvcnRfdHlwZV9pZBgQIAEoBU'
    'gNUgtzcG9ydFR5cGVJZIgBARIrCg9zcG9ydF90eXBlX25hbWUYESABKAlIDlINc3BvcnRUeXBl'
    'TmFtZYgBARIcCgdob21lX2lkGBIgASgFSA9SBmhvbWVJZIgBARIcCgdhd2F5X2lkGBMgASgFSB'
    'BSBmF3YXlJZIgBARIgCglob21lX25hbWUYFCABKAlIEVIIaG9tZU5hbWWIAQESIAoJYXdheV9u'
    'YW1lGBUgASgJSBJSCGF3YXlOYW1liAEBEiAKCWhvbWVfbG9nbxgWIAEoCUgTUghob21lTG9nb4'
    'gBARIgCglhd2F5X2xvZ28YFyABKAlIFFIIYXdheUxvZ2+IAQESJgoMbWFya2V0X2NvdW50GBgg'
    'ASgFSBVSC21hcmtldENvdW50iAEBEiMKDW1hcmtldF9ncm91cHMYGSADKAVSDG1hcmtldEdyb3'
    'VwcxIsChJ0aW1lX21hcmtldF9ncm91cHMYGiADKAVSEHRpbWVNYXJrZXRHcm91cHMSGgoGaXNf'
    'aG90GBsgASgISBZSBWlzSG90iAEBEicKDWlzX2dvaW5nX2xpdmUYHCABKAhIF1ILaXNHb2luZ0'
    'xpdmWIAQESHAoHaXNfbGl2ZRgdIAEoCEgYUgZpc0xpdmWIAQESKQoOaXNfbGl2ZV9zdHJlYW0Y'
    'HiABKAhIGVIMaXNMaXZlU3RyZWFtiAEBEiAKCWdhbWVfcGFydBgfIAEoBUgaUghnYW1lUGFydI'
    'gBARIgCglnYW1lX3RpbWUYICABKAVIG1IIZ2FtZVRpbWWIAQESKAoNc3RvcHBhZ2VfdGltZRgh'
    'IAEoBUgcUgxzdG9wcGFnZVRpbWWIAQESPAoKbGl2ZV9zY29yZRgiIAEoCzIYLmFwcC5wcm90by'
    '5TY29yZVJlc3BvbnNlSB1SCWxpdmVTY29yZYgBARIiCgpjaGlsZF90eXBlGCMgASgFSB5SCWNo'
    'aWxkVHlwZYgBAUILCglfc3BvcnRfaWRCDAoKX2xlYWd1ZV9pZEILCglfZXZlbnRfaWRCDQoLX3'
    'N0YXJ0X2RhdGVCDQoLX3N0YXJ0X3RpbWVCDwoNX2lzX3N1c3BlbmRlZEIMCgpfaXNfaGlkZGVu'
    'QgwKCl9pc19wYXJsYXlCDgoMX2lzX2Nhc2hfb3V0QgcKBV90eXBlQgsKCV9waW5fdHlwZUIUCh'
    'Jfc3BlY2lhbF9zaXR1YXRpb25CEQoPX2V2ZW50X3N0YXRzX2lkQhAKDl9zcG9ydF90eXBlX2lk'
    'QhIKEF9zcG9ydF90eXBlX25hbWVCCgoIX2hvbWVfaWRCCgoIX2F3YXlfaWRCDAoKX2hvbWVfbm'
    'FtZUIMCgpfYXdheV9uYW1lQgwKCl9ob21lX2xvZ29CDAoKX2F3YXlfbG9nb0IPCg1fbWFya2V0'
    'X2NvdW50QgkKB19pc19ob3RCEAoOX2lzX2dvaW5nX2xpdmVCCgoIX2lzX2xpdmVCEQoPX2lzX2'
    'xpdmVfc3RyZWFtQgwKCl9nYW1lX3BhcnRCDAoKX2dhbWVfdGltZUIQCg5fc3RvcHBhZ2VfdGlt'
    'ZUINCgtfbGl2ZV9zY29yZUINCgtfY2hpbGRfdHlwZQ==');

@$core.Deprecated('Use scoreResponseDescriptor instead')
const ScoreResponse$json = {
  '1': 'ScoreResponse',
  '2': [
    {
      '1': 'soccer',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.app.proto.SoccerScoreResponse',
      '9': 0,
      '10': 'soccer'
    },
    {
      '1': 'basketball',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.app.proto.BasketballScoreResponse',
      '9': 0,
      '10': 'basketball'
    },
    {
      '1': 'volleyball',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.app.proto.VolleyballScoreResponse',
      '9': 0,
      '10': 'volleyball'
    },
    {
      '1': 'tennis',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.app.proto.TennisScoreResponse',
      '9': 0,
      '10': 'tennis'
    },
    {
      '1': 'table_tennis',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.app.proto.TableTennisScoreResponse',
      '9': 0,
      '10': 'tableTennis'
    },
    {
      '1': 'badminton',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.app.proto.BadmintonScoreResponse',
      '9': 0,
      '10': 'badminton'
    },
  ],
  '8': [
    {'1': 'data'},
  ],
};

final $typed_data.Uint8List scoreResponseDescriptor = $convert.base64Decode(
    'Cg1TY29yZVJlc3BvbnNlEjgKBnNvY2NlchgBIAEoCzIeLmFwcC5wcm90by5Tb2NjZXJTY29yZV'
    'Jlc3BvbnNlSABSBnNvY2NlchJECgpiYXNrZXRiYWxsGAIgASgLMiIuYXBwLnByb3RvLkJhc2tl'
    'dGJhbGxTY29yZVJlc3BvbnNlSABSCmJhc2tldGJhbGwSRAoKdm9sbGV5YmFsbBgDIAEoCzIiLm'
    'FwcC5wcm90by5Wb2xsZXliYWxsU2NvcmVSZXNwb25zZUgAUgp2b2xsZXliYWxsEjgKBnRlbm5p'
    'cxgEIAEoCzIeLmFwcC5wcm90by5UZW5uaXNTY29yZVJlc3BvbnNlSABSBnRlbm5pcxJICgx0YW'
    'JsZV90ZW5uaXMYBSABKAsyIy5hcHAucHJvdG8uVGFibGVUZW5uaXNTY29yZVJlc3BvbnNlSABS'
    'C3RhYmxlVGVubmlzEkEKCWJhZG1pbnRvbhgGIAEoCzIhLmFwcC5wcm90by5CYWRtaW50b25TY2'
    '9yZVJlc3BvbnNlSABSCWJhZG1pbnRvbkIGCgRkYXRh');

@$core.Deprecated('Use soccerScoreResponseDescriptor instead')
const SoccerScoreResponse$json = {
  '1': 'SoccerScoreResponse',
  '2': [
    {
      '1': 'home_score',
      '3': 1,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'homeScore',
      '17': true
    },
    {
      '1': 'away_score',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'awayScore',
      '17': true
    },
    {
      '1': 'home_score_h2',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'homeScoreH2',
      '17': true
    },
    {
      '1': 'away_score_h2',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'awayScoreH2',
      '17': true
    },
    {
      '1': 'home_corner',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 4,
      '10': 'homeCorner',
      '17': true
    },
    {
      '1': 'away_corner',
      '3': 6,
      '4': 1,
      '5': 5,
      '9': 5,
      '10': 'awayCorner',
      '17': true
    },
    {
      '1': 'home_score_o_t',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 6,
      '10': 'homeScoreOT',
      '17': true
    },
    {
      '1': 'away_score_o_t',
      '3': 8,
      '4': 1,
      '5': 5,
      '9': 7,
      '10': 'awayScoreOT',
      '17': true
    },
    {
      '1': 'home_score_pen',
      '3': 9,
      '4': 1,
      '5': 5,
      '9': 8,
      '10': 'homeScorePen',
      '17': true
    },
    {
      '1': 'away_score_pen',
      '3': 10,
      '4': 1,
      '5': 5,
      '9': 9,
      '10': 'awayScorePen',
      '17': true
    },
    {
      '1': 'yellow_cards_home',
      '3': 11,
      '4': 1,
      '5': 5,
      '9': 10,
      '10': 'yellowCardsHome',
      '17': true
    },
    {
      '1': 'yellow_cards_away',
      '3': 12,
      '4': 1,
      '5': 5,
      '9': 11,
      '10': 'yellowCardsAway',
      '17': true
    },
    {
      '1': 'red_cards_home',
      '3': 13,
      '4': 1,
      '5': 5,
      '9': 12,
      '10': 'redCardsHome',
      '17': true
    },
    {
      '1': 'red_cards_away',
      '3': 14,
      '4': 1,
      '5': 5,
      '9': 13,
      '10': 'redCardsAway',
      '17': true
    },
  ],
  '8': [
    {'1': '_home_score'},
    {'1': '_away_score'},
    {'1': '_home_score_h2'},
    {'1': '_away_score_h2'},
    {'1': '_home_corner'},
    {'1': '_away_corner'},
    {'1': '_home_score_o_t'},
    {'1': '_away_score_o_t'},
    {'1': '_home_score_pen'},
    {'1': '_away_score_pen'},
    {'1': '_yellow_cards_home'},
    {'1': '_yellow_cards_away'},
    {'1': '_red_cards_home'},
    {'1': '_red_cards_away'},
  ],
};

final $typed_data.Uint8List soccerScoreResponseDescriptor = $convert.base64Decode(
    'ChNTb2NjZXJTY29yZVJlc3BvbnNlEiIKCmhvbWVfc2NvcmUYASABKAVIAFIJaG9tZVNjb3JliA'
    'EBEiIKCmF3YXlfc2NvcmUYAiABKAVIAVIJYXdheVNjb3JliAEBEicKDWhvbWVfc2NvcmVfaDIY'
    'AyABKAVIAlILaG9tZVNjb3JlSDKIAQESJwoNYXdheV9zY29yZV9oMhgEIAEoBUgDUgthd2F5U2'
    'NvcmVIMogBARIkCgtob21lX2Nvcm5lchgFIAEoBUgEUgpob21lQ29ybmVyiAEBEiQKC2F3YXlf'
    'Y29ybmVyGAYgASgFSAVSCmF3YXlDb3JuZXKIAQESKAoOaG9tZV9zY29yZV9vX3QYByABKAVIBl'
    'ILaG9tZVNjb3JlT1SIAQESKAoOYXdheV9zY29yZV9vX3QYCCABKAVIB1ILYXdheVNjb3JlT1SI'
    'AQESKQoOaG9tZV9zY29yZV9wZW4YCSABKAVICFIMaG9tZVNjb3JlUGVuiAEBEikKDmF3YXlfc2'
    'NvcmVfcGVuGAogASgFSAlSDGF3YXlTY29yZVBlbogBARIvChF5ZWxsb3dfY2FyZHNfaG9tZRgL'
    'IAEoBUgKUg95ZWxsb3dDYXJkc0hvbWWIAQESLwoReWVsbG93X2NhcmRzX2F3YXkYDCABKAVIC1'
    'IPeWVsbG93Q2FyZHNBd2F5iAEBEikKDnJlZF9jYXJkc19ob21lGA0gASgFSAxSDHJlZENhcmRz'
    'SG9tZYgBARIpCg5yZWRfY2FyZHNfYXdheRgOIAEoBUgNUgxyZWRDYXJkc0F3YXmIAQFCDQoLX2'
    'hvbWVfc2NvcmVCDQoLX2F3YXlfc2NvcmVCEAoOX2hvbWVfc2NvcmVfaDJCEAoOX2F3YXlfc2Nv'
    'cmVfaDJCDgoMX2hvbWVfY29ybmVyQg4KDF9hd2F5X2Nvcm5lckIRCg9faG9tZV9zY29yZV9vX3'
    'RCEQoPX2F3YXlfc2NvcmVfb190QhEKD19ob21lX3Njb3JlX3BlbkIRCg9fYXdheV9zY29yZV9w'
    'ZW5CFAoSX3llbGxvd19jYXJkc19ob21lQhQKEl95ZWxsb3dfY2FyZHNfYXdheUIRCg9fcmVkX2'
    'NhcmRzX2hvbWVCEQoPX3JlZF9jYXJkc19hd2F5');

@$core.Deprecated('Use liveScoreDescriptor instead')
const LiveScore$json = {
  '1': 'LiveScore',
  '2': [
    {
      '1': 'home_score',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'homeScore',
      '17': true
    },
    {
      '1': 'away_score',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'awayScore',
      '17': true
    },
  ],
  '8': [
    {'1': '_home_score'},
    {'1': '_away_score'},
  ],
};

final $typed_data.Uint8List liveScoreDescriptor = $convert.base64Decode(
    'CglMaXZlU2NvcmUSIgoKaG9tZV9zY29yZRgBIAEoCUgAUglob21lU2NvcmWIAQESIgoKYXdheV'
    '9zY29yZRgCIAEoCUgBUglhd2F5U2NvcmWIAQFCDQoLX2hvbWVfc2NvcmVCDQoLX2F3YXlfc2Nv'
    'cmU=');

@$core.Deprecated('Use basketballScoreResponseDescriptor instead')
const BasketballScoreResponse$json = {
  '1': 'BasketballScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {
      '1': 'home_score_f_t',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'homeScoreFT',
      '17': true
    },
    {
      '1': 'away_score_f_t',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'awayScoreFT',
      '17': true
    },
    {
      '1': 'home_score_o_t',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'homeScoreOT',
      '17': true
    },
    {
      '1': 'away_score_o_t',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'awayScoreOT',
      '17': true
    },
  ],
  '8': [
    {'1': '_home_score_f_t'},
    {'1': '_away_score_f_t'},
    {'1': '_home_score_o_t'},
    {'1': '_away_score_o_t'},
  ],
};

final $typed_data.Uint8List basketballScoreResponseDescriptor = $convert.base64Decode(
    'ChdCYXNrZXRiYWxsU2NvcmVSZXNwb25zZRI1CgtsaXZlX3Njb3JlcxgBIAMoCzIULmFwcC5wcm'
    '90by5MaXZlU2NvcmVSCmxpdmVTY29yZXMSKAoOaG9tZV9zY29yZV9mX3QYAiABKAVIAFILaG9t'
    'ZVNjb3JlRlSIAQESKAoOYXdheV9zY29yZV9mX3QYAyABKAVIAVILYXdheVNjb3JlRlSIAQESKA'
    'oOaG9tZV9zY29yZV9vX3QYBCABKAVIAlILaG9tZVNjb3JlT1SIAQESKAoOYXdheV9zY29yZV9v'
    'X3QYBSABKAVIA1ILYXdheVNjb3JlT1SIAQFCEQoPX2hvbWVfc2NvcmVfZl90QhEKD19hd2F5X3'
    'Njb3JlX2ZfdEIRCg9faG9tZV9zY29yZV9vX3RCEQoPX2F3YXlfc2NvcmVfb190');

@$core.Deprecated('Use volleyballScoreResponseDescriptor instead')
const VolleyballScoreResponse$json = {
  '1': 'VolleyballScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {
      '1': 'home_set_score',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'homeSetScore',
      '17': true
    },
    {
      '1': 'away_set_score',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'awaySetScore',
      '17': true
    },
    {
      '1': 'home_total_point',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'homeTotalPoint',
      '17': true
    },
    {
      '1': 'away_total_point',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'awayTotalPoint',
      '17': true
    },
    {
      '1': 'serving_side',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'servingSide',
      '17': true
    },
    {
      '1': 'current_set',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 5,
      '10': 'currentSet',
      '17': true
    },
    {
      '1': 'num_of_sets',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'numOfSets',
      '17': true
    },
  ],
  '8': [
    {'1': '_home_set_score'},
    {'1': '_away_set_score'},
    {'1': '_home_total_point'},
    {'1': '_away_total_point'},
    {'1': '_serving_side'},
    {'1': '_current_set'},
    {'1': '_num_of_sets'},
  ],
};

final $typed_data.Uint8List volleyballScoreResponseDescriptor = $convert.base64Decode(
    'ChdWb2xsZXliYWxsU2NvcmVSZXNwb25zZRI1CgtsaXZlX3Njb3JlcxgBIAMoCzIULmFwcC5wcm'
    '90by5MaXZlU2NvcmVSCmxpdmVTY29yZXMSKQoOaG9tZV9zZXRfc2NvcmUYAiABKAVIAFIMaG9t'
    'ZVNldFNjb3JliAEBEikKDmF3YXlfc2V0X3Njb3JlGAMgASgFSAFSDGF3YXlTZXRTY29yZYgBAR'
    'ItChBob21lX3RvdGFsX3BvaW50GAQgASgFSAJSDmhvbWVUb3RhbFBvaW50iAEBEi0KEGF3YXlf'
    'dG90YWxfcG9pbnQYBSABKAVIA1IOYXdheVRvdGFsUG9pbnSIAQESJgoMc2VydmluZ19zaWRlGA'
    'YgASgJSARSC3NlcnZpbmdTaWRliAEBEiQKC2N1cnJlbnRfc2V0GAcgASgFSAVSCmN1cnJlbnRT'
    'ZXSIAQESIwoLbnVtX29mX3NldHMYCCABKAlIBlIJbnVtT2ZTZXRziAEBQhEKD19ob21lX3NldF'
    '9zY29yZUIRCg9fYXdheV9zZXRfc2NvcmVCEwoRX2hvbWVfdG90YWxfcG9pbnRCEwoRX2F3YXlf'
    'dG90YWxfcG9pbnRCDwoNX3NlcnZpbmdfc2lkZUIOCgxfY3VycmVudF9zZXRCDgoMX251bV9vZl'
    '9zZXRz');

@$core.Deprecated('Use tennisScoreResponseDescriptor instead')
const TennisScoreResponse$json = {
  '1': 'TennisScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {
      '1': 'home_set_score',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'homeSetScore',
      '17': true
    },
    {
      '1': 'away_set_score',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'awaySetScore',
      '17': true
    },
    {
      '1': 'home_game_score',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'homeGameScore',
      '17': true
    },
    {
      '1': 'away_game_score',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'awayGameScore',
      '17': true
    },
    {
      '1': 'home_current_point',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'homeCurrentPoint',
      '17': true
    },
    {
      '1': 'away_current_point',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'awayCurrentPoint',
      '17': true
    },
    {
      '1': 'serving_side',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'servingSide',
      '17': true
    },
    {
      '1': 'current_set',
      '3': 9,
      '4': 1,
      '5': 5,
      '9': 7,
      '10': 'currentSet',
      '17': true
    },
    {
      '1': 'num_of_sets',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 8,
      '10': 'numOfSets',
      '17': true
    },
  ],
  '8': [
    {'1': '_home_set_score'},
    {'1': '_away_set_score'},
    {'1': '_home_game_score'},
    {'1': '_away_game_score'},
    {'1': '_home_current_point'},
    {'1': '_away_current_point'},
    {'1': '_serving_side'},
    {'1': '_current_set'},
    {'1': '_num_of_sets'},
  ],
};

final $typed_data.Uint8List tennisScoreResponseDescriptor = $convert.base64Decode(
    'ChNUZW5uaXNTY29yZVJlc3BvbnNlEjUKC2xpdmVfc2NvcmVzGAEgAygLMhQuYXBwLnByb3RvLk'
    'xpdmVTY29yZVIKbGl2ZVNjb3JlcxIpCg5ob21lX3NldF9zY29yZRgCIAEoBUgAUgxob21lU2V0'
    'U2NvcmWIAQESKQoOYXdheV9zZXRfc2NvcmUYAyABKAVIAVIMYXdheVNldFNjb3JliAEBEisKD2'
    'hvbWVfZ2FtZV9zY29yZRgEIAEoBUgCUg1ob21lR2FtZVNjb3JliAEBEisKD2F3YXlfZ2FtZV9z'
    'Y29yZRgFIAEoBUgDUg1hd2F5R2FtZVNjb3JliAEBEjEKEmhvbWVfY3VycmVudF9wb2ludBgGIA'
    'EoCUgEUhBob21lQ3VycmVudFBvaW50iAEBEjEKEmF3YXlfY3VycmVudF9wb2ludBgHIAEoCUgF'
    'UhBhd2F5Q3VycmVudFBvaW50iAEBEiYKDHNlcnZpbmdfc2lkZRgIIAEoCUgGUgtzZXJ2aW5nU2'
    'lkZYgBARIkCgtjdXJyZW50X3NldBgJIAEoBUgHUgpjdXJyZW50U2V0iAEBEiMKC251bV9vZl9z'
    'ZXRzGAogASgJSAhSCW51bU9mU2V0c4gBAUIRCg9faG9tZV9zZXRfc2NvcmVCEQoPX2F3YXlfc2'
    'V0X3Njb3JlQhIKEF9ob21lX2dhbWVfc2NvcmVCEgoQX2F3YXlfZ2FtZV9zY29yZUIVChNfaG9t'
    'ZV9jdXJyZW50X3BvaW50QhUKE19hd2F5X2N1cnJlbnRfcG9pbnRCDwoNX3NlcnZpbmdfc2lkZU'
    'IOCgxfY3VycmVudF9zZXRCDgoMX251bV9vZl9zZXRz');

@$core.Deprecated('Use tableTennisScoreResponseDescriptor instead')
const TableTennisScoreResponse$json = {
  '1': 'TableTennisScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {
      '1': 'home_set_score',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'homeSetScore',
      '17': true
    },
    {
      '1': 'away_set_score',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'awaySetScore',
      '17': true
    },
    {
      '1': 'home_total_point',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'homeTotalPoint',
      '17': true
    },
    {
      '1': 'away_total_point',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'awayTotalPoint',
      '17': true
    },
    {
      '1': 'serving_side',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'servingSide',
      '17': true
    },
    {
      '1': 'current_set',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 5,
      '10': 'currentSet',
      '17': true
    },
    {
      '1': 'num_of_sets',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'numOfSets',
      '17': true
    },
  ],
  '8': [
    {'1': '_home_set_score'},
    {'1': '_away_set_score'},
    {'1': '_home_total_point'},
    {'1': '_away_total_point'},
    {'1': '_serving_side'},
    {'1': '_current_set'},
    {'1': '_num_of_sets'},
  ],
};

final $typed_data.Uint8List tableTennisScoreResponseDescriptor = $convert.base64Decode(
    'ChhUYWJsZVRlbm5pc1Njb3JlUmVzcG9uc2USNQoLbGl2ZV9zY29yZXMYASADKAsyFC5hcHAucH'
    'JvdG8uTGl2ZVNjb3JlUgpsaXZlU2NvcmVzEikKDmhvbWVfc2V0X3Njb3JlGAIgASgFSABSDGhv'
    'bWVTZXRTY29yZYgBARIpCg5hd2F5X3NldF9zY29yZRgDIAEoBUgBUgxhd2F5U2V0U2NvcmWIAQ'
    'ESLQoQaG9tZV90b3RhbF9wb2ludBgEIAEoBUgCUg5ob21lVG90YWxQb2ludIgBARItChBhd2F5'
    'X3RvdGFsX3BvaW50GAUgASgFSANSDmF3YXlUb3RhbFBvaW50iAEBEiYKDHNlcnZpbmdfc2lkZR'
    'gGIAEoCUgEUgtzZXJ2aW5nU2lkZYgBARIkCgtjdXJyZW50X3NldBgHIAEoBUgFUgpjdXJyZW50'
    'U2V0iAEBEiMKC251bV9vZl9zZXRzGAggASgJSAZSCW51bU9mU2V0c4gBAUIRCg9faG9tZV9zZX'
    'Rfc2NvcmVCEQoPX2F3YXlfc2V0X3Njb3JlQhMKEV9ob21lX3RvdGFsX3BvaW50QhMKEV9hd2F5'
    'X3RvdGFsX3BvaW50Qg8KDV9zZXJ2aW5nX3NpZGVCDgoMX2N1cnJlbnRfc2V0Qg4KDF9udW1fb2'
    'Zfc2V0cw==');

@$core.Deprecated('Use badmintonScoreResponseDescriptor instead')
const BadmintonScoreResponse$json = {
  '1': 'BadmintonScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {
      '1': 'home_set_score',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'homeSetScore',
      '17': true
    },
    {
      '1': 'away_set_score',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'awaySetScore',
      '17': true
    },
    {
      '1': 'home_total_point',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'homeTotalPoint',
      '17': true
    },
    {
      '1': 'away_total_point',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'awayTotalPoint',
      '17': true
    },
    {
      '1': 'serving_side',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'servingSide',
      '17': true
    },
    {
      '1': 'current_set',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 5,
      '10': 'currentSet',
      '17': true
    },
    {
      '1': 'num_of_sets',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'numOfSets',
      '17': true
    },
  ],
  '8': [
    {'1': '_home_set_score'},
    {'1': '_away_set_score'},
    {'1': '_home_total_point'},
    {'1': '_away_total_point'},
    {'1': '_serving_side'},
    {'1': '_current_set'},
    {'1': '_num_of_sets'},
  ],
};

final $typed_data.Uint8List badmintonScoreResponseDescriptor = $convert.base64Decode(
    'ChZCYWRtaW50b25TY29yZVJlc3BvbnNlEjUKC2xpdmVfc2NvcmVzGAEgAygLMhQuYXBwLnByb3'
    'RvLkxpdmVTY29yZVIKbGl2ZVNjb3JlcxIpCg5ob21lX3NldF9zY29yZRgCIAEoBUgAUgxob21l'
    'U2V0U2NvcmWIAQESKQoOYXdheV9zZXRfc2NvcmUYAyABKAVIAVIMYXdheVNldFNjb3JliAEBEi'
    '0KEGhvbWVfdG90YWxfcG9pbnQYBCABKAVIAlIOaG9tZVRvdGFsUG9pbnSIAQESLQoQYXdheV90'
    'b3RhbF9wb2ludBgFIAEoBUgDUg5hd2F5VG90YWxQb2ludIgBARImCgxzZXJ2aW5nX3NpZGUYBi'
    'ABKAlIBFILc2VydmluZ1NpZGWIAQESJAoLY3VycmVudF9zZXQYByABKAVIBVIKY3VycmVudFNl'
    'dIgBARIjCgtudW1fb2Zfc2V0cxgIIAEoCUgGUgludW1PZlNldHOIAQFCEQoPX2hvbWVfc2V0X3'
    'Njb3JlQhEKD19hd2F5X3NldF9zY29yZUITChFfaG9tZV90b3RhbF9wb2ludEITChFfYXdheV90'
    'b3RhbF9wb2ludEIPCg1fc2VydmluZ19zaWRlQg4KDF9jdXJyZW50X3NldEIOCgxfbnVtX29mX3'
    'NldHM=');

@$core.Deprecated('Use marketResponseDescriptor instead')
const MarketResponse$json = {
  '1': 'MarketResponse',
  '2': [
    {
      '1': 'oddsList',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.OddsResponse',
      '10': 'oddsList'
    },
    {
      '1': 'sport_id',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'sportId',
      '17': true
    },
    {
      '1': 'league_id',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'leagueId',
      '17': true
    },
    {
      '1': 'event_id',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'eventId',
      '17': true
    },
    {
      '1': 'market_id',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'marketId',
      '17': true
    },
    {
      '1': 'is_suspended',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 4,
      '10': 'isSuspended',
      '17': true
    },
    {
      '1': 'is_parlay',
      '3': 7,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'isParlay',
      '17': true
    },
    {
      '1': 'is_cash_out',
      '3': 8,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'isCashOut',
      '17': true
    },
    {
      '1': 'promotion_type',
      '3': 9,
      '4': 1,
      '5': 5,
      '9': 7,
      '10': 'promotionType',
      '17': true
    },
    {
      '1': 'group_id',
      '3': 10,
      '4': 1,
      '5': 5,
      '9': 8,
      '10': 'groupId',
      '17': true
    },
  ],
  '8': [
    {'1': '_sport_id'},
    {'1': '_league_id'},
    {'1': '_event_id'},
    {'1': '_market_id'},
    {'1': '_is_suspended'},
    {'1': '_is_parlay'},
    {'1': '_is_cash_out'},
    {'1': '_promotion_type'},
    {'1': '_group_id'},
  ],
};

final $typed_data.Uint8List marketResponseDescriptor = $convert.base64Decode(
    'Cg5NYXJrZXRSZXNwb25zZRIzCghvZGRzTGlzdBgBIAMoCzIXLmFwcC5wcm90by5PZGRzUmVzcG'
    '9uc2VSCG9kZHNMaXN0Eh4KCHNwb3J0X2lkGAIgASgFSABSB3Nwb3J0SWSIAQESIAoJbGVhZ3Vl'
    'X2lkGAMgASgFSAFSCGxlYWd1ZUlkiAEBEh4KCGV2ZW50X2lkGAQgASgDSAJSB2V2ZW50SWSIAQ'
    'ESIAoJbWFya2V0X2lkGAUgASgFSANSCG1hcmtldElkiAEBEiYKDGlzX3N1c3BlbmRlZBgGIAEo'
    'CEgEUgtpc1N1c3BlbmRlZIgBARIgCglpc19wYXJsYXkYByABKAhIBVIIaXNQYXJsYXmIAQESIw'
    'oLaXNfY2FzaF9vdXQYCCABKAhIBlIJaXNDYXNoT3V0iAEBEioKDnByb21vdGlvbl90eXBlGAkg'
    'ASgFSAdSDXByb21vdGlvblR5cGWIAQESHgoIZ3JvdXBfaWQYCiABKAVICFIHZ3JvdXBJZIgBAU'
    'ILCglfc3BvcnRfaWRCDAoKX2xlYWd1ZV9pZEILCglfZXZlbnRfaWRCDAoKX21hcmtldF9pZEIP'
    'Cg1faXNfc3VzcGVuZGVkQgwKCl9pc19wYXJsYXlCDgoMX2lzX2Nhc2hfb3V0QhEKD19wcm9tb3'
    'Rpb25fdHlwZUILCglfZ3JvdXBfaWQ=');

@$core.Deprecated('Use oddsResponseDescriptor instead')
const OddsResponse$json = {
  '1': 'OddsResponse',
  '2': [
    {
      '1': 'selection_home_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'selectionHomeId',
      '17': true
    },
    {
      '1': 'selection_away_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'selectionAwayId',
      '17': true
    },
    {
      '1': 'selection_draw_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'selectionDrawId',
      '17': true
    },
    {'1': 'points', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'points', '17': true},
    {
      '1': 'odds_home',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OddsStyleResponse',
      '9': 4,
      '10': 'oddsHome',
      '17': true
    },
    {
      '1': 'odds_away',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OddsStyleResponse',
      '9': 5,
      '10': 'oddsAway',
      '17': true
    },
    {
      '1': 'odds_draw',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OddsStyleResponse',
      '9': 6,
      '10': 'oddsDraw',
      '17': true
    },
    {
      '1': 'str_offer_id',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 7,
      '10': 'strOfferId',
      '17': true
    },
    {
      '1': 'is_main_line',
      '3': 9,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'isMainLine',
      '17': true
    },
    {
      '1': 'is_suspended',
      '3': 10,
      '4': 1,
      '5': 8,
      '9': 9,
      '10': 'isSuspended',
      '17': true
    },
    {
      '1': 'is_hidden',
      '3': 11,
      '4': 1,
      '5': 8,
      '9': 10,
      '10': 'isHidden',
      '17': true
    },
    {
      '1': 'player_name',
      '3': 12,
      '4': 1,
      '5': 9,
      '9': 11,
      '10': 'playerName',
      '17': true
    },
    {
      '1': 'player_id',
      '3': 13,
      '4': 1,
      '5': 9,
      '9': 12,
      '10': 'playerId',
      '17': true
    },
    {
      '1': 'period',
      '3': 14,
      '4': 1,
      '5': 5,
      '9': 13,
      '10': 'period',
      '17': true
    },
  ],
  '8': [
    {'1': '_selection_home_id'},
    {'1': '_selection_away_id'},
    {'1': '_selection_draw_id'},
    {'1': '_points'},
    {'1': '_odds_home'},
    {'1': '_odds_away'},
    {'1': '_odds_draw'},
    {'1': '_str_offer_id'},
    {'1': '_is_main_line'},
    {'1': '_is_suspended'},
    {'1': '_is_hidden'},
    {'1': '_player_name'},
    {'1': '_player_id'},
    {'1': '_period'},
  ],
};

final $typed_data.Uint8List oddsResponseDescriptor = $convert.base64Decode(
    'CgxPZGRzUmVzcG9uc2USLwoRc2VsZWN0aW9uX2hvbWVfaWQYASABKAlIAFIPc2VsZWN0aW9uSG'
    '9tZUlkiAEBEi8KEXNlbGVjdGlvbl9hd2F5X2lkGAIgASgJSAFSD3NlbGVjdGlvbkF3YXlJZIgB'
    'ARIvChFzZWxlY3Rpb25fZHJhd19pZBgDIAEoCUgCUg9zZWxlY3Rpb25EcmF3SWSIAQESGwoGcG'
    '9pbnRzGAQgASgJSANSBnBvaW50c4gBARI+CglvZGRzX2hvbWUYBSABKAsyHC5hcHAucHJvdG8u'
    'T2Rkc1N0eWxlUmVzcG9uc2VIBFIIb2Rkc0hvbWWIAQESPgoJb2Rkc19hd2F5GAYgASgLMhwuYX'
    'BwLnByb3RvLk9kZHNTdHlsZVJlc3BvbnNlSAVSCG9kZHNBd2F5iAEBEj4KCW9kZHNfZHJhdxgH'
    'IAEoCzIcLmFwcC5wcm90by5PZGRzU3R5bGVSZXNwb25zZUgGUghvZGRzRHJhd4gBARIlCgxzdH'
    'Jfb2ZmZXJfaWQYCCABKAlIB1IKc3RyT2ZmZXJJZIgBARIlCgxpc19tYWluX2xpbmUYCSABKAhI'
    'CFIKaXNNYWluTGluZYgBARImCgxpc19zdXNwZW5kZWQYCiABKAhICVILaXNTdXNwZW5kZWSIAQ'
    'ESIAoJaXNfaGlkZGVuGAsgASgISApSCGlzSGlkZGVuiAEBEiQKC3BsYXllcl9uYW1lGAwgASgJ'
    'SAtSCnBsYXllck5hbWWIAQESIAoJcGxheWVyX2lkGA0gASgJSAxSCHBsYXllcklkiAEBEhsKBn'
    'BlcmlvZBgOIAEoBUgNUgZwZXJpb2SIAQFCFAoSX3NlbGVjdGlvbl9ob21lX2lkQhQKEl9zZWxl'
    'Y3Rpb25fYXdheV9pZEIUChJfc2VsZWN0aW9uX2RyYXdfaWRCCQoHX3BvaW50c0IMCgpfb2Rkc1'
    '9ob21lQgwKCl9vZGRzX2F3YXlCDAoKX29kZHNfZHJhd0IPCg1fc3RyX29mZmVyX2lkQg8KDV9p'
    'c19tYWluX2xpbmVCDwoNX2lzX3N1c3BlbmRlZEIMCgpfaXNfaGlkZGVuQg4KDF9wbGF5ZXJfbm'
    'FtZUIMCgpfcGxheWVyX2lkQgkKB19wZXJpb2Q=');

@$core.Deprecated('Use oddsStyleResponseDescriptor instead')
const OddsStyleResponse$json = {
  '1': 'OddsStyleResponse',
  '2': [
    {
      '1': 'decimal',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'decimal',
      '17': true
    },
    {'1': 'malay', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'malay', '17': true},
    {'1': 'indo', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'indo', '17': true},
    {'1': 'hk', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'hk', '17': true},
  ],
  '8': [
    {'1': '_decimal'},
    {'1': '_malay'},
    {'1': '_indo'},
    {'1': '_hk'},
  ],
};

final $typed_data.Uint8List oddsStyleResponseDescriptor = $convert.base64Decode(
    'ChFPZGRzU3R5bGVSZXNwb25zZRIdCgdkZWNpbWFsGAEgASgJSABSB2RlY2ltYWyIAQESGQoFbW'
    'FsYXkYAiABKAlIAVIFbWFsYXmIAQESFwoEaW5kbxgDIAEoCUgCUgRpbmRviAEBEhMKAmhrGAQg'
    'ASgJSANSAmhriAEBQgoKCF9kZWNpbWFsQggKBl9tYWxheUIHCgVfaW5kb0IFCgNfaGs=');

@$core.Deprecated('Use outrightOddsResponseDescriptor instead')
const OutrightOddsResponse$json = {
  '1': 'OutrightOddsResponse',
  '2': [
    {
      '1': 'selection_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'selectionId',
      '17': true
    },
    {
      '1': 'selection_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'selectionName',
      '17': true
    },
    {
      '1': 'selection_logo',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'selectionLogo',
      '17': true
    },
    {
      '1': 'offer_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'offerId',
      '17': true
    },
    {'1': 'odds', '3': 5, '4': 1, '5': 1, '9': 4, '10': 'odds', '17': true},
    {'1': 'cls', '3': 6, '4': 1, '5': 9, '9': 5, '10': 'cls', '17': true},
    {
      '1': 'is_suspended',
      '3': 7,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'isSuspended',
      '17': true
    },
  ],
  '8': [
    {'1': '_selection_id'},
    {'1': '_selection_name'},
    {'1': '_selection_logo'},
    {'1': '_offer_id'},
    {'1': '_odds'},
    {'1': '_cls'},
    {'1': '_is_suspended'},
  ],
};

final $typed_data.Uint8List outrightOddsResponseDescriptor = $convert.base64Decode(
    'ChRPdXRyaWdodE9kZHNSZXNwb25zZRImCgxzZWxlY3Rpb25faWQYASABKAlIAFILc2VsZWN0aW'
    '9uSWSIAQESKgoOc2VsZWN0aW9uX25hbWUYAiABKAlIAVINc2VsZWN0aW9uTmFtZYgBARIqCg5z'
    'ZWxlY3Rpb25fbG9nbxgDIAEoCUgCUg1zZWxlY3Rpb25Mb2dviAEBEh4KCG9mZmVyX2lkGAQgAS'
    'gJSANSB29mZmVySWSIAQESFwoEb2RkcxgFIAEoAUgEUgRvZGRziAEBEhUKA2NscxgGIAEoCUgF'
    'UgNjbHOIAQESJgoMaXNfc3VzcGVuZGVkGAcgASgISAZSC2lzU3VzcGVuZGVkiAEBQg8KDV9zZW'
    'xlY3Rpb25faWRCEQoPX3NlbGVjdGlvbl9uYW1lQhEKD19zZWxlY3Rpb25fbG9nb0ILCglfb2Zm'
    'ZXJfaWRCBwoFX29kZHNCBgoEX2Nsc0IPCg1faXNfc3VzcGVuZGVk');

@$core.Deprecated('Use outrightLineResponseDescriptor instead')
const OutrightLineResponse$json = {
  '1': 'OutrightLineResponse',
  '2': [
    {
      '1': 'odds_list',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.OutrightOddsResponse',
      '10': 'oddsList'
    },
    {
      '1': 'line_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'lineName',
      '17': true
    },
    {
      '1': 'line_order',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'lineOrder',
      '17': true
    },
  ],
  '8': [
    {'1': '_line_name'},
    {'1': '_line_order'},
  ],
};

final $typed_data.Uint8List outrightLineResponseDescriptor = $convert.base64Decode(
    'ChRPdXRyaWdodExpbmVSZXNwb25zZRI8CglvZGRzX2xpc3QYASADKAsyHy5hcHAucHJvdG8uT3'
    'V0cmlnaHRPZGRzUmVzcG9uc2VSCG9kZHNMaXN0EiAKCWxpbmVfbmFtZRgCIAEoCUgAUghsaW5l'
    'TmFtZYgBARIiCgpsaW5lX29yZGVyGAMgASgFSAFSCWxpbmVPcmRlcogBAUIMCgpfbGluZV9uYW'
    '1lQg0KC19saW5lX29yZGVy');

@$core.Deprecated('Use outrightEventResponseDescriptor instead')
const OutrightEventResponse$json = {
  '1': 'OutrightEventResponse',
  '2': [
    {
      '1': 'lines',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.OutrightLineResponse',
      '10': 'lines'
    },
    {
      '1': 'sport_id',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'sportId',
      '17': true
    },
    {
      '1': 'league_id',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'leagueId',
      '17': true
    },
    {
      '1': 'event_id',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'eventId',
      '17': true
    },
    {
      '1': 'event_name',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'eventName',
      '17': true
    },
    {
      '1': 'is_suspended',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 4,
      '10': 'isSuspended',
      '17': true
    },
    {
      '1': 'end_date',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'endDate',
      '17': true
    },
    {
      '1': 'end_time',
      '3': 8,
      '4': 1,
      '5': 3,
      '9': 6,
      '10': 'endTime',
      '17': true
    },
  ],
  '8': [
    {'1': '_sport_id'},
    {'1': '_league_id'},
    {'1': '_event_id'},
    {'1': '_event_name'},
    {'1': '_is_suspended'},
    {'1': '_end_date'},
    {'1': '_end_time'},
  ],
};

final $typed_data.Uint8List outrightEventResponseDescriptor = $convert.base64Decode(
    'ChVPdXRyaWdodEV2ZW50UmVzcG9uc2USNQoFbGluZXMYASADKAsyHy5hcHAucHJvdG8uT3V0cm'
    'lnaHRMaW5lUmVzcG9uc2VSBWxpbmVzEh4KCHNwb3J0X2lkGAIgASgFSABSB3Nwb3J0SWSIAQES'
    'IAoJbGVhZ3VlX2lkGAMgASgFSAFSCGxlYWd1ZUlkiAEBEh4KCGV2ZW50X2lkGAQgASgDSAJSB2'
    'V2ZW50SWSIAQESIgoKZXZlbnRfbmFtZRgFIAEoCUgDUglldmVudE5hbWWIAQESJgoMaXNfc3Vz'
    'cGVuZGVkGAYgASgISARSC2lzU3VzcGVuZGVkiAEBEh4KCGVuZF9kYXRlGAcgASgJSAVSB2VuZE'
    'RhdGWIAQESHgoIZW5kX3RpbWUYCCABKANIBlIHZW5kVGltZYgBAUILCglfc3BvcnRfaWRCDAoK'
    'X2xlYWd1ZV9pZEILCglfZXZlbnRfaWRCDQoLX2V2ZW50X25hbWVCDwoNX2lzX3N1c3BlbmRlZE'
    'ILCglfZW5kX2RhdGVCCwoJX2VuZF90aW1l');

@$core.Deprecated('Use betSlipStatusResponseDescriptor instead')
const BetSlipStatusResponse$json = {
  '1': 'BetSlipStatusResponse',
  '2': [
    {
      '1': 'ticket_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'ticketId',
      '17': true
    },
    {'1': 'status', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'status', '17': true},
  ],
  '8': [
    {'1': '_ticket_id'},
    {'1': '_status'},
  ],
};

final $typed_data.Uint8List betSlipStatusResponseDescriptor = $convert.base64Decode(
    'ChVCZXRTbGlwU3RhdHVzUmVzcG9uc2USIAoJdGlja2V0X2lkGAEgASgJSABSCHRpY2tldElkiA'
    'EBEhsKBnN0YXR1cxgCIAEoCUgBUgZzdGF0dXOIAQFCDAoKX3RpY2tldF9pZEIJCgdfc3RhdHVz');

@$core.Deprecated('Use hotEventsResponseDescriptor instead')
const HotEventsResponse$json = {
  '1': 'HotEventsResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.HotEventResponse',
      '10': 'events'
    },
  ],
};

final $typed_data.Uint8List hotEventsResponseDescriptor = $convert.base64Decode(
    'ChFIb3RFdmVudHNSZXNwb25zZRIzCgZldmVudHMYASADKAsyGy5hcHAucHJvdG8uSG90RXZlbn'
    'RSZXNwb25zZVIGZXZlbnRz');

@$core.Deprecated('Use hotEventResponseDescriptor instead')
const HotEventResponse$json = {
  '1': 'HotEventResponse',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '9': 0,
      '10': 'event',
      '17': true
    },
    {
      '1': 'league_id',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'leagueId',
      '17': true
    },
    {
      '1': 'league_name',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'leagueName',
      '17': true
    },
    {
      '1': 'league_order',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'leagueOrder',
      '17': true
    },
    {
      '1': 'league_priority_order',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 4,
      '10': 'leaguePriorityOrder',
      '17': true
    },
    {
      '1': 'league_logo',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'leagueLogo',
      '17': true
    },
  ],
  '8': [
    {'1': '_event'},
    {'1': '_league_id'},
    {'1': '_league_name'},
    {'1': '_league_order'},
    {'1': '_league_priority_order'},
    {'1': '_league_logo'},
  ],
};

final $typed_data.Uint8List hotEventResponseDescriptor = $convert.base64Decode(
    'ChBIb3RFdmVudFJlc3BvbnNlEjMKBWV2ZW50GAEgASgLMhguYXBwLnByb3RvLkV2ZW50UmVzcG'
    '9uc2VIAFIFZXZlbnSIAQESIAoJbGVhZ3VlX2lkGAIgASgFSAFSCGxlYWd1ZUlkiAEBEiQKC2xl'
    'YWd1ZV9uYW1lGAMgASgJSAJSCmxlYWd1ZU5hbWWIAQESJgoMbGVhZ3VlX29yZGVyGAQgASgFSA'
    'NSC2xlYWd1ZU9yZGVyiAEBEjcKFWxlYWd1ZV9wcmlvcml0eV9vcmRlchgFIAEoBUgEUhNsZWFn'
    'dWVQcmlvcml0eU9yZGVyiAEBEiQKC2xlYWd1ZV9sb2dvGAYgASgJSAVSCmxlYWd1ZUxvZ2+IAQ'
    'FCCAoGX2V2ZW50QgwKCl9sZWFndWVfaWRCDgoMX2xlYWd1ZV9uYW1lQg8KDV9sZWFndWVfb3Jk'
    'ZXJCGAoWX2xlYWd1ZV9wcmlvcml0eV9vcmRlckIOCgxfbGVhZ3VlX2xvZ28=');

@$core.Deprecated('Use popularLeaguesResponseDescriptor instead')
const PopularLeaguesResponse$json = {
  '1': 'PopularLeaguesResponse',
  '2': [
    {
      '1': 'leagues',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LeagueResponse',
      '10': 'leagues'
    },
  ],
};

final $typed_data.Uint8List popularLeaguesResponseDescriptor =
    $convert.base64Decode(
        'ChZQb3B1bGFyTGVhZ3Vlc1Jlc3BvbnNlEjMKB2xlYWd1ZXMYASADKAsyGS5hcHAucHJvdG8uTG'
        'VhZ3VlUmVzcG9uc2VSB2xlYWd1ZXM=');

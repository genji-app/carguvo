class MockData {

  static Map<String, dynamic> mainConfig = {
    'api_domain': 'https://api-test.example.com/',
    'sport_domain': 'https://sport-test.example.com/',
    'sport_domain_top': 'https://top-test.example.com/',
    'main_ws_url': 'wss://ws-test.example.com',
    'ws_sport_domain': 'wss://sport-ws-test.example.com',
    'avatarUrl': 'https://cdn-test.example.com/avatars/',
    'logo': 'sun.win',
  };

  static Map<String, dynamic> refreshTokenResponse = {
    'status': 'success',
    'data': {'wsToken': 'mock_ws_token_12345', 'expiresIn': 3600},
  };

  static Map<String, dynamic> sbConfig = {
    'urlSetting': 'https://config-test.example.com/settings/',
    'sport_domain': 'https://sb-test.example.com/api/v1',
    'video_domain': 'https://video-test.example.com',
    'virtual_video_domain': 'https://virtual-video-test.example.com',
    'team': {
      '101': {'name': 'Real Madrid', 'logo': 'real_madrid.png'},
      '102': {'name': 'Barcelona', 'logo': 'barcelona.png'},
    },
    'league': {
      '201': {'name': 'La Liga', 'country': 'Spain'},
      '202': {'name': 'Premier League', 'country': 'England'},
    },
  };

  static Map<String, dynamic> sbTokenResponse = {
    'status': 'success',
    'data': {
      'token': 'mock_sb_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      'expiresIn': 3600,
    },
  };

  static Map<String, dynamic> userInfo = {
    'uid': 'test_uid_12345',
    'displayName': 'Test User',
    'cust_login': 'testuser',
    'cust_id': '999',
    'balance': '1000.000',
    'currency': 'VND',
    'status': 'Active',
    'email': 'test@example.com',
    'phone': '+84123456789',
  };

  static Map<String, dynamic> balanceUpdate = {
    'uid': 'test_uid_12345',
    'balance': '950.000',
    'currency': 'VND',
  };

  static Map<String, dynamic> eventsResponse = {
    'events': [
      {
        'id': 123456,
        'name': 'Real Madrid vs Barcelona',
        'leagueId': 201,
        'leagueName': 'La Liga',
        'startDate': '2024-11-24T20:00:00Z',
        'isLive': false,
        'homeTeam': {'id': 101, 'name': 'Real Madrid'},
        'awayTeam': {'id': 102, 'name': 'Barcelona'},
        'markets': [
          {
            'id': 'm_1x2_1',
            'name': 'Match Winner',
            'cls': '1x2',
            'odds': [
              {
                'selectionId': '1',
                'name': 'Home',
                'displayOdds': '1.95',
                'offerId': 'o_1',
              },
              {
                'selectionId': 'X',
                'name': 'Draw',
                'displayOdds': '3.20',
                'offerId': 'o_2',
              },
              {
                'selectionId': '2',
                'name': 'Away',
                'displayOdds': '4.50',
                'offerId': 'o_3',
              },
            ],
          },
          {
            'id': 'm_ah_1',
            'name': 'Asian Handicap',
            'cls': 'asian_handicap',
            'odds': [
              {
                'selectionId': '1_-0.5',
                'name': 'Home -0.5',
                'displayOdds': '1.90',
                'offerId': 'o_4',
              },
              {
                'selectionId': '2_+0.5',
                'name': 'Away +0.5',
                'displayOdds': '1.90',
                'offerId': 'o_5',
              },
            ],
          },
        ],
      },
      {
        'id': 123457,
        'name': 'Manchester United vs Liverpool',
        'leagueId': 202,
        'leagueName': 'Premier League',
        'startDate': '2024-11-24T18:00:00Z',
        'isLive': true,
        'homeTeam': {'id': 103, 'name': 'Manchester United'},
        'awayTeam': {'id': 104, 'name': 'Liverpool'},
        'score': {'home': 1, 'away': 1},
        'minute': 67,
        'markets': [
          {
            'id': 'm_1x2_2',
            'name': 'Match Winner',
            'cls': '1x2',
            'odds': [
              {
                'selectionId': '1',
                'name': 'Home',
                'displayOdds': '2.10',
                'offerId': 'o_6',
              },
              {
                'selectionId': 'X',
                'name': 'Draw',
                'displayOdds': '3.40',
                'offerId': 'o_7',
              },
              {
                'selectionId': '2',
                'name': 'Away',
                'displayOdds': '3.20',
                'offerId': 'o_8',
              },
            ],
          },
        ],
      },
    ],
    'total': 2,
  };

  static Map<String, dynamic> hotMatchesResponse = {
    'events': [
      {
        'id': 123456,
        'name': 'Real Madrid vs Barcelona',
        'leagueId': 201,
        'featured': true,
        'popularityScore': 9.5,
      },
    ],
  };

  static Map<String, dynamic> calculateBetsResponse = {
    'minStake': 10000,
    'maxStake': 50000000,
    'maxPayout': 100000000,
    'displayOdds': '1.95',
    'trueOdds': 1.95,
    'errorCode': 0,
    'message': 'Success',
  };

  static Map<String, dynamic> placeBetSuccess = {
    'ticketId': 'TICKET_ABC123XYZ',
    'status': 'SUCCESS',
    'odds': '1.95',
    'stake': 100000,
    'winnings': 195000,
    'selections': [
      {
        'eventId': 123456,
        'eventName': 'Real Madrid vs Barcelona',
        'selectionId': '1_-0.5',
        'selectionName': 'Home -0.5',
        'odds': '1.95',
      },
    ],
    'errorCode': 0,
    'message': 'Bet placed successfully',
    'createdAt': '2024-11-24T10:00:00Z',
  };

  static Map<String, dynamic> placeBetErrorBalance = {
    'ticketId': null,
    'status': 'FAILED',
    'errorCode': 1001,
    'message': 'Insufficient balance',
  };

  static Map<String, dynamic> placeBetErrorOdds = {
    'ticketId': null,
    'status': 'FAILED',
    'errorCode': 1002,
    'message': 'Odds have changed',
    'newOdds': '1.85',
  };

  static Map<String, dynamic> betHistoryResponse = {
    'bets': [
      {
        'ticketId': 'TICKET_ABC123XYZ',
        'status': 'pending',
        'stake': 100000,
        'potentialWinnings': 195000,
        'odds': '1.95',
        'selections': [
          {
            'eventName': 'Real Madrid vs Barcelona',
            'selectionName': 'Home -0.5',
            'odds': '1.95',
            'status': 'pending',
          },
        ],
        'createdAt': '2024-11-24T10:00:00Z',
      },
      {
        'ticketId': 'TICKET_XYZ789DEF',
        'status': 'won',
        'stake': 50000,
        'actualWinnings': 97500,
        'odds': '1.95',
        'selections': [
          {
            'eventName': 'Manchester United vs Liverpool',
            'selectionName': 'Draw',
            'odds': '3.40',
            'status': 'won',
          },
        ],
        'createdAt': '2024-11-23T15:00:00Z',
        'settledAt': '2024-11-23T17:00:00Z',
      },
      {
        'ticketId': 'TICKET_LMN456OPQ',
        'status': 'lost',
        'stake': 75000,
        'actualWinnings': 0,
        'odds': '2.10',
        'selections': [
          {
            'eventName': 'Chelsea vs Arsenal',
            'selectionName': 'Home',
            'odds': '2.10',
            'status': 'lost',
          },
        ],
        'createdAt': '2024-11-22T20:00:00Z',
        'settledAt': '2024-11-22T22:00:00Z',
      },
    ],
    'total': 3,
    'totalStake': 225000,
    'totalWinnings': 97500,
  };

  static Map<String, dynamic> ticketStatusResponse = {
    'ticketId': 'TICKET_ABC123XYZ',
    'status': 'won',
    'stake': 100000,
    'actualWinnings': 195000,
    'odds': '1.95',
    'selections': [
      {
        'eventName': 'Real Madrid vs Barcelona',
        'selectionName': 'Home -0.5',
        'odds': '1.95',
        'status': 'won',
        'result': {'homeScore': 2, 'awayScore': 1},
      },
    ],
    'createdAt': '2024-11-24T10:00:00Z',
    'settledAt': '2024-11-24T22:00:00Z',
  };

  static Map<String, dynamic> cashOutOptionsResponse = {
    'ticketId': 'TICKET_ABC123XYZ',
    'available': true,
    'cashOutAmount':
        150000,
    'originalStake': 100000,
    'potentialWinnings': 195000,
    'profit': 50000,
    'profitPercentage': 50.0,
    'reason': 'Match is going well, cash out now to secure profit',
  };

  static Map<String, dynamic> cashOutSuccess = {
    'ticketId': 'TICKET_ABC123XYZ',
    'status': 'SUCCESS',
    'cashOutAmount': 150000,
    'profit': 50000,
    'message': 'Cash out successful',
  };

  static Map<String, dynamic> cashOutNotAvailable = {
    'ticketId': 'TICKET_ABC123XYZ',
    'available': false,
    'reason': 'Match has ended or cash out is not available for this bet',
  };

  static Map<String, dynamic> liveLinkResponse = {
    'eventId': 123456,
    'available': true,
    'streamUrl': 'https://video-test.example.com/live/123456',
    'provider': 'test_provider',
    'quality': ['720p', '480p', '360p'],
  };

  static Map<String, dynamic> highlightResponse = {
    'videos': [
      {
        'eventId': 123450,
        'eventName': 'Real Madrid vs Barcelona',
        'thumbnailUrl': 'https://cdn-test.example.com/thumbnails/123450.jpg',
        'videoUrl': 'https://video-test.example.com/highlight/123450',
        'duration': 300,
        'views': 125000,
      },
      {
        'eventId': 123451,
        'eventName': 'Manchester United vs Liverpool',
        'thumbnailUrl': 'https://cdn-test.example.com/thumbnails/123451.jpg',
        'videoUrl': 'https://video-test.example.com/highlight/123451',
        'duration': 420,
        'views': 98000,
      },
    ],
  };

  static Map<String, dynamic> statsLinkResponse = {
    'eventId': 123456,
    'statsUrl': 'https://stats-test.example.com/match/123456',
    'available': true,
  };

  static Map<String, dynamic> getAllMockData() {
    return {
      'mainConfig': mainConfig,
      'refreshTokenResponse': refreshTokenResponse,
      'sbConfig': sbConfig,
      'sbTokenResponse': sbTokenResponse,
      'userInfo': userInfo,
      'balanceUpdate': balanceUpdate,
      'eventsResponse': eventsResponse,
      'hotMatchesResponse': hotMatchesResponse,
      'calculateBetsResponse': calculateBetsResponse,
      'placeBetSuccess': placeBetSuccess,
      'placeBetErrorBalance': placeBetErrorBalance,
      'placeBetErrorOdds': placeBetErrorOdds,
      'betHistoryResponse': betHistoryResponse,
      'ticketStatusResponse': ticketStatusResponse,
      'cashOutOptionsResponse': cashOutOptionsResponse,
      'cashOutSuccess': cashOutSuccess,
      'cashOutNotAvailable': cashOutNotAvailable,
      'liveLinkResponse': liveLinkResponse,
      'highlightResponse': highlightResponse,
      'statsLinkResponse': statsLinkResponse,
    };
  }
}

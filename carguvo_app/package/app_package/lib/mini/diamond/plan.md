
Đây là file plan để handle trò diamond. Sẽ có tất cả 4 màn hình chính. Hãy handle lần lượt từ trên xuống dưới. Icon đã được define trong `mini_game_icons.dart`

- Xử lý load ảnh lớn về(follow trò updown) 
  - https://raw.githubusercontent.com/genji-app/config_download/refs/heads/main/diamond.manifest_staging.json link staging
  - https://raw.githubusercontent.com/genji-app/config_download/refs/heads/main/diamond.manifest.json link prod
  - tất cả icon sẽ sử dụng hàm load trong ImageHelper
- khi tap thì sử dụng Sound.wrap(function)(follow trò updown)
- Follow trò updown để tách widget.

1 màn hình chính(diamond_screen.dart): design Figma. @https://www.figma.com/design/ao0vxVAJlscxdKTb4C7KKV/Minigames?node-id=867-101612&m=dev . Dựa vào link figma hãy hoàn thành màn hình chính như design.
1.1 Handle Logic & business:
- Dựa vào list file 00-06 .md trong docs để handle logic và business cho trò diamond này. cần tách widget nhỏ để dễ nhìn và performance hiệu quả hơn.
1.2 UI:
  - Hãy xem những widget sài gradient hãy check design kỹ càng.
2 màn hình rank: design Figma. @https://www.figma.com/design/ao0vxVAJlscxdKTb4C7KKV/Minigames?node-id=869-109532&m=dev . Dựa vào link figma hãy hoàn thành màn hình chính như design.
2.1 Handle Logic & business: 
- Dựa vào file 07_history_rank.md để handle logic và business.
- API rank: domainAPI/sa?command=fetchTopSlotMachine&gameId=202&limit=6&skip=0 . Check trò updown để xử lý api
- response: hãy check trò updown để biết cách tạo+xử lý model như thế nào
`{
    "message": "Success",
    "code": 0,
    "data": {
        "count": 1326,
        "items": [
            {
                "gameType": 0,
                "isBot": false,
                "numLines": 20,
                "displayName": "gonall",
                "description": "Nổ hũ",
                "symbols": [
                    4,
                    3,
                    4,
                    0,
                    1,
                    0,
                    2,
                    0,
                    5
                ],
                "betlines": [
                    0,
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    8,
                    9,
                    10,
                    11,
                    12,
                    13,
                    14,
                    15,
                    16,
                    17,
                    18,
                    19
                ],
                "payoutLines": [
                    {
                        "payout": 40,
                        "id": 0,
                        "isJackpot": false
                    },
                    {
                        "payout": 8500,
                        "id": 1,
                        "isJackpot": false
                    },
                    {
                        "payout": 80,
                        "id": 2,
                        "isJackpot": false
                    },
                    {
                        "payout": 800,
                        "id": 4,
                        "isJackpot": false
                    },
                    {
                        "payout": 2000,
                        "id": 8,
                        "isJackpot": false
                    },
                    {
                        "payout": 776540,
                        "id": 9,
                        "isJackpot": true
                    },
                    {
                        "payout": 80,
                        "id": 10,
                        "isJackpot": false
                    },
                    {
                        "payout": 4000,
                        "id": 11,
                        "isJackpot": false
                    },
                    {
                        "payout": 80,
                        "id": 12,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 13,
                        "isJackpot": false
                    },
                    {
                        "payout": 80,
                        "id": 14,
                        "isJackpot": false
                    },
                    {
                        "payout": 300,
                        "id": 15,
                        "isJackpot": false
                    },
                    {
                        "payout": 80,
                        "id": 16,
                        "isJackpot": false
                    },
                    {
                        "payout": 80,
                        "id": 18,
                        "isJackpot": false
                    }
                ],
                "gameName": "Kim cương",
                "assetId": 1,
                "customerId": 312393821,
                "rank": 5,
                "createdTime": 1783257476623,
                "miniGameCredit": 0,
                "id": "6a4a5984c8c5094e08fd6b4a",
                "brand": "sun.win",
                "gameId": 202,
                "hasMiniGame": false,
                "betting": 100,
                "sessionId": 23864460,
                "userId": "754fdc12-0956-460d-9c35-f76017c9e1e0",
                "money": 792700,
                "betLines": [],
                "freeSpinRate": 0,
                "totalBet": 2000,
                "isJackpot": true,
                "isEvent": false
            },
        ]
    },
    "status": 0
}`

3 màn hình history : design Figma @https://www.figma.com/design/ao0vxVAJlscxdKTb4C7KKV/Minigames?node-id=869-112301&m=dev . Dựa vào link figma hãy hoàn thành màn hình chính như design.
3.1 Handle Logic & business:
- Dựa vào file 07_history_rank.md để handle logic và business.    
- API history: domainAPI/sa?command=fetchSlotMachineHistory&assetId=1&limit=6&skip=0&gameId=202 . Check trò updown để xử lý api
- response: hãy check trò updown để biết cách tạo+xử lý model như thế nào
`{
    "message": "Success",
    "code": 0,
    "data": {
        "count": 2,
        "items": [
            {
                "gameType": 0,
                "isBot": false,
                "numLines": 20,
                "displayName": "chucha1245",
                "description": "Payline",
                "symbols": [
                    2,
                    5,
                    5,
                    2,
                    5,
                    1,
                    5,
                    5,
                    5
                ],
                "betlines": [
                    0,
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    8,
                    9,
                    10,
                    11,
                    12,
                    13,
                    14,
                    15,
                    16,
                    17,
                    18,
                    19
                ],
                "payoutLines": [
                    {
                        "payout": 300,
                        "id": 0,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 2,
                        "isJackpot": false
                    },
                    {
                        "payout": 300,
                        "id": 3,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 4,
                        "isJackpot": false
                    },
                    {
                        "payout": 300,
                        "id": 5,
                        "isJackpot": false
                    },
                    {
                        "payout": 300,
                        "id": 6,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 7,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 10,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 11,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 12,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 13,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 15,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 17,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 18,
                        "isJackpot": false
                    },
                    {
                        "payout": 40,
                        "id": 19,
                        "isJackpot": false
                    }
                ],
                "gameName": "Kim cương",
                "assetId": 1,
                "customerId": 329328061,
                "rank": 1,
                "createdTime": 1783258032907,
                "miniGameCredit": 0,
                "id": "6a4a5bb0d1ab603dbfff56c6",
                "brand": "sun.win",
                "gameId": 202,
                "hasMiniGame": false,
                "betting": 100,
                "sessionId": 23869196,
                "userId": "aaade1e7-90b1-45eb-83ee-44447ac1f02a",
                "money": 1640,
                "betLines": [],
                "freeSpinRate": 0,
                "totalBet": 2000,
                "isJackpot": false,
                "isEvent": false,
                "username": "SC_testgame0612"
            },
        ]
    },
    "status": 0
}`

4 Màn hình hướng dẫn link design Figma @https://www.figma.com/design/ao0vxVAJlscxdKTb4C7KKV/Minigames?node-id=894-121974&m=dev .Dựa vào link figma hãy hoàn thành màn hình chính như design.

5 chi tiết History: link design Figma @https://www.figma.com/design/ao0vxVAJlscxdKTb4C7KKV/Minigames?node-id=869-114236&m=dev . Từ màn hình list history click thì move sang màn hình chi tiết history. Data để fill dựa vào item history.
Hãy handle những yêu cầu sau đây:
- trong profile_screen.dart thêm iconCamera(class app_icons.dart) ở vị trí bottom-right của avatar.
- tạo màn hình với UI show list avatar from Figma.
@https://www.figma.com/design/Kmxt5j4aqDHQBPQNOCpuEw/Sun-Sport?node-id=8394-45753&m=dev
sẽ call api getAvatars $api_domain/id?command=getAvatars trả về response
{
"items": [
{
"id": 1,
"url": "https://images.swinshop.net/images/avatar/avatar_01.png"
},
]
}

- click item avatar show dialog confirm với message "Bạn có chắc chắn chọn avatar không ?" với 2 button "Có" và "Không".
- call api update $api_domain/id?command=updateAvatar&id=4 trả về response
{"data":{"message":"Thành công"},"status":0}
- Hãy nhớ làm theo codebase hiện tại.


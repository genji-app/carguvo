# Tài liệu thiết kế System UI Manager cho Flutter Gaming App

## Tổng quan

Tài liệu này tổng hợp toàn bộ các quyết định thiết kế đã được thống nhất cho một module quản lý System UI dùng trong ứng dụng Flutter đa nền tảng (mobile app + web), với ngữ cảnh chính là màn hình chơi game sử dụng WebView và yêu cầu trải nghiệm toàn màn hình.[cite:17][cite:19]

Mục tiêu của module là cung cấp một lõi dịch vụ thống nhất để điều khiển trạng thái hiển thị của system UI theo ngữ cảnh nghiệp vụ của ứng dụng, thay vì để từng màn hình tự thao tác trực tiếp với API nền tảng như `SystemChrome` hoặc Browser Fullscreen API.[cite:17][cite:19]

## Bối cảnh bài toán

Ứng dụng có luồng sử dụng điển hình là: **home → list game → chọn game → loading + kiểm tra điều kiện chơi → load webview → chơi game → thoát game**.[cite:17]

Trong luồng này, màn hình game cần chạy ở trạng thái toàn màn hình nhằm tối đa diện tích hiển thị và giảm yếu tố gây phân tâm. Trên app, yêu cầu này tương ứng với việc ẩn status bar và navigation bar của hệ điều hành; trên web, yêu cầu tương ứng với việc cố gắng đưa trình duyệt vào chế độ fullscreen.[cite:17]

Tuy nhiên, mobile app và web có cơ chế kỹ thuật khác nhau. Flutter app có thể dùng `SystemChrome` để điều khiển system UI, trong khi web không có khả năng chủ động ẩn address bar hay toolbar của trình duyệt theo cách tùy ý; cách khả thi nhất là dùng Fullscreen API, và API này thường chỉ hoạt động khi được gọi từ một thao tác trực tiếp của người dùng như tap hoặc click.[cite:17]

Nếu mỗi màn hình tự quản lý fullscreen theo cách riêng, codebase sẽ nhanh chóng rơi vào tình trạng logic phân tán, khó bảo trì, khó debug và dễ gặp lỗi trạng thái UI không nhất quán sau điều hướng hoặc khi app resume từ background.[cite:17][cite:19]

## Mục tiêu thiết kế

Thiết kế được chốt theo hướng tách riêng một **core service** chuyên trách việc tương tác với nền tảng, đóng vai trò là điểm vào duy nhất để toàn bộ ứng dụng yêu cầu thay đổi trạng thái System UI.[cite:17]

Core service này cần đạt các tiêu chí sau:

- API rõ ràng, thể hiện đúng ngữ cảnh nghiệp vụ của ứng dụng game.[cite:17]
- Tách abstraction với implementation để dễ test, dễ mock và dễ mở rộng sang nền tảng khác.[cite:17]
- Có cơ chế logging và tracing đủ tốt để debug các tình huống như apply preset thất bại, browser chặn fullscreen hoặc app resume làm mất immersive mode.[cite:17][cite:19]
- Không nhúng trực tiếp logic presentation như overlay “tap to play” hay state management của UI vào bên trong core service.[cite:17]
- Cho phép linh hoạt cấu hình preset theo state và cho phép override theo từng lần gọi API.[cite:19]

## Phạm vi package

Package được định hướng như một module nền tảng độc lập, chưa bao gồm presentation layer. Điều này có nghĩa là package chỉ giải quyết phần **hạ tầng điều khiển System UI**, còn các phần như overlay chạm để fullscreen, loading indicator, route-aware observer hay state management qua BLoC/Riverpod sẽ được thiết kế ở giai đoạn sau.[cite:17]

Những gì package này bao gồm:

- Theo dõi state System UI hiện tại.[cite:17]
- Chuyển đổi giữa các state nghiệp vụ như splash, normal, gameFocus.[cite:17]
- Áp dụng preset phù hợp lên mobile app hoặc web tùy nền tảng.[cite:17]
- Cung cấp logging, exception và cơ chế recovery.[cite:17][cite:19]
- Cho phép đăng ký preset tùy chỉnh theo từng state và override preset theo từng lần transition.[cite:19]

Những gì package này chưa bao gồm:

- Presentation overlay trên web để yêu cầu người dùng chạm vào màn hình trước khi fullscreen.[cite:17]
- Orientation management và khóa xoay màn hình.[cite:17]
- Logic quản lý WebView lifecycle.[cite:17]
- Các điều kiện nghiệp vụ để vào chơi game như session, balance hoặc eligibility check.[cite:17]

## Mô hình trạng thái nghiệp vụ

Thiết kế thống nhất dùng các state mang nghĩa nghiệp vụ thay vì đặt tên thuần kỹ thuật. Ba state chính được xác định là `splash`, `normal` và `gameFocus`.[cite:17]

### `splash`

Đây là trạng thái khi ứng dụng vừa khởi động. Mục tiêu là hiển thị màn hình thương hiệu sạch, ít nhiễu, nên trên app có thể áp dụng preset ẩn system UI hoàn toàn; trên web thì chủ yếu chỉ là state nội bộ vì browser chrome không thể bị điều khiển tùy ý ở giai đoạn này.[cite:17]

### `normal`

Đây là trạng thái mặc định của ứng dụng trong các màn hình như home, lobby, list game, settings hoặc các view thông thường khác. Ở trạng thái này, system UI nên phản ánh hành vi bình thường của nền tảng, ví dụ `edgeToEdge` trên app với status bar và navigation bar hiển thị đúng cách.[cite:17]

### `gameFocus`

Đây là trạng thái khi người dùng đang trong phiên chơi. Mục tiêu là tối đa hóa vùng hiển thị cho game, nên app sẽ dùng preset immersive như `immersiveSticky`; trên web, service sẽ cố gắng gọi Browser Fullscreen API để đưa tài liệu hoặc phần tử gốc vào fullscreen.[cite:17]

## Luồng chuyển trạng thái

Ban đầu, thiết kế dùng state machine guard chặt chẽ để chặn các transition “sai thứ tự” bằng exception ngay lập tức.[cite:17]

Sau đó, quyết định được điều chỉnh theo hướng **linh hoạt hơn**: state machine vẫn theo dõi state hiện tại và biết đâu là luồng “khuyến nghị”, nhưng không còn đóng vai trò gate keeper bắt buộc nữa. Một transition ngoài luồng tiêu chuẩn vẫn được phép tiếp tục, và hệ thống chỉ log warning để phục vụ debug.[cite:19]

Luồng khuyến nghị vẫn là:

- `splash → normal`
- `normal → gameFocus`
- `gameFocus → normal`
- `* → normal` qua `forceReset()`[cite:17][cite:19]

Cách tiếp cận này phù hợp hơn với các edge case thực tế như deep link đi thẳng vào game screen, back navigation bất ngờ, hay flow đặc biệt theo campaign mà không muốn service trở nên quá cứng nhắc.[cite:19]

## Kiến trúc tổng thể

Thiết kế package được tách thành các nhóm thành phần rõ ràng để dễ bảo trì và mở rộng.[cite:17]

### 1. Service layer

`SystemUIService` là abstract interface mà toàn bộ ứng dụng sẽ phụ thuộc vào. Đây là lớp public API theo đúng ngữ cảnh nghiệp vụ, thay vì để UI gọi thẳng `SystemChrome` hoặc `requestFullscreen()`.[cite:17]

Các implementation cụ thể gồm:

- `SystemUIServiceIO`: dành cho Android, iOS và các môi trường non-web, sử dụng `SystemChrome` để apply preset.[cite:17]
- `SystemUIServiceWeb`: dành cho Flutter Web, sử dụng Browser Fullscreen API và xử lý ràng buộc user gesture.[cite:17]

### 2. State tracking

`SystemUIStateMachine` chịu trách nhiệm lưu state hiện tại, cung cấp advisory information về transition có nằm trong luồng khuyến nghị hay không, và hỗ trợ `forceReset()` về `normal`.[cite:17][cite:19]

Điểm quan trọng là state machine không còn throw exception cho invalid transition. Nó chỉ cung cấp khả năng quan sát và chuẩn hóa việc ghi log.[cite:19]

### 3. Preset model

`SystemUIPreset` là value object immutable mô tả một cấu hình System UI, bao gồm mode và các thuộc tính liên quan đến status bar / navigation bar style. Thiết kế có các named constructor theo ngữ cảnh như `normal()`, `normalDark()`, `splash()` và `gameFocus()`.[cite:17][cite:19]

Preset model cũng được mở rộng với `copyWith()` để caller có thể biến thể nhanh từ một preset mặc định mà không phải tự tạo object mới hoàn toàn.[cite:19]

### 4. Logger abstraction

`SystemUILogger` là interface logging độc lập, cho phép package không bị khóa chặt vào một thư viện log cụ thể. Một default logger dựa trên `dart:developer` có thể được dùng ở môi trường development, trong khi production có thể inject logger khác hoặc tắt log tùy nhu cầu.[cite:17]

### 5. Exception hierarchy

Hệ thống exception giữ theo mô hình sealed hierarchy để dễ handle một cách tường minh. Sau khi bỏ strict transition enforcement, package tập trung vào hai nhóm lỗi chính:

- `SystemUIApplyFailedException`: platform API call thất bại, ví dụ `SystemChrome` hoặc `exitFullscreen()` lỗi.[cite:19]
- `SystemUIGestureRequiredException`: browser chặn request fullscreen vì lệnh không xuất phát từ thao tác người dùng.[cite:19]

## Chính sách preset và khả năng tùy biến

Một thay đổi quan trọng trong thiết kế là bổ sung cơ chế preset linh hoạt hơn thay vì phụ thuộc hoàn toàn vào preset mặc định gắn cứng với từng state.[cite:19]

### Preset resolution order

Preset được resolve theo thứ tự ưu tiên sau:[cite:19]

1. Preset override truyền trực tiếp vào method call, ví dụ `enterGameFocus(preset: customPreset)`.[cite:19]
2. Preset đã đăng ký trước cho state đó bằng `setPresetForState(state, preset)`.[cite:19]
3. Preset mặc định gắn với state, ví dụ `SystemUIState.gameFocus.defaultPreset`.[cite:17][cite:19]

Cách phân tầng này cho phép vừa có cấu hình toàn cục theo từng trạng thái, vừa có khả năng override theo từng game hoặc từng lần điều hướng đặc biệt mà không phải viết nhánh logic riêng trong service.[cite:19]

### API tùy chỉnh preset

Các API quan trọng được đưa vào interface gồm:[cite:19]

- `setPresetForState(SystemUIState state, SystemUIPreset preset)` — đăng ký preset tùy chỉnh cho một state.[cite:19]
- `resetPresetForState(SystemUIState state)` — xóa preset tùy chỉnh của state đó, quay về default.[cite:19]
- `resetAllPresets()` — xóa toàn bộ custom preset registry.[cite:19]
- `resolvePreset(SystemUIState state)` — lấy preset thực sự sẽ dùng cho state, sau khi áp dụng logic ưu tiên.[cite:19]
- Các method transition như `enterSplash`, `exitSplash`, `enterGameFocus`, `exitGameFocus`, `forceReset` đều nhận thêm tham số `preset` optional để cho phép one-time override.[cite:19]

## Hành vi theo nền tảng

### Mobile app

Trên mobile app, implementation dùng `SystemChrome` để apply `SystemUiMode` và `SystemUiOverlayStyle`. Đây là nền tảng có khả năng kiểm soát system UI tốt hơn so với web, nên hầu hết preset đều có thể hiện thực tương đối đầy đủ.[cite:17]

Một lưu ý quan trọng là Android có thể reset system UI khi app bị background rồi resume. Vì vậy service cần có `onPlatformResumed()` để re-apply preset của state hiện tại khi nhận lifecycle event `AppLifecycleState.resumed`.[cite:17]

### Web

Trên web, implementation không thể tái tạo hoàn toàn hành vi của app. Browser không cho phép ẩn address bar và toolbar một cách tự do. Cơ chế khả thi là Browser Fullscreen API, và API này yêu cầu phải được gọi từ user gesture như tap hoặc click.[cite:17]

Do đó, `enterGameFocus()` trên web có thể thất bại với `SystemUIGestureRequiredException` nếu bị gọi tự động khi route vào game screen. Đây không phải lỗi logic của app mà là ràng buộc bảo mật của browser.[cite:17][cite:19]

Giải pháp đúng ở tầng presentation là hiển thị overlay “Tap to play” hoặc tương tự, để người dùng chủ động tương tác rồi service mới thử lại lệnh fullscreen. Phần này đã được thống nhất là để dành cho phase presentation sau, không nhúng vào core service.[cite:17]

## Nguyên tắc thiết kế đã thống nhất

### Single responsibility

Mỗi thành phần chỉ làm một việc rõ ràng: service quản lý API nghiệp vụ, state machine theo dõi state, preset mô tả cấu hình, logger lo tracing và exceptions dùng để biểu diễn lỗi.[cite:17]

### Clean abstraction

UI hoặc feature module không làm việc trực tiếp với API nền tảng. Chúng chỉ phụ thuộc vào `SystemUIService`, nhờ đó dễ test, dễ thay implementation và ít coupling với Flutter platform layer.[cite:17]

### Flexible over strict

Thiết kế cuối cùng ưu tiên tính linh hoạt thay vì cưỡng ép thứ tự tuyệt đối. Service có thể xử lý các tình huống đặc biệt mà vẫn giữ trace tốt thông qua warning logs.[cite:19]

### Explicit configurability

Preset không còn là thứ “ẩn” trong implementation mà trở thành một phần của public API. Điều này giúp package minh bạch hơn, ít surprise hơn và phù hợp hơn với các game có yêu cầu UI khác nhau.[cite:19]

### Recovery first

`forceReset()` vẫn là API quan trọng để đưa hệ thống về trạng thái `normal` trong các tình huống lỗi, thoát game bất thường hoặc khi cần tự chữa trạng thái UI bị lệch sau nhiều bước điều hướng.[cite:17][cite:19]

## Điểm cần lưu ý khi triển khai sau này

### 1. Không gọi API nền tảng trực tiếp từ presentation

Presentation layer không nên gọi thẳng `SystemChrome` hoặc Browser Fullscreen API. Mọi thay đổi System UI cần đi qua service để đảm bảo state, log và preset resolution luôn nhất quán.[cite:17]

### 2. Tách System UI khỏi orientation

Quản lý xoay màn hình là một bài toán riêng. Dù thường được gọi gần nhau trong game screen, orientation service và system UI service nên tách biệt để mỗi service giữ phạm vi trách nhiệm nhỏ, rõ ràng và dễ tái sử dụng.[cite:17]

### 3. Presentation sẽ cần xử lý gesture-required flow

Với web, service chỉ trả về exception hoặc trạng thái thất bại khi browser chặn fullscreen. Chính presentation layer sẽ quyết định UX: hiện overlay, chặn input game cho tới khi fullscreen thành công, hoặc cho phép tiếp tục ở chế độ non-fullscreen nếu business chấp nhận.[cite:17][cite:19]

### 4. Web PWA là hướng tối ưu dài hạn

Fullscreen API chỉ là giải pháp tương đối. Nếu mục tiêu là trải nghiệm giống native app trên web, hướng đi tốt hơn về lâu dài là triển khai PWA với `display: fullscreen` hoặc `standalone` trong manifest để giảm phụ thuộc vào browser chrome.[cite:17]

## Đề xuất phạm vi triển khai tiếp theo

Sau khi chốt tài liệu core này, phase tiếp theo nên tập trung vào presentation và state management.[cite:17]

Thứ tự hợp lý là:

1. Bọc `SystemUIService` vào một layer quản lý state của ứng dụng, ví dụ BLoC, Cubit, Riverpod Notifier hoặc controller tương tự.[cite:17]
2. Thiết kế widget hoặc overlay cho web để xử lý luồng `GestureRequiredException`.[cite:17][cite:19]
3. Gắn service vào lifecycle của route và app lifecycle để tự động enter/exit đúng state ở splash, home, game screen và khi resume app.[cite:17]
4. Sau cùng mới tối ưu UX như loading overlay, hint text, animation hoặc recovery strategy theo từng loại game.[cite:17]

## Kết luận

Thiết kế hiện tại đã đi từ một ý tưởng fullscreen manager đơn giản sang một core module có cấu trúc rõ ràng, phân tách tốt giữa abstraction và implementation, có khả năng debug/trace, hoạt động đa nền tảng và đủ linh hoạt cho các tình huống thực tế của gaming app Flutter.[cite:17][cite:19]

Điểm thay đổi quan trọng nhất là chuyển từ mô hình state machine chặt chẽ sang state tracking linh hoạt có advisory warning, đồng thời mở thêm cơ chế preset registry và one-time override để phù hợp hơn với nhu cầu business và tính đa dạng của các loại game trong cùng hệ sinh thái ứng dụng.[cite:19]

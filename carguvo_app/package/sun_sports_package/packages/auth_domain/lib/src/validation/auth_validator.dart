class AuthValidator {
  AuthValidator._();

  static final _accentPattern = RegExp(
    r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ]',
  );

  static final _alphanumericOnlyPattern = RegExp(r'^[a-zA-Z0-9]+$');

  static final _allDigitsPattern = RegExp(r'^[0-9]+$');

  static bool hasVietnameseAccent(String text) {
    return _accentPattern.hasMatch(text);
  }

  static bool isNonAccent(String text) {
    return !hasVietnameseAccent(text);
  }

  static bool hasSpecialCharacter(String text) {
    return !_alphanumericOnlyPattern.hasMatch(text);
  }

  static bool isAllDigits(String text) {
    return _allDigitsPattern.hasMatch(text);
  }

  static bool isStrongPassword(String text) {
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(text);
    final hasDigit = RegExp(r'[0-9]').hasMatch(text);
    return hasLetter && hasDigit;
  }

  static String? validateRegisterUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.length < 6 || value.length > 15) {
      return 'Tên đăng nhập phải từ 6 đến 15 ký tự';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    return null;
  }

  static String? validateRegisterUsernameRealtime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    if (value.length < 6 || value.length > 15) {
      return 'Tên đăng nhập phải từ 6 đến 15 ký tự';
    }
    return null;
  }

  static String? validateLoginUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (value.length < 6 || value.length > 30) {
      return 'Mật khẩu phải từ 6-30 ký tự';
    }
    if (!isStrongPassword(value)) {
      return 'Mật khẩu phải gồm cả chữ và số';
    }
    return null;
  }

  static String? validatePasswordRealtime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (value.length < 6 || value.length > 30) {
      return 'Mật khẩu phải từ 6-30 ký tự';
    }
    if (!isStrongPassword(value)) {
      return 'Mật khẩu phải gồm cả chữ và số';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  static String? validateConfirmPasswordRealtime(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (password.isNotEmpty && value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  static String? validateDisplayName(String? value, String username) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên hiển thị';
    }
    if (value.length < 6 || value.length > 15) {
      return 'Tên hiển thị phải từ 6 đến 15 ký tự';
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (value.toLowerCase() == username.toLowerCase()) {
      return 'Tên hiển thị không được trùng tên đăng nhập';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    return null;
  }

  static String? validateDisplayNameRealtime(String? value, String username) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.contains(' ')) {
      return 'Không được nhập khoảng trắng';
    }
    if (!isNonAccent(value)) {
      return 'Không được nhập có dấu';
    }
    if (hasSpecialCharacter(value)) {
      return 'Không được nhập ký tự đặc biệt';
    }
    if (isAllDigits(value)) {
      return 'Không được nhập toàn bộ là số';
    }
    if (username.isNotEmpty && value.toLowerCase() == username.toLowerCase()) {
      return 'Tên hiển thị không được trùng tên đăng nhập';
    }
    if (value.length < 6 || value.length > 15) {
      return 'Tên hiển thị phải từ 6 đến 15 ký tự';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (value.length != 6) {
      return 'Mã OTP phải có 6 ký tự';
    }
    return null;
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get settings => 'Cài đặt tài khoản';

  @override
  String get preferences => 'TÙY CHỌN';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get darkEnabled => 'Giao diện tối đang bật';

  @override
  String get lightEnabled => 'Giao diện sáng đang bật';

  @override
  String get preferenceSyncFailed =>
      'Đã lưu trên thiết bị nhưng chưa đồng bộ được với máy chủ';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navProducts => 'Sản phẩm';

  @override
  String get navPending => 'Chờ duyệt';

  @override
  String get navBidRoom => 'Phòng bid';

  @override
  String get navProfile => 'Cá nhân';

  @override
  String get searchRequests => 'Tìm kiếm yêu cầu...';

  @override
  String allCount(Object count) {
    return 'Tất cả ($count)';
  }

  @override
  String pendingCount(Object count) {
    return 'Chờ duyệt ($count)';
  }

  @override
  String approvedCount(Object count) {
    return 'Đã duyệt ($count)';
  }

  @override
  String get noRequests => 'Chưa có yêu cầu';

  @override
  String get noRequestsMessage =>
      'Yêu cầu đã chuyển khoản sẽ hiển thị tại đây để chờ admin duyệt.';

  @override
  String get reload => 'Tải lại';

  @override
  String get cannotLoadRequests => 'Không tải được yêu cầu';

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get loginToViewRequests =>
      'Vui lòng đăng nhập để xem yêu cầu chờ duyệt';

  @override
  String get profileTitle => 'Cá nhân';

  @override
  String get auctionActivity => 'HOẠT ĐỘNG ĐẤU GIÁ';

  @override
  String get mySellingItems => 'Đồ tôi đang bán';

  @override
  String get auctionHistory => 'Lịch sử đấu giá';

  @override
  String get wonProducts => 'Sản phẩm đã thắng';

  @override
  String get favorites => 'Danh sách yêu thích';

  @override
  String get securityIdentity => 'BẢO MẬT VÀ ĐỊNH DANH';

  @override
  String get identityVerification => 'Xác minh danh tính';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get settingsSection => 'CÀI ĐẶT';

  @override
  String get notifications => 'Thông báo';

  @override
  String get verified => 'Đã xác thực';

  @override
  String get pendingApproval => 'Đang chờ duyệt';

  @override
  String get rejectedRetry => 'Bị từ chối - Nhấn để thử lại';

  @override
  String get notVerified => 'Chưa xác thực';

  @override
  String get loading => 'Đang tải...';

  @override
  String get emailNotUpdated => 'Chưa cập nhật email';

  @override
  String get user => 'Người dùng';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutSuccess => 'Đăng xuất thành công';

  @override
  String get withdraw => 'Rút tiền';

  @override
  String get withdrawable => 'Có thể rút';

  @override
  String get lockedDeposit => 'Tiền cọc đang giữ';

  @override
  String get history => 'Lịch sử';

  @override
  String get withdrawHistory => 'Lịch sử rút tiền';

  @override
  String maximumAmount(Object amount) {
    return 'Tối đa: $amount';
  }

  @override
  String get amount => 'Số tiền';

  @override
  String get bank => 'Ngân hàng';

  @override
  String get accountNumber => 'Số tài khoản';

  @override
  String get accountHolder => 'Chủ tài khoản';

  @override
  String get branch => 'Chi nhánh';

  @override
  String get note => 'Ghi chú';

  @override
  String get submitForApproval => 'Gửi admin xét duyệt';

  @override
  String get noWithdrawalRequests => 'Chưa có yêu cầu rút tiền';

  @override
  String get transferred => 'Đã chuyển';

  @override
  String get rejected => 'Từ chối';

  @override
  String get pending => 'Chờ duyệt';
}

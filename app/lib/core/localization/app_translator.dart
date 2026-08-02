import 'package:flutter/material.dart';

class AppTranslator {
  static const Map<String, String> _english = {
    'Cá nhân': 'Profile',
    'Trang chủ': 'Home',
    'Sản phẩm': 'Products',
    'Chờ duyệt': 'Pending',
    'Phòng bid': 'Bid room',
    'HOẠT ĐỘNG ĐẤU GIÁ': 'AUCTION ACTIVITY',
    'Đồ tôi đang bán': 'My selling items',
    'Lịch sử đấu giá': 'Auction history',
    'Sản phẩm đã thắng': 'Won products',
    'Danh sách yêu thích': 'Favorites',
    'BẢO MẬT VÀ ĐỊNH DANH': 'SECURITY AND IDENTITY',
    'Xác minh danh tính': 'Identity verification',
    'Đổi mật khẩu': 'Change password',
    'CÀI ĐẶT': 'SETTINGS',
    'Thông báo': 'Notifications',
    'Ngôn ngữ': 'Language',
    'Tiếng Việt': 'Vietnamese',
    'Chế độ tối': 'Dark mode',
    'Đăng nhập': 'Sign in',
    'Đăng ký': 'Sign up',
    'Đăng xuất': 'Log out',
    'Email': 'Email',
    'Mật khẩu': 'Password',
    'Họ và tên': 'Full name',
    'Số điện thoại': 'Phone number',
    'Xác nhận mật khẩu': 'Confirm password',
    'Tìm kiếm sản phẩm...': 'Search products...',
    'Tìm kiếm yêu cầu...': 'Search requests...',
    'Tìm kiếm': 'Search',
    'Tất cả': 'All',
    'Đang diễn ra': 'Ongoing',
    'Sắp diễn ra': 'Upcoming',
    'Đã duyệt': 'Approved',
    'Chưa có yêu cầu': 'No requests yet',
    'Tải lại': 'Reload',
    'Thử lại': 'Try again',
    'Đang tải...': 'Loading...',
    'Chưa cập nhật': 'Not updated',
    'Lịch sử': 'History',
    'Rút tiền': 'Withdraw',
    'Có thể rút': 'Available to withdraw',
    'Tiền cọc đang giữ': 'Locked deposit',
    'Ghi chú': 'Note',
    'Ngân hàng': 'Bank',
    'Số tài khoản': 'Account number',
    'Chủ tài khoản': 'Account holder',
    'Chi nhánh': 'Branch',
    'Số tiền': 'Amount',
    'Tiếp theo': 'Next',
    'Quay lại': 'Back',
    'Hoàn tất': 'Complete',
    'Xác nhận': 'Confirm',
    'Hủy': 'Cancel',
    'Lưu': 'Save',
    'Chỉnh sửa': 'Edit',
    'Chi tiết sản phẩm': 'Product details',
    'Giá hiện tại': 'Current price',
    'Giá khởi điểm': 'Starting price',
    'Thời gian còn lại': 'Time remaining',
    'Đăng ký đấu giá': 'Register for auction',
    'Tham gia phòng': 'Join room',
    'Đặt giá': 'Place bid',
    'Lịch sử đặt giá': 'Bid history',
    'Phòng đấu giá': 'Auction room',
    'Mã phòng': 'Room code',
    'Mật khẩu phòng': 'Room password',
    'Xác thực danh tính': 'Identity verification',
    'Chụp ảnh khuôn mặt': 'Capture face photo',
    'Mặt trước CCCD': 'ID front',
    'Mặt sau CCCD': 'ID back',
    'Gửi xác minh': 'Submit verification',
    'Da dong y nhan san pham': 'Product receipt confirmed',
    'Da gui bien lai cho admin kiem tra': 'Receipt sent to admin for review',
    'Dong y nhan san pham': 'Confirm product receipt',
    'Gui bien lai cho admin': 'Send receipt to admin',
    'Tai lai': 'Reload',
    'Nhap day du ma phong va mat khau': 'Enter the room code and password',
    'Vui long dang nhap': 'Please sign in',
    'Cần xác minh KYC': 'KYC verification required',
    'Chua den gio dau gia': 'The auction has not started yet',
    'Chuyển khoản đăng ký': 'Pay registration deposit',
    'Chuyển sang KYC': 'Go to KYC',
    'Đã chuyển khoản': 'Payment transferred',
    'Da hieu': 'Got it',
    'Đã hiểu': 'Got it',
    'Đang chờ admin duyệt': 'Waiting for admin approval',
    'Để sau': 'Later',
    'Đóng': 'Close',
    'Phien dau gia da bat dau': 'The auction has started',
    'Phien dau gia da ket thuc': 'The auction has ended',
    'Thông tin vào phòng': 'Room access information',
    'Tiếp tục': 'Continue',
    'Tiêu chuẩn cộng đồng': 'Community standards',
    'Xem chờ duyệt': 'View pending requests',
    'Vui lòng đồng ý với điều khoản sử dụng': 'Please accept the terms of use',
    'Vui long hoan thanh thong tin cua buoc hien tai':
        'Please complete the current step',
    'Vào phòng bid': 'Enter bid room',
    'Chưa hỗ trợ đổi ảnh tại đây':
        'Changing the photo is not supported here yet',
    'Đã cập nhật thông tin thành công': 'Information updated successfully',
    'Chua co so du co the rut': 'No withdrawable balance',
    'Da gui yeu cau rut tien': 'Withdrawal request submitted',
    'Chon anh tu thiet bi': 'Choose an image from device',
    'Edit Setting': 'Edit settings',
    'Không tìm thấy access token': 'Access token not found',
    'Cap nhat setting thanh cong': 'Settings updated successfully',
    'Dang xuat thanh cong': 'Logged out successfully',
    'Tôi đồng ý với tiêu chuẩn cộng đồng và quy chế đấu giá.':
        'I agree to the community standards and auction rules.',
    'Bạn cần hoàn tất KYC trước khi đăng ký đấu giá vào phòng.':
        'You must complete KYC before registering for this auction.',
    'Bạn đã xác nhận chuyển khoản. Yêu cầu đăng ký đấu giá đang chờ admin kiểm tra tiền cọc.':
        'Your transfer was confirmed. The deposit is awaiting admin review.',
    'Tiền cọc đã được admin duyệt. Bạn có thể dùng mã phòng và mật khẩu dưới đây để vào phòng đấu giá.':
        'Your deposit was approved. Use the room code and password below to join.',
    'Vui lòng cung cấp hình ảnh rõ nét của CMND hoặc CCCD bản gốc để xác minh danh tính của bạn.':
        'Provide clear photos of your original ID card for identity verification.',
    'Vui lòng thực hiện chụp ảnh chân dung của bạn để đảm bảo tính bảo mật và xác minh danh tính chính chủ.':
        'Take a portrait photo to securely verify your identity.',
    'Vui long cung cap thong tin chinh xac theo CMND/CCCD de qua trinh xac minh dien ra nhanh hon.':
        'Provide accurate ID information to speed up verification.',
    'Vui long kiem tra ky thong tin truoc khi gui yeu cau KYC.':
        'Review your information before submitting the KYC request.',
    'Nguoi xep hang truoc da bi loai. Ban co muon nhan san pham voi gia da dau khong?':
        'The previous winner was disqualified. Do you want the product at your bid price?',
  };

  static String translate(BuildContext context, String text) {
    if (Localizations.localeOf(context).languageCode != 'en') return text;
    final exact = _english[text];
    if (exact != null) return exact;

    var result = text;
    const phrases = <String, String>{
      'Tất cả': 'All',
      'Chờ duyệt': 'Pending',
      'Đã duyệt': 'Approved',
      'Sản phẩm': 'Product',
      'Đấu giá': 'Auction',
      'đấu giá': 'auction',
      'Đang tải': 'Loading',
      'Chưa có': 'No',
      'Không có': 'No',
      'Thành công': 'Success',
      'thành công': 'successfully',
      'Thất bại': 'Failed',
      'Vui lòng': 'Please',
      'Nhập': 'Enter',
      'Tìm kiếm': 'Search',
      'Cập nhật': 'Update',
      'Xác nhận': 'Confirm',
      'Thông tin': 'Information',
      'Trạng thái': 'Status',
      'Ngày sinh': 'Date of birth',
      'Giới tính': 'Gender',
      'Quốc tịch': 'Nationality',
      'Địa chỉ': 'Address',
      'Họ và tên': 'Full name',
      'Số điện thoại': 'Phone number',
      'Mật khẩu': 'Password',
      'Lịch sử': 'History',
      'Tải lại': 'Reload',
      'Phong dau gia': 'Auction room',
      'Lich su dau gia': 'Auction history',
      'Chua co luot dau nao': 'No bids yet',
      'Chua co nguoi dang ky': 'No registered users',
      'Nguoi da dang ky dau gia': 'Registered bidders',
      'Dan dau': 'Leading',
      'XEM TAT CA': 'VIEW ALL',
      'NHAP TIEN CONG THEM': 'ENTER ADDITIONAL AMOUNT',
      'Con phai thanh toan': 'Remaining payment',
      'Thanh toan dau gia': 'Auction payment',
      'Nhap ma phong va mat khau duoc cung cap de tham gia.':
          'Enter the provided room code and password to join.',
      'MA PHONG': 'ROOM CODE',
      'MAT KHAU': 'PASSWORD',
      'GIAO DICH BAO MAT': 'SECURE TRANSACTION',
      'ĐANG DẪN ĐẦU': 'LEADING',
      'Quen mat khau?': 'Forgot password?',
      'Chào mừng trở lại với ReBid': 'Welcome back to ReBid',
      'Tôi đồng ý với điều khoản sử dụng và chính sách bảo mật của hệ thống.':
          'I agree to the terms of use and privacy policy.',
      'Du lieu tu backend': 'Backend data',
      'Chi con vai phut cuoi': 'Only a few minutes left',
      'Sap ket thuc': 'Ending soon',
      'Chua co san pham sap ket thuc': 'No products ending soon',
      'TRỰC TIẾP': 'LIVE',
      'GIÁ HIỆN TẠI': 'CURRENT PRICE',
      'Cơ hội sở hữu ngay lúc này': 'Your chance to own it now',
      'Đấu giá trực tiếp': 'Live auctions',
      'Chưa có sản phẩm đấu giá': 'No auction products yet',
      '1 sản phẩm': '1 product',
      'Căn chỉnh khuôn mặt vào giữa khung hình':
          'Align your face in the center of the frame',
      'Tải lên tài liệu': 'Upload documents',
      'Xác thực khuôn mặt': 'Face verification',
      'Mẹo chụp ảnh đẹp': 'Photo tips',
      'Kiem tra thong tin': 'Review information',
      'Trang thai hien tai': 'Current status',
      'BƯỚC': 'STEP',
      'TRÊN': 'OF',
      'Gửi lúc': 'Submitted at',
      'Gia khoi diem': 'Starting price',
      'GIA KHOI DIEM': 'STARTING PRICE',
      'TRANG THAI': 'STATUS',
      'NGAY GIO BAT DAU': 'START DATE AND TIME',
      'THONG SO SAN PHAM': 'PRODUCT SPECIFICATIONS',
      'CHUNG CHI SO DI KEM': 'INCLUDED CERTIFICATES',
      'Không có sản phẩm phù hợp': 'No matching products',
      'Chi tiết': 'Details',
      'Chỉnh sửa cá nhân': 'Edit profile',
      'Lan gui lai': 'Resubmission',
      'Hang': 'Rank',
      'Xac nhan thanh toan': 'Confirm payment',
      'San pham da thang': 'Won products',
    };
    for (final entry in phrases.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }
}

class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) => Text(
    AppTranslator.translate(context, data),
    style: style,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
  );
}

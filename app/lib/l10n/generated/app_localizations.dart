import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt tài khoản'**
  String get settings;

  /// No description provided for @preferences.
  ///
  /// In vi, this message translates to:
  /// **'TÙY CHỌN'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Anh'**
  String get english;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @darkEnabled.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện tối đang bật'**
  String get darkEnabled;

  /// No description provided for @lightEnabled.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện sáng đang bật'**
  String get lightEnabled;

  /// No description provided for @preferenceSyncFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu trên thiết bị nhưng chưa đồng bộ được với máy chủ'**
  String get preferenceSyncFailed;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm'**
  String get navProducts;

  /// No description provided for @navPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get navPending;

  /// No description provided for @navBidRoom.
  ///
  /// In vi, this message translates to:
  /// **'Phòng bid'**
  String get navBidRoom;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get navProfile;

  /// No description provided for @searchRequests.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm yêu cầu...'**
  String get searchRequests;

  /// No description provided for @allCount.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả ({count})'**
  String allCount(Object count);

  /// No description provided for @pendingCount.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt ({count})'**
  String pendingCount(Object count);

  /// No description provided for @approvedCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt ({count})'**
  String approvedCount(Object count);

  /// No description provided for @noRequests.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có yêu cầu'**
  String get noRequests;

  /// No description provided for @noRequestsMessage.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đã chuyển khoản sẽ hiển thị tại đây để chờ admin duyệt.'**
  String get noRequestsMessage;

  /// No description provided for @reload.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại'**
  String get reload;

  /// No description provided for @cannotLoadRequests.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được yêu cầu'**
  String get cannotLoadRequests;

  /// No description provided for @tryAgain.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get tryAgain;

  /// No description provided for @loginToViewRequests.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để xem yêu cầu chờ duyệt'**
  String get loginToViewRequests;

  /// No description provided for @profileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get profileTitle;

  /// No description provided for @auctionActivity.
  ///
  /// In vi, this message translates to:
  /// **'HOẠT ĐỘNG ĐẤU GIÁ'**
  String get auctionActivity;

  /// No description provided for @mySellingItems.
  ///
  /// In vi, this message translates to:
  /// **'Đồ tôi đang bán'**
  String get mySellingItems;

  /// No description provided for @auctionHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử đấu giá'**
  String get auctionHistory;

  /// No description provided for @wonProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm đã thắng'**
  String get wonProducts;

  /// No description provided for @favorites.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách yêu thích'**
  String get favorites;

  /// No description provided for @securityIdentity.
  ///
  /// In vi, this message translates to:
  /// **'BẢO MẬT VÀ ĐỊNH DANH'**
  String get securityIdentity;

  /// No description provided for @identityVerification.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh danh tính'**
  String get identityVerification;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @settingsSection.
  ///
  /// In vi, this message translates to:
  /// **'CÀI ĐẶT'**
  String get settingsSection;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @verified.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác thực'**
  String get verified;

  /// No description provided for @pendingApproval.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ duyệt'**
  String get pendingApproval;

  /// No description provided for @rejectedRetry.
  ///
  /// In vi, this message translates to:
  /// **'Bị từ chối - Nhấn để thử lại'**
  String get rejectedRetry;

  /// No description provided for @notVerified.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác thực'**
  String get notVerified;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @emailNotUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật email'**
  String get emailNotUpdated;

  /// No description provided for @user.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng'**
  String get user;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @logoutSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất thành công'**
  String get logoutSuccess;

  /// No description provided for @withdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút tiền'**
  String get withdraw;

  /// No description provided for @withdrawable.
  ///
  /// In vi, this message translates to:
  /// **'Có thể rút'**
  String get withdrawable;

  /// No description provided for @lockedDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Tiền cọc đang giữ'**
  String get lockedDeposit;

  /// No description provided for @history.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get history;

  /// No description provided for @withdrawHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử rút tiền'**
  String get withdrawHistory;

  /// No description provided for @maximumAmount.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa: {amount}'**
  String maximumAmount(Object amount);

  /// No description provided for @amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get amount;

  /// No description provided for @bank.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get bank;

  /// No description provided for @accountNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số tài khoản'**
  String get accountNumber;

  /// No description provided for @accountHolder.
  ///
  /// In vi, this message translates to:
  /// **'Chủ tài khoản'**
  String get accountHolder;

  /// No description provided for @branch.
  ///
  /// In vi, this message translates to:
  /// **'Chi nhánh'**
  String get branch;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @submitForApproval.
  ///
  /// In vi, this message translates to:
  /// **'Gửi admin xét duyệt'**
  String get submitForApproval;

  /// No description provided for @noWithdrawalRequests.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có yêu cầu rút tiền'**
  String get noWithdrawalRequests;

  /// No description provided for @transferred.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển'**
  String get transferred;

  /// No description provided for @rejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get pending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Account Settings';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkEnabled => 'Dark interface enabled';

  @override
  String get lightEnabled => 'Light interface enabled';

  @override
  String get preferenceSyncFailed =>
      'Saved on this device but could not sync with the server';

  @override
  String get navHome => 'Home';

  @override
  String get navProducts => 'Products';

  @override
  String get navPending => 'Pending';

  @override
  String get navBidRoom => 'Bid room';

  @override
  String get navProfile => 'Profile';

  @override
  String get searchRequests => 'Search requests...';

  @override
  String allCount(Object count) {
    return 'All ($count)';
  }

  @override
  String pendingCount(Object count) {
    return 'Pending ($count)';
  }

  @override
  String approvedCount(Object count) {
    return 'Approved ($count)';
  }

  @override
  String get noRequests => 'No requests yet';

  @override
  String get noRequestsMessage =>
      'Transferred deposit requests will appear here for admin approval.';

  @override
  String get reload => 'Reload';

  @override
  String get cannotLoadRequests => 'Could not load requests';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loginToViewRequests => 'Please sign in to view pending requests';

  @override
  String get profileTitle => 'Profile';

  @override
  String get auctionActivity => 'AUCTION ACTIVITY';

  @override
  String get mySellingItems => 'My selling items';

  @override
  String get auctionHistory => 'Auction history';

  @override
  String get wonProducts => 'Won products';

  @override
  String get favorites => 'Favorites';

  @override
  String get securityIdentity => 'SECURITY AND IDENTITY';

  @override
  String get identityVerification => 'Identity verification';

  @override
  String get changePassword => 'Change password';

  @override
  String get settingsSection => 'SETTINGS';

  @override
  String get notifications => 'Notifications';

  @override
  String get verified => 'Verified';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get rejectedRetry => 'Rejected - Tap to retry';

  @override
  String get notVerified => 'Not verified';

  @override
  String get loading => 'Loading...';

  @override
  String get emailNotUpdated => 'Email not updated';

  @override
  String get user => 'User';

  @override
  String get logout => 'Log out';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get withdrawable => 'Available to withdraw';

  @override
  String get lockedDeposit => 'Locked deposit';

  @override
  String get history => 'History';

  @override
  String get withdrawHistory => 'Withdrawal history';

  @override
  String maximumAmount(Object amount) {
    return 'Maximum: $amount';
  }

  @override
  String get amount => 'Amount';

  @override
  String get bank => 'Bank';

  @override
  String get accountNumber => 'Account number';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get branch => 'Branch';

  @override
  String get note => 'Note';

  @override
  String get submitForApproval => 'Submit for admin approval';

  @override
  String get noWithdrawalRequests => 'No withdrawal requests';

  @override
  String get transferred => 'Transferred';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';
}

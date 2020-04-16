import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/route_authentication_use_case.dart';
import 'package:lykke_mobile_mavn/base/dependency_injection/app_module.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/common/offer_type.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/country/response_model/countries_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/country/response_model/country_codes_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/partner_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/real_estate_properties_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/spend_rules_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/wallet_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/earn/response_model/earn_rule_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/earn/response_model/extended_earn_rule_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/maintenance/response_model/maintenance_response_model.dart';
import 'package:lykke_mobile_mavn/base/router/base_router.dart';
import 'package:lykke_mobile_mavn/base/router/router_page_factory.dart';
import 'package:lykke_mobile_mavn/base/router/router_page_names.dart';
import 'package:lykke_mobile_mavn/feature_bottom_bar/view/scanned_info_dialog.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/view/email_verification_page.dart';
import 'package:lykke_mobile_mavn/feature_real_estate_payment/utility_model/extended_instalment_model.dart';
import 'package:lykke_mobile_mavn/feature_wallet_linking/bloc/link_wallet_bloc.dart';
import 'package:lykke_mobile_mavn/library_dependency_injection/core.dart';
import 'package:lykke_mobile_mavn/library_qr_actions/actions/qr_base_action.dart';
import 'package:lykke_mobile_mavn/library_ui_components/dialog/custom_dialog.dart';
import 'package:lykke_mobile_mavn/library_ui_components/dialog/delete_account_dialog.dart';
import 'package:lykke_mobile_mavn/library_ui_components/dialog/enable_biometrics_dialog.dart';
import 'package:lykke_mobile_mavn/library_ui_components/dialog/log_out_confirmation_dialog.dart';
import 'package:lykke_mobile_mavn/library_ui_components/error/wallet_disabled_dialog.dart';
import 'package:store_redirect/store_redirect.dart';

class Router extends BaseRouter {
  Router({
    @required GlobalKey<NavigatorState> globalNavigatorStateKey,
    @required GlobalKey globalBottomNavBarStateKey,
  }) : super(globalNavigatorStateKey, globalBottomNavBarStateKey);

  //region Splash, Onboarding, Welcome
  Future<void> pushRootOnboardingPage() async {
    await pushRootPage(
      RouterPageFactory.getOnboardingPage(),
      pageName: RouterPageName.onboardingPage,
    );
  }

  Future<void> pushOnboardingPage() async {
    await pushPage(
      RouterPageFactory.getOnboardingPage(),
      pageName: RouterPageName.onboardingPage,
    );
  }

  Future<void> pushWelcomePage() async {
    await pushPage(
      RouterPageFactory.getWelcomePage(),
      pageName: RouterPageName.welcomePage,
    );
  }

  Future<void> replaceWithWelcomePage() async {
    await replacePage(
      RouterPageFactory.getWelcomePage(),
      pageName: RouterPageName.welcomePage,
    );
  }

  Future<void> pushRootWelcomePage() async {
    await pushRootPage(
      RouterPageFactory.getWelcomePage(),
      pageName: RouterPageName.welcomePage,
    );
  }

  Future<void> pushRootWelcomePageForMultiPush() async {
    await pushRootPageForMultiPush(
      RouterPageFactory.getWelcomePage(),
      pageName: RouterPageName.welcomePage,
    );
  }

  //endregion Splash, Onboarding, Welcome

  //region Authentication
  //region Login
  Future<void> pushLoginPage(
      {bool unauthorizedInterceptorRedirection = false}) async {
    await pushPage(
      RouterPageFactory.getLoginPage(
        unauthorizedInterceptorRedirection: unauthorizedInterceptorRedirection,
      ),
      pageName: RouterPageName.loginPage,
    );
  }

  Future<void> pushLoginPageForMultiPush({
    bool unauthorizedInterceptorRedirection = false,
  }) async {
    await pushPageForMultiPush(
      RouterPageFactory.getLoginPage(
        unauthorizedInterceptorRedirection: unauthorizedInterceptorRedirection,
      ),
      pageName: RouterPageName.loginPage,
    );
  }

  Future<void> navigateToLoginPage(
      {bool unauthorizedInterceptorRedirection = false}) {
    this
      ..pushRootWelcomePageForMultiPush()
      ..pushLoginPage(
          unauthorizedInterceptorRedirection:
              unauthorizedInterceptorRedirection);
  }

  Future<void> replaceWithLoginPage(
      {bool unauthorizedInterceptorRedirection = false}) async {
    await replacePage(
      RouterPageFactory.getLoginPage(
        unauthorizedInterceptorRedirection: unauthorizedInterceptorRedirection,
      ),
      pageName: RouterPageName.loginPage,
    );
  }

  //endregion Login

  //region PIN
  Future<void> pushRootPinCreatePage() async {
    await pushRootPage(
      RouterPageFactory.getPinCreatePage(),
      pageName: RouterPageName.pinCreatePage,
    );
  }

  Future<void> pushPinConfirmPage(List<int> passCode) async {
    await pushPage(
      RouterPageFactory.getPinConfirmPage(passCode),
      pageName: RouterPageName.pinConfirmPage,
    );
  }

  Future<void> pushPinForgotPage() async {
    await pushPage(RouterPageFactory.getPinForgotPage(),
        pageName: RouterPageName.pinForgotPage);
  }

  Future<void> pushRootPinCreatedSuccessPage() async {
    await pushRootPage(
      RouterPageFactory.getPinCreatedSuccessPage(),
      pageName: RouterPageName.pinCreatedSuccessPage,
    );
  }

  Future<void> pushRootSignInPage() async {
    await pushRootPage(
      RouterPageFactory.getPinSignInPage(),
      pageName: RouterPageName.pinSignInPage,
    );
  }

  Future<bool> pushPinVerificationPage() async => pushPage(
        RouterPageFactory.getPinVerificationPage(),
        pageName: RouterPageName.pinVerificationPage,
      );

  Future<void> pushRootBiometricAgreementPage(
      {@required bool unauthorizedInterceptorRedirection}) async {
    await pushRootPage(
      RouterPageFactory.getBiometricAgreementPage(
          unauthorizedInterceptorRedirection:
              unauthorizedInterceptorRedirection),
      pageName: RouterPageName.biometricAgreementPage,
    );
  }

  //endregion PIN

  //region Registration
  Future<void> pushRegisterPage() async {
    await pushPage(
      RouterPageFactory.getRegisterPage(),
      pageName: RouterPageName.registerPage,
    );
  }

  Future<void> navigateToRegisterPage() {
    this
      ..pushRootWelcomePageForMultiPush()
      ..pushRegisterPage();
  }

  Future<void> pushRootEmailVerificationPage({
    @required String email,
    @required VerificationStatus status,
  }) async {
    await pushRootPage(
        RouterPageFactory.getEmailVerificationPage(
            email: email, status: status),
        pageName: RouterPageName.emailVerificationPage);
  }

  //TODO: Remove isEmailVerificationCurrentRoute custom implementation once
  //we have ModalRoute.of(_navigatorKey.currentContext) working as expected.
  bool get isEmailVerificationCurrentRoute => _isEmailVerificationCurrentRoute;

  bool _isEmailVerificationCurrentRoute = false;

  void markAsClosedEmailConfirmationPage() {
    _isEmailVerificationCurrentRoute = false;
  }

  Future<void> replaceWithEmailConfirmationPage() async {
    _isEmailVerificationCurrentRoute = true;

    await replacePage(RouterPageFactory.getEmailConfirmationPage(),
        pageName: RouterPageName.emailConfirmationPage);
  }

  Future<void> replaceWithEmailVerificationSuccessPage() async {
    await replacePage(RouterPageFactory.getEmailVerificationSuccessPage(),
        pageName: RouterPageName.emailVerificationSuccessPage);
  }

  //endregion Registration

  //region Password
  Future<void> pushResetPasswordPage() async {
    await pushPage(
      RouterPageFactory.getResetPasswordPage(),
      pageName: RouterPageName.resetPasswordPage,
    );
  }

  Future<void> pushSetPasswordPage(String email, String resetIdentifier) async {
    await pushPage(
      RouterPageFactory.getSetPasswordPage(email, resetIdentifier),
      pageName: RouterPageName.resetPasswordPage,
    );
  }

  Future<void> pushChangePasswordPage() async {
    await pushPage(
      RouterPageFactory.getChangePasswordPage(),
      pageName: RouterPageName.changePasswordPage,
    );
  }

  Future<void> replaceWithChangePasswordSuccessPage() async {
    await replacePage(
      RouterPageFactory.getChangePasswordSuccessPage(),
      pageName: RouterPageName.changePasswordSuccessPage,
    );
  }

  Future<void> replaceWithSetPasswordSuccessPage() async {
    await replacePage(
      RouterPageFactory.getSetPasswordSuccessPage(),
      pageName: RouterPageName.setPasswordSuccessPage,
    );
  }

  //endregion Password

  //region Misc authentication
  Future<void> navigateToAuthenticationFlow(
      RouteAuthenticationTarget target) async {
    switch (target.page) {
      case RouteAuthenticationPage.welcome:
        await pushRootWelcomePage();
        break;
      case RouteAuthenticationPage.biometricAgreement:
        await pushRootBiometricAgreementPage(
            unauthorizedInterceptorRedirection: false);
        break;
      case RouteAuthenticationPage.createPin:
        await pushRootPinCreatePage();
        break;
      case RouteAuthenticationPage.signInWithPin:
        await pushRootSignInPage();
        break;
      case RouteAuthenticationPage.verifyEmail:
        await pushRootEmailVerificationPage(
            email: target.data, status: VerificationStatus.noCode);
        break;
      case RouteAuthenticationPage.home:
        await pushRootBottomBarPage();
        break;
      case RouteAuthenticationPage.onboarding:
        await pushRootOnboardingPage();
        break;
      case RouteAuthenticationPage.mandatoryAppUpgrade:
        await pushRootMandatoryAppUpgradePage();
        break;
    }
  }

  Future<void> pushAccountDeactivatedPage() async {
    await pushPage(
      RouterPageFactory.getAccountDeactivatedPage(),
      pageName: RouterPageName.accountDeactivatedPage,
    );
  }

  Future<bool> showEnableBiometricsDialog() =>
      showDialog(child: EnableBiometricsDialog());

  Future<bool> showLogOutConfirmationDialog() =>
      showDialog(child: LogOutConfirmationDialog());

  Future<bool> showDeleteAccountDialog() =>
      showDialog(child: DeleteAccountDialog());

  //endregion Misc authentication

  //endregion Authentication

  //region Home
  Future<void> pushRootBottomBarPage() async {
    await pushRootPage(
      RouterPageFactory.getBottomBarPage(),
      pageName: RouterPageName.homePage,
    );
  }

  Future<void> pushRootLandingPage() async {
    await pushRootPage(
      RouterPageFactory.getLandingPage(),
      pageName: RouterPageName.landingPage,
    );
  }

  Future<void> navigateToLandingPage() async {
    await pushRootLandingPage();
  }

  void switchToHomeTab() => switchToTabAtIndex(0);

  void switchToOffersTab() => switchToTabAtIndex(1);

  void switchToWalletTab() => switchToTabAtIndex(3);

  void switchToSocialTab() => switchToTabAtIndex(4);

  //endregion Home

  //region Referrals

  //region Lead Referral
  Future<void> pushLeadReferralPage(ExtendedEarnRule extendedEarnRule) async {
    await pushPage(
      RouterPageFactory.getLeadReferralPage(extendedEarnRule),
      pageName: RouterPageName.leadReferralPage,
    );
  }

  Future<void> replaceWithLeadReferralSuccessPage({
    @required String refereeFirstName,
    @required String refereeLastName,
    @required ExtendedEarnRule extendedEarnRule,
  }) async {
    await replacePage(
      RouterPageFactory.getLeadReferralSuccessPage(
        refereeFirstName,
        refereeLastName,
        extendedEarnRule,
      ),
      pageName: RouterPageName.leadReferralSuccessPage,
    );
  }

  //TODO: Remove isLeadReferralAcceptedCurrentRoute custom implementation once
  //we have ModalRoute.of(_navigatorKey.currentContext) working as expected.
  bool get isLeadReferralAcceptedCurrentRoute =>
      _isLeadReferralAcceptedCurrentRoute;

  bool _isLeadReferralAcceptedCurrentRoute = false;

  Future<void> pushLeadReferralAcceptedPage() async {
    _isLeadReferralAcceptedCurrentRoute = true;

    await pushPage(
      RouterPageFactory.getLeadReferralAcceptedPage(),
      pageName: RouterPageName.leadReferralAcceptedPage,
    );
  }

  void markAsClosedLeadReferralAcceptedPage() {
    _isLeadReferralAcceptedCurrentRoute = false;
  }

  //endregion Lead Referral

  //region Hotel Referral

  Future<void> pushHotelReferralPage(ExtendedEarnRule extendedEarnRule) async {
    await pushPage(
      RouterPageFactory.getHotelReferralPage(extendedEarnRule),
      pageName: RouterPageName.hotelReferralPage,
    );
  }

  Future<void> replaceWithHotelReferralSuccessPage({
    @required String refereeFullName,
    @required ExtendedEarnRule extendedEarnRule,
  }) async {
    await replacePage(
      RouterPageFactory.getHotelReferralSuccessPage(
        refereeFullName,
        extendedEarnRule,
      ),
      pageName: RouterPageName.hotelReferralSuccessPage,
    );
  }

  //TODO: Remove isHotelReferralAcceptedCurrentRoute custom implementation once
  //we have ModalRoute.of(_navigatorKey.currentContext) working as expected.
  bool get isHotelReferralAcceptedCurrentRoute =>
      _isHotelReferralAcceptedCurrentRoute;

  bool _isHotelReferralAcceptedCurrentRoute = false;

  Future<void> pushHotelReferralAcceptedPage() async {
    _isHotelReferralAcceptedCurrentRoute = true;

    await pushPage(
      RouterPageFactory.getHotelReferralAcceptedPage(),
      pageName: RouterPageName.hotelReferralAcceptedPage,
    );
  }

  void markAsClosedHotelReferralAcceptedPage() {
    _isHotelReferralAcceptedCurrentRoute = false;
  }

  //endregion Hotel Referral

  //region Friend Referral
  Future<void> pushFriendReferralPage(ExtendedEarnRule extendedEarnRule) async {
    await pushPage(
      RouterPageFactory.getFriendReferralPage(extendedEarnRule),
      pageName: RouterPageName.friendReferralPage,
    );
  }

  Future<void> replaceWithFriendReferralSuccessPage() async {
    await replacePage(
      RouterPageFactory.getFriendReferralSuccessPage(),
      pageName: RouterPageName.friendReferralSuccessPage,
    );
  }

  //endregion Friend Referral

  Future<void> pushReferralListPage() async {
    await pushPage(RouterPageFactory.getReferralListPage(),
        pageName: RouterPageName.referralListPage);
  }

  //endregion Referrals

  //region Utilities
  //region Country
  Future<CountryCode> pushCountryCodePage() => pushPage<CountryCode>(
        RouterPageFactory.getCountryCodeListPage(),
        pageName: RouterPageName.countryCodeListPage,
      );

  Future<Country> pushCountryPage({String pageTitle}) => pushPage<Country>(
        RouterPageFactory.getCountryListPage(pageTitle: pageTitle),
        pageName: RouterPageName.countryListPage,
      );

  //endregion Country

  //region Maintenance
  //TODO: Remove isMaintenancePageCurrentRoute custom implementation once we
  //have ModalRoute.of(_navigatorKey.currentContext) working in dio interceptors
  bool get isMaintenancePageCurrentRoute => _isMaintenancePageCurrentRoute;

  bool _isMaintenancePageCurrentRoute = false;

  void closeMaintenancePageAndNavigateToLogin() {
    _isMaintenancePageCurrentRoute = false;
    navigateToLoginPage();
  }

  Future<void> pushRootMaintenancePage(
      MaintenanceResponseModel maintenanceModel) async {
    _isMaintenancePageCurrentRoute = true;

    await pushRootPage(
      RouterPageFactory.getMaintenancePage(maintenanceModel),
      pageName: RouterPageName.maintenancePage,
      fullScreenDialog: true,
    );
  }

  //endregion Maintenance

  //region Dialogs
  Future<bool> showCustomDialog({
    @required String title,
    @required String content,
    @required String positiveButtonText,
    @required String negativeButtonText,
  }) =>
      showDialog(
        child: CustomDialog(
          title: title,
          content: content,
          positiveButtonText: positiveButtonText,
          negativeButtonText: negativeButtonText,
        ),
      );

  Future<void> showWalletDisabledDialog() async {
    await showDialog(
      child: const WalletDisabledDialog(),
      isDismissible: false,
    );
  }

  //endregion Dialogs
  //endregion Utilities

  //region Transactions & Payments
  Future<void> pushTransactionFormPage({String emailAddress}) async {
    await pushPage(
      RouterPageFactory.getTransactionFormPage(emailAddress: emailAddress),
      pageName: RouterPageName.transactionFormPage,
    );
  }

  Future<void> replaceWithTransactionSuccessPage() async {
    await replacePage(
      RouterPageFactory.getP2pTransactionSuccessPage(),
      pageName: RouterPageName.p2pTransactionSuccessPage,
    );
  }

  Future<void> pushP2PReceiveTokenPage() async {
    await pushPage(
      RouterPageFactory.getP2PReceiveTokenPage(),
      pageName: RouterPageName.p2pReceiveTokenPage,
    );
  }

  Future<bool> pushPaymentRequestPage(
    String paymentRequestId, {
    bool fromPushNotification = false,
  }) =>
      pushPage(
        RouterPageFactory.getPaymentRequestPage(paymentRequestId,
            fromPushNotification: fromPushNotification),
        pageName: RouterPageName.paymentRequestPage,
      );

  Future<void> replaceWithPaymentRequestApprovalSuccessPage() async {
    await replacePage(
      RouterPageFactory.getPaymentRequestApprovalSuccessPage(),
      pageName: RouterPageName.paymentRequestApprovalSuccessPage,
    );
  }

  Future<void> pushPaymentRequestExpiredPage() async {
    await pushPage(
      RouterPageFactory.getPaymentRequestExpiredPage(),
      pageName: RouterPageName.paymentRequestExpiredPage,
    );
  }

  Future<void> pushPaymentRequestListPage() async {
    await pushPage(
      RouterPageFactory.getPaymentRequestListPage(),
      pageName: RouterPageName.paymentRequestListPage,
    );
  }

  Future<void> redirectToAppStores() => StoreRedirect.redirect();

  Future<void> redirectToCustomAppStore({String androidId, String iosId}) =>
      StoreRedirect.redirect(androidAppId: androidId, iOSAppId: iosId);

  //endregion Transactions & Payments

  //region Spend & Earn Rules

  Future<void> pushStakingDetailsPage(ExtendedEarnRule extendedEarnRule) async {
    await pushPage(
      RouterPageFactory.getStakingDetailsPage(extendedEarnRule),
      pageName: RouterPageName.stakingDetailsPage,
    );
  }

  Future<void> pushSpendDetailsByType(SpendRule spendRule) async {
    switch (spendRule.type) {
      case OfferVertical.hospitality:
        return pushOfferDetailsPage(spendRule);
      case OfferVertical.realEstate:
        return pushPropertyListPage(spendRule);
      case OfferVertical.retail:
        return pushOfferDetailsPage(spendRule);
    }
  }

  Future<void> pushOfferDetailsPage(SpendRule spendRule) async {
    await pushPage(
      RouterPageFactory.getSpendOfferDetailsPage(spendRule),
      pageName: RouterPageName.offerDetailsPage,
    );
  }

  Future<void> pushEarnRuleDetailsPage(EarnRule earnRule) async {
    await pushPage(
      RouterPageFactory.getEarnRuleDetailPage(earnRule),
      pageName: RouterPageName.earnRuleDetailsPage,
    );
  }

  Future<void> pushPropertyPaymentPage({
    @required String spendRuleId,
    @required Property property,
    @required ExtendedInstalmentModel extendedInstalment,
  }) async {
    await pushPage(
      RouterPageFactory.getPropertyPaymentPage(
        spendRuleId,
        property,
        extendedInstalment,
      ),
      pageName: RouterPageName.propertyPaymentPage,
    );
  }

  Future<void> pushPropertyListPage(SpendRule spendRule) async {
    await pushPage(
      RouterPageFactory.getPropertyListPage(spendRule),
      pageName: RouterPageName.propertyListPage,
    );
  }

  Future<void> pushInstalmentListPage({
    @required String spendRuleId,
    @required Property property,
  }) async {
    await pushPage(
      RouterPageFactory.getInstalmentListPage(
        spendRuleId,
        property,
      ),
      pageName: RouterPageName.instalmentListPage,
    );
  }

  Future<void> pushPropertyPaymentSuccessPage() async {
    await pushPage(
      RouterPageFactory.getPropertyPaymentSuccessPage(),
      pageName: RouterPageName.propertyPaymentSuccessPage,
    );
  }

  Future<void> pushVoucherRedemptionSuccessPage({
    @required String voucherCode,
  }) async {
    await replacePage(
      RouterPageFactory.getRedemptionSuccessfulPage(voucherCode: voucherCode),
      pageName: RouterPageName.redemptionSuccessfulPage,
    );
  }

  //endregion Spend & Earn Rules

  //region Link Wallet

  Future<void> pushLinkedWalletSendPage() async {
    await pushPage(
      RouterPageFactory.getLinkedWalletSendPage(),
      pageName: RouterPageName.linkedWalletSendPage,
    );
  }

  Future<void> pushLinkedWalletSendProgressPage() async {
    await pushPage(
      RouterPageFactory.getLinkedWalletSendProgressPage(),
      pageName: RouterPageName.linkedWalletSendProgressPage,
    );
  }

  Future<void> pushLinkedWalletSendFailedPage(
      {@required String amount, @required String error}) async {
    await pushPage(
      RouterPageFactory.getLinkedWalletSendFailedPage(
        amount: amount,
        error: error,
      ),
      pageName: RouterPageName.linkedWalletSendFailedPage,
    );
  }

  Future<void> pushLinkWalletByStatus(WalletLinkingStatusType status) async {
    switch (status) {
      case WalletLinkingStatusType.notLinked:
      case WalletLinkingStatusType.pendingCustomerApproval:
        return pushLinkWalletPage();
      case WalletLinkingStatusType.pending:
      case WalletLinkingStatusType.pendingConfirmationInBlockchain:
        return pushLinkWalletInProgressPage();
      case WalletLinkingStatusType.linked:
        return pushLinkedWalletPage();
    }
  }

  Future<void> pushLinkWalletPage() async {
    await pushPage(
      RouterPageFactory.getLinkWalletPage(),
      pageName: RouterPageName.linkWalletPage,
    );
  }

  Future<void> pushLinkedWalletPage() async {
    await pushPage(
      RouterPageFactory.getLinkedWalletPage(),
      pageName: RouterPageName.linkedWalletPage,
    );
  }

  Future<void> pushLinkWalletInProgressPage() async {
    await pushPage(
      RouterPageFactory.getLinkWalletInProgressPage(),
      pageName: RouterPageName.linkWalletInProgressPage,
    );
  }

  Future<void> pushLinkSimpleWalletPage() async {
    await pushPage(
      RouterPageFactory.getLinkSimpleWalletPage(),
      pageName: RouterPageName.linkSimpleWalletPage,
    );
  }

  Future<void> replaceWithLinkWalletInProgressPage() async {
    await replacePage(
      RouterPageFactory.getLinkWalletInProgressPage(),
      pageName: RouterPageName.linkWalletInProgressPage,
    );
  }

  Future<void> pushUnlinkWalletInProgressPage() async {
    await pushPage(
      RouterPageFactory.getUnlinkWalletInProgressPage(),
      pageName: RouterPageName.unlinkWalletInProgressPage,
    );
  }

  Future<void> pushLinkWalletByType(LinkWalletType type) async {
    switch (type) {
      case LinkWalletType.simple:
        return pushLinkSimpleWalletPage();
      case LinkWalletType.advanced:
        return pushLinkAdvancedWalletPage();
    }
  }

  Future<void> pushLinkAdvancedWalletPage() async {
    await pushPage(
      RouterPageFactory.getLinkAdvancedWalletPage(),
      pageName: RouterPageName.linkAdvancedWalletPage,
    );
  }

  Future<void> pushLinkWalletReceivePage() async {
    await pushPage(
      RouterPageFactory.getLinkWalletReceivePage(),
      pageName: RouterPageName.linkWalletReceivePage,
    );
  }

  //endregion Link Wallet

  //region Partners
  Future<void> showHotelWelcomeDialog(String partnerMessageId) async {
    await showDialog(
        child: RouterPageFactory.getHotelWelcomeDialog(partnerMessageId));
  }

  Future<void> showHotelPreCheckoutDialog(String paymentRequestId) async {
    await showDialog(
        child: RouterPageFactory.getHotelPreCheckoutDialog(paymentRequestId));
  }

  Future<void> pushPartnerListPage(List<Partner> partners) async {
    await pushPage(
      RouterPageFactory.getPartnerListPage(partners),
      pageName: RouterPageName.partnerListPage,
    );
  }

  //endregion Partners

  //region AccountPage

  Future<void> pushAccountPage() async {
    await pushPage(
      RouterPageFactory.getAccountPage(),
      pageName: RouterPageName.accountPage,
    );
  }

  //endregion AccountPage

  //region Static pages from Account
  Future<void> pushContactUsPage() async {
    await pushPage(
      RouterPageFactory.getContactUsPage(),
      pageName: RouterPageName.contactUsPage,
    );
  }

  Future<void> pushPersonalDetailsPage() async {
    await pushPage(
      RouterPageFactory.getPersonalDetailsPage(),
      pageName: RouterPageName.personalDetailsPage,
    );
  }

  Future<void> pushTermsOfUsePage() async {
    await pushPage(
      RouterPageFactory.getTermsOfUsePage(),
      pageName: RouterPageName.termsOfUsePage,
    );
  }

  Future<void> pushPrivacyPolicyPage() async {
    await pushPage(
      RouterPageFactory.getPrivacyPolicyPage(),
      pageName: RouterPageName.privacyPolicyPage,
    );
  }

  Future<void> pushRootMandatoryAppUpgradePage() async {
    await pushRootPage(
      RouterPageFactory.getMandatoryAppUpgradePage(),
      pageName: RouterPageName.mandatoryAppUpgradePage,
    );
  }

//endregion Static pages from Account

  //region Vouchers
  Future<void> pushVoucherListPage() async {
    await pushPage(
      RouterPageFactory.getVoucherListPage(),
      pageName: RouterPageName.voucherListPage,
    );
  }

  //endregion Vouchers

  //region Misc

  Future<bool> showScannedInfoDialog(QrBaseAction action) => showDialog(
        child: ScannedInfoDialog(action: action),
      );

  //endregion Misc

  //region Notifications

  Future<void> pushNotificationListPage() async {
    await pushPage(
      RouterPageFactory.getNotificationListPage(),
      pageName: RouterPageName.notificationListPage,
    );
  }

//endregion Notifications
}

Router useRouter() => ModuleProvider.of<AppModule>(useContext()).router;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lykke_mobile_mavn/app/bloc/app_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/accept_hotel_referral_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/accept_hotel_referral_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/accept_lead_referral_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/accept_lead_referral_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/country_code_list_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/country_code_list_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/country_list_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/earn_rule_list_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/generic_list_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/spend_rule_list_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/clear_secure_storage_use_case.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/get_mobile_settings_use_case.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/has_pin_use_case.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/logout_use_case.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/route_authentication_use_case.dart';
import 'package:lykke_mobile_mavn/base/date/date_time_manager.dart';
import 'package:lykke_mobile_mavn/base/dependency_injection/app_module.dart';
import 'package:lykke_mobile_mavn/base/local_data_source/secure_store/secure_store.dart';
import 'package:lykke_mobile_mavn/base/local_data_source/shared_preferences_manager/shared_preferences_manager.dart';
import 'package:lykke_mobile_mavn/base/local_data_source/sim_info/sim_card_info_manager.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/conversion/conversion_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/country/country_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/country/response_model/countries_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/customer_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/change_password_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/login_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/spend_rules_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/earn/earn_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/earn/response_model/earn_rule_condition_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/earn/response_model/earn_rule_list_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/earn/response_model/extended_earn_rule_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/email/email_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/error/exception_to_message_mapper.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/mobile/response_model/mobile_settings_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/partner/partner_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/partner/response_model/payment_request_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/partner/response_model/payments_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/phone/phone_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/referral/referral_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/spend/spend_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/wallet/response_model/transaction_response_model.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/wallet/wallet_api.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/remote_config_manager/remote_config_manager.dart';
import 'package:lykke_mobile_mavn/base/repository/balance_repository/balance_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/conversion/conversion_respository.dart';
import 'package:lykke_mobile_mavn/base/repository/country/country_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/customer/customer_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/earn/earn_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/email/email_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/local/local_settings_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/mapper/referral_to_ui_model_mapper.dart';
import 'package:lykke_mobile_mavn/base/repository/mobile/mobile_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/notification/notification_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/partner/partner_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/phone/phone_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/pin/pin_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/referral/referral_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/spend/spend_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/token/token_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/user/user_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/voucher/voucher_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/wallet/wallet_repository.dart';
import 'package:lykke_mobile_mavn/base/router/external_router.dart';
import 'package:lykke_mobile_mavn/base/router/router.dart';
import 'package:lykke_mobile_mavn/base/router/router_page_factory.dart';
import 'package:lykke_mobile_mavn/feature_balance/bloc/balance/balance_bloc.dart';
import 'package:lykke_mobile_mavn/feature_biometrics/bloc/biometric_bloc.dart';
import 'package:lykke_mobile_mavn/feature_biometrics/bloc/biometric_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_bottom_bar/analytics/bottom_bar_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_bottom_bar/bloc/bottom_bar_page_bloc.dart';
import 'package:lykke_mobile_mavn/feature_bottom_bar/bloc/bottom_bar_refresh_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_bottom_bar/di/bottom_bar_module.dart';
import 'package:lykke_mobile_mavn/feature_change_password/analytics/change_password_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_change_password/bloc/change_password_bloc.dart';
import 'package:lykke_mobile_mavn/feature_change_password/bloc/change_password_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_change_password/di/change_password_module.dart';
import 'package:lykke_mobile_mavn/feature_change_password/use_case/change_password_use_case.dart';
import 'package:lykke_mobile_mavn/feature_debug_menu/bloc/debug_menu_bloc.dart';
import 'package:lykke_mobile_mavn/feature_earn/analytics/earn_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_earn/di/earn_module.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/analytics/email_verification_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_verification_bloc.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_verification_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/timer_bloc.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/timer_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/di/email_verification_module.dart';
import 'package:lykke_mobile_mavn/feature_home/bloc/staking_referrals_bloc.dart';
import 'package:lykke_mobile_mavn/feature_home/bloc/staking_referrals_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_home/di/staking_referrals_module.dart';
import 'package:lykke_mobile_mavn/feature_hotel_pre_checkout/bloc/hotel_pre_checkout_bloc.dart';
import 'package:lykke_mobile_mavn/feature_hotel_pre_checkout/di/hotel_pre_checkout_di.dart';
import 'package:lykke_mobile_mavn/feature_hotel_referral/bloc/hotel_referral_bloc.dart';
import 'package:lykke_mobile_mavn/feature_hotel_referral/bloc/hotel_referral_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_hotel_referral/di/hotel_referral_module.dart';
import 'package:lykke_mobile_mavn/feature_hotel_welcome/bloc/hotel_welcome_bloc.dart';
import 'package:lykke_mobile_mavn/feature_hotel_welcome/di/hotel_welcome_di.dart';
import 'package:lykke_mobile_mavn/feature_lead_referral/bloc/lead_referal_bloc.dart';
import 'package:lykke_mobile_mavn/feature_lead_referral/bloc/lead_referral_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_lead_referral/di/lead_referral_di.dart';
import 'package:lykke_mobile_mavn/feature_login/anaytics/login_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_login/bloc/login_bloc.dart';
import 'package:lykke_mobile_mavn/feature_login/bloc/login_form_bloc.dart';
import 'package:lykke_mobile_mavn/feature_login/bloc/login_form_state.dart';
import 'package:lykke_mobile_mavn/feature_login/di/login_module.dart';
import 'package:lykke_mobile_mavn/feature_login/use_case/login_use_case.dart';
import 'package:lykke_mobile_mavn/feature_notification/bloc/notification_count_bloc.dart';
import 'package:lykke_mobile_mavn/feature_notification/bloc/notification_count_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_notification/di/notification_module.dart';
import 'package:lykke_mobile_mavn/feature_onboarding/analytics/onboarding_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_onboarding/di/onboarding_module.dart';
import 'package:lykke_mobile_mavn/feature_p2p_transactions/analytics/transaction_form_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_p2p_transactions/bloc/barcode_scanner_manager.dart';
import 'package:lykke_mobile_mavn/feature_p2p_transactions/bloc/transaction_form_bloc.dart';
import 'package:lykke_mobile_mavn/feature_p2p_transactions/bloc/transaction_form_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_p2p_transactions/di/transaction_form_module.dart';
import 'package:lykke_mobile_mavn/feature_password_validation/bloc/password_validation_bloc.dart';
import 'package:lykke_mobile_mavn/feature_password_validation/bloc/password_validation_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_password_validation/di/password_validation_module.dart';
import 'package:lykke_mobile_mavn/feature_payment_request/bloc/partner_conversion_rate_bloc.dart';
import 'package:lykke_mobile_mavn/feature_payment_request/bloc/payment_request_bloc.dart';
import 'package:lykke_mobile_mavn/feature_payment_request/bloc/payment_request_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_payment_request/bloc/payment_request_details_bloc.dart';
import 'package:lykke_mobile_mavn/feature_payment_request/bloc/payment_request_details_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_payment_request/di/payment_request_module.dart';
import 'package:lykke_mobile_mavn/feature_payment_request_list/bloc/completed_payment_requests_bloc.dart';
import 'package:lykke_mobile_mavn/feature_payment_request_list/bloc/failed_payment_requests_bloc.dart';
import 'package:lykke_mobile_mavn/feature_payment_request_list/bloc/pending_payment_requests_bloc.dart';
import 'package:lykke_mobile_mavn/feature_payment_request_list/di/partner_payments_module.dart';
import 'package:lykke_mobile_mavn/feature_personal_details/bloc/personal_details_bloc.dart';
import 'package:lykke_mobile_mavn/feature_personal_details/bloc/personal_details_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_personal_details/di/personal_details_module.dart';
import 'package:lykke_mobile_mavn/feature_pin/bloc/pin_forgot_bloc.dart';
import 'package:lykke_mobile_mavn/feature_pin/di/pin_module.dart';
import 'package:lykke_mobile_mavn/feature_pin/use_case/get_biometric_type_use_case.dart';
import 'package:lykke_mobile_mavn/feature_property_payment/bloc/property_payment_bloc.dart';
import 'package:lykke_mobile_mavn/feature_property_payment/bloc/property_payment_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_property_payment/bloc/spend_rule_conversion_rate_bloc.dart';
import 'package:lykke_mobile_mavn/feature_property_payment/di/property_payment_module.dart';
import 'package:lykke_mobile_mavn/feature_receive_token/bloc/p2p_receive_token_bloc.dart';
import 'package:lykke_mobile_mavn/feature_receive_token/bloc/p2p_receive_token_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_receive_token/di/p2p_receive_token_module.dart';
import 'package:lykke_mobile_mavn/feature_referral_list/bloc/referral_list_bloc.dart';
import 'package:lykke_mobile_mavn/feature_register/analytics/register_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_register/bloc/register_bloc.dart';
import 'package:lykke_mobile_mavn/feature_register/di/register_module.dart';
import 'package:lykke_mobile_mavn/feature_register/use_case/register_use_case.dart';
import 'package:lykke_mobile_mavn/feature_spend/analytics/redeem_transfer_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_spend/analytics/spend_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_spend/bloc/spend_rule_detail_bloc.dart';
import 'package:lykke_mobile_mavn/feature_spend/bloc/spend_rule_detail_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_spend/bloc/voucher_bloc.dart';
import 'package:lykke_mobile_mavn/feature_spend/bloc/voucher_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_spend/di/spend_module.dart';
import 'package:lykke_mobile_mavn/feature_spend/di/spend_rule_detail_module.dart';
import 'package:lykke_mobile_mavn/feature_spend/di/transfer_module.dart';
import 'package:lykke_mobile_mavn/feature_splash/bloc/splash_bloc.dart';
import 'package:lykke_mobile_mavn/feature_splash/bloc/splash_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_splash/use_case/save_mobile_settings_use_case.dart';
import 'package:lykke_mobile_mavn/feature_theme/bloc/theme_bloc.dart';
import 'package:lykke_mobile_mavn/feature_theme/bloc/theme_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_ticker/bloc/ticker_bloc.dart';
import 'package:lykke_mobile_mavn/feature_ticker/bloc/ticker_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_ticker/di/ticker_module.dart';
import 'package:lykke_mobile_mavn/feature_transaction_history/bloc/transaction_history_bloc.dart';
import 'package:lykke_mobile_mavn/feature_user_verification/bloc/user_verification_bloc.dart';
import 'package:lykke_mobile_mavn/feature_wallet/bloc/wallet_bloc.dart';
import 'package:lykke_mobile_mavn/feature_wallet/bloc/wallet_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_wallet/di/wallet_page_module.dart';
import 'package:lykke_mobile_mavn/feature_wallet_unlinking/bloc/unlink_wallet_bloc.dart';
import 'package:lykke_mobile_mavn/feature_wallet_unlinking/bloc/unlink_wallet_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_wallet_unlinking/di/wallet_unlinking_module.dart';
import 'package:lykke_mobile_mavn/feature_welcome/analytics/welcome_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_welcome/di/welcome_module.dart';
import 'package:lykke_mobile_mavn/lib_dynamic_links/dynamic_link_manager.dart';
import 'package:lykke_mobile_mavn/library_analytics/analytics_service.dart';
import 'package:lykke_mobile_mavn/library_fcm/bloc/firebase_messaging_bloc.dart';
import 'package:lykke_mobile_mavn/library_fcm/bloc/firebase_messaging_bloc_output.dart';
import 'package:lykke_mobile_mavn/library_models/token_currency.dart';
import 'package:lykke_mobile_mavn/library_qr_actions/qr_content_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/bloc.dart';

//region App dependencies
class MockRouter extends Mock implements Router {}

class MockExternalRouter extends Mock implements ExternalRouter {}

class MockAppModule extends Mock implements AppModule {}

class MockRouterPageFactory extends Mock implements RouterPageFactory {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockSecureStore extends Mock implements SecureStore {}

class MockSharedPreferencesManager extends Mock
    implements SharedPreferencesManager {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockRemoteConfigManager extends Mock implements RemoteConfigManager {}

class MockRemoteConfig extends Mock implements RemoteConfig {}

//endregion App dependencies
//region APIs
class MockCustomerApi extends Mock implements CustomerApi {}

class MockCountryApi extends Mock implements CountryApi {}

class MockWalletApi extends Mock implements WalletApi {}

class MockPartnerApi extends Mock implements PartnerApi {}

class MockConversionApi extends Mock implements ConversionApi {}

class MockEmailApi extends Mock implements EmailApi {}

class MockPhoneApi extends Mock implements PhoneApi {}

class MockReferralApi extends Mock implements ReferralApi {}

class MockEarnApi extends Mock implements EarnApi {}

class MockSpendApi extends Mock implements SpendApi {}

//endregion APIs
//region Repositories
class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockCountryRepository extends Mock implements CountryRepository {}

class MockTokenRepository extends Mock implements TokenRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockWalletRealTimeRepository extends Mock
    implements WalletRealTimeRepository {}

class MockPartnerRepository extends Mock implements PartnerRepository {}

class MockPinRepository extends Mock implements PinRepository {}

class MockMobileRepository extends Mock implements MobileSettingsRepository {}

class MockLocalSettingsRepository extends Mock
    implements LocalSettingsRepository {}

class MockConversionRepository extends Mock implements ConversionRepository {}

class MockEmailRepository extends Mock implements EmailRepository {}

class MockPhoneRepository extends Mock implements PhoneRepository {}

class MockReferralRepository extends Mock implements ReferralRepository {}

class MockEarnRepository extends Mock implements EarnRepository {}

class MockVoucherRepository extends Mock implements VoucherRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockSpendRepository extends Mock implements SpendRepository {}

//endregion
//region Analytics Managers
class MockOnboardingAnalyticsManager extends Mock
    implements OnboardingAnalyticsManager {}

class MockRegisterAnalyticsManager extends Mock
    implements RegisterAnalyticsManager {}

class MockLoginAnalyticsManager extends Mock implements LoginAnalyticsManager {}

class MockBottomBarAnalyticsManager extends Mock
    implements BottomBarAnalyticsManager {}

class MockTransactionFormAnalyticsManager extends Mock
    implements TransactionFormAnalyticsManager {}

class MockChangePasswordAnalyticsManager extends Mock
    implements ChangePasswordAnalyticsManager {}

class MockEmailVerificationAnalyticsManager extends Mock
    implements EmailVerificationAnalyticsManager {}

class MockWelcomeAnalyticsManager extends Mock
    implements WelcomeAnalyticsManager {}

class MockSpendAnalyticsManager extends Mock implements SpendAnalyticsManager {}

class MockRedeemTransferAnalyticsManager extends Mock
    implements RedeemTransferAnalyticsManager {}

class MockEarnAnalyticsManager extends Mock implements EarnAnalyticsManager {}

//endregion Analytics Managers
//region Modules
class MockOnboardingModule extends Mock implements OnboardingModule {}

class MockLoginModule extends Mock implements LoginModule {}

class MockRegisterModule extends Mock implements RegisterModule {}

class MockBottomBarModule extends Mock implements BottomBarModule {}

class MockLeadReferralModule extends Mock implements LeadReferralModule {}

class MockP2PReceiveTokenModule extends Mock implements P2PReceiveTokenModule {}

class MockPersonalDetailsModule extends Mock implements PersonalDetailsModule {}

class MockSpendRuleDetailModule extends Mock implements SpendRuleDetailModule {}

class MockTransactionFormModule extends Mock implements TransactionFormModule {}

class MockPropertyPaymentModule extends Mock implements PropertyPaymentModule {}

class MockChangePasswordModule extends Mock implements ChangePasswordModule {}

class MockWalletPageModule extends Mock implements WalletPageModule {}

class MockPaymentRequestModule extends Mock implements PaymentRequestModule {}

class MockPartnerPaymentsModule extends Mock implements PartnerPaymentsModule {}

class MockHotelWelcomeModule extends Mock implements HotelWelcomeModule {}

class MockHotelPreCheckoutModule extends Mock
    implements HotelPreCheckoutModule {}

class MockEmailVerificationModule extends Mock
    implements EmailVerificationModule {}

class MockPasswordValidationModule extends Mock
    implements PasswordValidationModule {}

class MockHotelReferralModule extends Mock implements HotelReferralModule {}

class MockPinModule extends Mock implements PinModule {}

class MockTickerModule extends Mock implements TickerModule {}

class MockWalletUnlinkingModule extends Mock implements WalletUnlinkingModule {}

class MockStakingReferralsModule extends Mock
    implements StakingReferralsModule {}

class MockNotificationModule extends Mock implements NotificationModule {}

class MockWelcomeModule extends Mock implements WelcomeModule {}

class MockSpendModule extends Mock implements SpendModule {}

class MockRedeemTransferModule extends Mock implements RedeemTransferModule {}

class MockEarnModule extends Mock implements EarnModule {}

//endregion Modules
//region Blocs
class MockAppBloc extends MockBloc<AppState> implements AppBloc {
  MockAppBloc(AppState initialState) : super(initialState);
}

class MockDebugMenuBloc extends MockBloc<DebugMenuState>
    implements DebugMenuBloc {
  MockDebugMenuBloc(DebugMenuState initialState) : super(initialState);
}

class MockLoginBloc extends MockBloc<LoginState> implements LoginBloc {
  MockLoginBloc(LoginState initialState) : super(initialState);
}

class MockLoginFormBloc extends MockBloc<LoginFormState>
    implements LoginFormBloc {
  MockLoginFormBloc(LoginFormState initialState) : super(initialState);
}

class MockRegisterBloc extends MockBloc<RegisterState> implements RegisterBloc {
  MockRegisterBloc(RegisterState initialState) : super(initialState);
}

class MockBalanceBloc extends MockBloc<BalanceState> implements BalanceBloc {
  MockBalanceBloc(BalanceState initialState) : super(initialState);
}

class MockBottomBarPageBloc extends MockBloc<RefreshState>
    implements BottomBarPageBloc {
  MockBottomBarPageBloc(RefreshState initialState) : super(initialState);
}

class MockLeadReferralBloc extends MockBloc<LeadReferralState>
    implements LeadReferralBloc {
  MockLeadReferralBloc(LeadReferralState initialState) : super(initialState);
}

class MockTransactionHistoryBloc extends MockBloc<TransactionHistoryState>
    implements TransactionHistoryBloc {
  MockTransactionHistoryBloc(TransactionHistoryState initialState)
      : super(initialState);
}

class MockAcceptHotelReferralBloc extends MockBloc<AcceptHotelReferralState>
    implements AcceptHotelReferralBloc {
  MockAcceptHotelReferralBloc(AcceptHotelReferralState initialState)
      : super(initialState);
}

class MockHotelReferralBloc extends MockBloc<HotelReferralState>
    implements HotelReferralBloc {
  MockHotelReferralBloc(HotelReferralState initialState) : super(initialState);
}

class MockLeadReferralListBloc extends MockBloc<GenericListState>
    implements ReferralListBloc {
  MockLeadReferralListBloc(GenericListState initialState) : super(initialState);
}

class MockAcceptLeadReferralBloc extends MockBloc<AcceptLeadReferralState>
    implements AcceptLeadReferralBloc {
  MockAcceptLeadReferralBloc(AcceptLeadReferralState initialState)
      : super(initialState);
}

class MockHotelReferralListBloc extends MockBloc<GenericListState>
    implements ReferralListBloc {
  MockHotelReferralListBloc(GenericListState initialState)
      : super(initialState);
}

class MockP2PReceiveTokenBloc extends MockBloc<ReceiveTokenPageState>
    implements P2pReceiveTokenBloc {
  MockP2PReceiveTokenBloc(ReceiveTokenPageState initialState)
      : super(initialState);
}

class MockCountryCodeListBloc extends MockBloc<CountryCodeListState>
    implements CountryCodeListBloc {
  MockCountryCodeListBloc(CountryCodeListState initialState)
      : super(initialState);
}

class MockCountryListBloc extends MockBloc<CountryListState>
    implements CountryListBloc {
  MockCountryListBloc(CountryListState initialState) : super(initialState);
}

class MockTransactionFormBloc extends MockBloc<TransactionFormState>
    implements TransactionFormBloc {
  MockTransactionFormBloc(TransactionFormState initialState)
      : super(initialState);
}

class MockPropertyPaymentBloc extends MockBloc<PropertyPaymentState>
    implements PropertyPaymentBloc {
  MockPropertyPaymentBloc(PropertyPaymentState initialState)
      : super(initialState);
}

class MockChangePasswordBloc extends MockBloc<ChangePasswordState>
    implements ChangePasswordBloc {
  MockChangePasswordBloc(ChangePasswordState initialState)
      : super(initialState);
}

class MockSpendRuleListBloc extends MockBloc<GenericListState>
    implements SpendRuleListBloc {
  MockSpendRuleListBloc(GenericListState initialState) : super(initialState);
}

class MockEarnRuleListBloc extends MockBloc<GenericListState>
    implements EarnRuleListBloc {
  MockEarnRuleListBloc(GenericListState initialState) : super(initialState);
}

class MockPersonalDetailsBloc extends MockBloc<PersonalDetailsState>
    implements PersonalDetailsBloc {
  MockPersonalDetailsBloc(PersonalDetailsState initialState)
      : super(initialState);
}

class MockSpendRuleDetailBloc extends MockBloc<SpendRuleDetailState>
    implements SpendRuleDetailBloc {
  MockSpendRuleDetailBloc(SpendRuleDetailState initialState)
      : super(initialState);
}

class MockVoucherPurchaseBloc extends MockBloc<VoucherPurchaseState>
    implements VoucherPurchaseBloc {
  MockVoucherPurchaseBloc(VoucherPurchaseState initialState)
      : super(initialState);
}

class MockPaymentRequestDetailsBloc extends MockBloc<PaymentRequestDetailsState>
    implements PaymentRequestDetailsBloc {
  MockPaymentRequestDetailsBloc(PaymentRequestDetailsState initialState)
      : super(initialState);
}

class MockPaymentRequestBloc extends MockBloc<PaymentRequestState>
    implements PaymentRequestBloc {
  MockPaymentRequestBloc(PaymentRequestState initialState)
      : super(initialState);
}

class MockPartnerPaymentsPendingBloc extends MockBloc<GenericListState>
    implements PendingPartnerPaymentsBloc {
  MockPartnerPaymentsPendingBloc(GenericListState initialState)
      : super(initialState);
}

class MockPartnerPaymentsCompletedBloc extends MockBloc<GenericListState>
    implements CompletedPartnerPaymentsBloc {
  MockPartnerPaymentsCompletedBloc(GenericListState initialState)
      : super(initialState);
}

class MockPartnerPaymentsFailedBloc extends MockBloc<GenericListState>
    implements FailedPartnerPaymentsBloc {
  MockPartnerPaymentsFailedBloc(GenericListState initialState)
      : super(initialState);
}

class MockHotelWelcomeBloc extends MockBloc<HotelWelcomeState>
    implements HotelWelcomeBloc {
  MockHotelWelcomeBloc(HotelWelcomeState initialState) : super(initialState);
}

class MockHotelPreCheckoutBloc extends MockBloc<HotelPreCheckoutState>
    implements HotelPreCheckoutBloc {
  MockHotelPreCheckoutBloc(HotelPreCheckoutState initialState)
      : super(initialState);
}

class MockSplashBloc extends MockBloc<SplashState> implements SplashBloc {
  MockSplashBloc(SplashState initialState) : super(initialState);
}

class MockBiometricBloc extends MockBloc<BiometricState>
    implements BiometricBloc {
  MockBiometricBloc(BiometricState initialState) : super(initialState);
}

class MockSpendRuleConversionRateBloc
    extends MockBloc<SpendRuleConversionRateState>
    implements SpendRuleConversionRateBloc {
  MockSpendRuleConversionRateBloc(SpendRuleConversionRateState initialState)
      : super(initialState);
}

class MockPartnerConversionRateBloc extends MockBloc<PartnerConversionRateState>
    implements PartnerConversionRateBloc {
  MockPartnerConversionRateBloc(PartnerConversionRateState initialState)
      : super(initialState);
}

class MockCustomerBloc extends MockBloc<CustomerState> implements CustomerBloc {
  MockCustomerBloc(CustomerState initialState) : super(initialState);
}

class MockEmailVerificationBloc extends MockBloc<EmailVerificationState>
    implements EmailVerificationBloc {
  MockEmailVerificationBloc(EmailVerificationState initialState)
      : super(initialState);
}

class MockEmailConfirmationBloc extends MockBloc<EmailConfirmationState>
    implements EmailConfirmationBloc {
  MockEmailConfirmationBloc(EmailConfirmationState initialState)
      : super(initialState);
}

class MockTimerBloc extends MockBloc<TimerState> implements TimerBloc {
  MockTimerBloc(TimerState initialState) : super(initialState);
}

class MockPasswordValidationBloc extends MockBloc<PasswordValidationState>
    implements PasswordValidationBloc {
  MockPasswordValidationBloc(PasswordValidationState initialState)
      : super(initialState);
}

class MockTickerBloc extends MockBloc<TickerState> implements TickerBloc {
  MockTickerBloc(TickerState initialState) : super(initialState);
}

class MockWalletBloc extends MockBloc<WalletState> implements WalletBloc {
  MockWalletBloc(WalletState initialState) : super(initialState);
}

class MockPinForgotBloc extends Mock implements PinForgotBloc {}

class MockUnlinkWalletBloc extends MockBloc<UnlinkWalletSubmissionState>
    implements UnlinkWalletBloc {
  MockUnlinkWalletBloc(UnlinkWalletSubmissionState initialState)
      : super(initialState);
}

class MockUserVerificationBloc extends Mock implements UserVerificationBloc {}

class MockStakingReferralsBloc extends MockBloc<StakingReferralsState>
    implements StakingReferralsBloc {
  MockStakingReferralsBloc(StakingReferralsState initialState)
      : super(initialState);
}

class MockNotificationCountBloc extends MockBloc<NotificationCountState>
    implements NotificationCountBloc {
  MockNotificationCountBloc(NotificationCountState initialState)
      : super(initialState);
}

class MockFirebaseMessagingBloc extends MockBloc<FirebaseMessagingState>
    implements FirebaseMessagingBloc {
  MockFirebaseMessagingBloc(FirebaseMessagingState initialState)
      : super(initialState);
}

class MockThemeBloc extends MockBloc<ThemeState> implements ThemeBloc {
  MockThemeBloc(ThemeState initialState) : super(initialState);
}

//endregion Blocs
//region Use Cases

class MockGetBiometricTypeUseCase extends Mock
    implements GetBiometricTypeUseCase {}

class MockLogOutUseCase extends Mock implements LogOutUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

class MockSaveMobileSettingsUseCase extends Mock
    implements SaveMobileSettingsUseCase {}

class MockGetMobileSettingsUseCase extends Mock
    implements GetMobileSettingsUseCase {}

class MockClearSecureStorageUseCase extends Mock
    implements ClearSecureStorageUseCase {}

class MockRouteAuthenticationUseCase extends Mock
    implements RouteAuthenticationUseCase {}

class MockHasPinUseCase extends Mock implements HasPinUseCase {}

class MockExceptionToMessageMapper extends Mock
    implements ExceptionToMessageMapper {}

//endregion Use Cases
//region Response Models
class MockLoginResponseModel extends Mock implements LoginResponseModel {}

class MockCountryListResponseModel extends Mock
    implements CountryListResponseModel {}

class MockTransactionResponseModel extends Mock
    implements TransactionResponseModel {}

// ignore: must_be_immutable
class MockSpendRuleListResponseModel extends Mock
    implements SpendRuleListResponseModel {}

// ignore: must_be_immutable
class MockEarnRuleListResponseModel extends Mock
    implements EarnRuleListResponseModel {}

class MockChangePasswordResponseModel extends Mock
    implements ChangePasswordResponseModel {}

class MockPartnerPaymentsResponseModel extends Mock
    implements PartnerPaymentsResponseModel {}

class MockExtendedEarnRule extends Mock implements ExtendedEarnRule {}

class MockTokenCurrency extends Mock implements TokenCurrency {}

class MockCondition extends Mock implements EarnRuleCondition {}

// ignore: must_be_immutable
class MockMobileSettings extends Mock implements MobileSettings {}

//endregion Response Models
//region Misc
class MockValueNotifier<T> extends Mock implements ValueNotifier<T> {}

class MockSimCardInfoManager extends Mock implements SimCardInfoManager {}

class MockPaymentRequestResponseModel extends Mock
    implements PaymentRequestResponseModel {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockBarcodeScannerManager extends Mock implements BarcodeScanManager {}

class MockDynamicLinkManager extends Mock implements DynamicLinkManager {}

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockDateTimeManager extends Mock implements DateTimeManager {}

class MockReferralToUiModelMapper extends Mock
    implements ReferralToUiModelMapper {}

class MockQrContentManager extends Mock implements QrContentManager {}

class MockStopwatch extends Mock implements Stopwatch {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

//endregion Misc

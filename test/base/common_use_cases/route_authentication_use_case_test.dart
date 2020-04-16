import 'package:flutter_test/flutter_test.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/route_authentication_use_case.dart';
import 'package:lykke_mobile_mavn/base/remote_data_source/api/customer/response_model/customer_response_model.dart';
import 'package:lykke_mobile_mavn/feature_biometrics/bloc/biometric_bloc_output.dart';
import 'package:mockito/mockito.dart';

import '../../feature_login/use_case/login_use_case_test.dart';
import '../../mock_classes.dart';
import '../../test_constants.dart';

final _mockLocalSettingsRepository = MockLocalSettingsRepository();
final _mockUserRepository = MockUserRepository();
final _mockHasPinUseCase = MockHasPinUseCase();
final _mockCustomerRepository = MockCustomerRepository();
final _mockTokenRepository = MockTokenRepository();
final _mockBiometricBloc = MockBiometricBloc(BiometricUninitializedState());

void main() {
  group('RouteAuthenticationUseCase tests', () {
    RouteAuthenticationUseCase subject;

    setUp(() {
      reset(_mockLocalSettingsRepository);
      reset(_mockUserRepository);
      reset(_mockHasPinUseCase);
      reset(_mockCustomerRepository);
      reset(_mockTokenRepository);
      reset(_mockBiometricBloc);

      when(_mockTokenRepository.getLoginToken()).thenAnswer(
        (_) => Future.value(TestConstants.stubLoginToken),
      );

      subject = RouteAuthenticationUseCase(
        _mockLocalSettingsRepository,
        _mockUserRepository,
        _mockHasPinUseCase,
        _mockCustomerRepository,
        _mockBiometricBloc,
        _mockTokenRepository,
      );
    });

    test('onBoarding', () async {
      _when(
        hasBeenPreviouslyLoggedIn: false,
        userShouldSeeOnboarding: true,
      );

      final target = await subject.execute();

      expect(target,
          const RouteAuthenticationTarget(RouteAuthenticationPage.onboarding));
    });

    test('welcome', () async {
      _when(
        hasBeenPreviouslyLoggedIn: false,
        userShouldSeeOnboarding: false,
      );

      final target = await subject.execute();

      expect(target,
          const RouteAuthenticationTarget(RouteAuthenticationPage.welcome));
    });

    test('verifyEmail', () async {
      _when(
        hasBeenPreviouslyLoggedIn: true,
        userShouldSeeOnboarding: false,
        isUserVerified: false,
        customer: TestConstants.verifiedEmailNonVerifiedPhoneCustomer,
      );

      final target = await subject.execute();

      expect(
          target,
          RouteAuthenticationTarget(
            RouteAuthenticationPage.verifyEmail,
            data: stubEmail,
          ));
    });

    test('biometricAgreement', () async {
      _when(
        hasBeenPreviouslyLoggedIn: true,
        userShouldSeeOnboarding: false,
        isUserVerified: true,
        hasPin: false,
        shouldAskUserToEnableBiometrics: true,
      );

      final target = await subject.execute();

      expect(
          target,
          const RouteAuthenticationTarget(
              RouteAuthenticationPage.biometricAgreement));
    });

    test('createPin', () async {
      _when(
        hasBeenPreviouslyLoggedIn: true,
        userShouldSeeOnboarding: false,
        isUserVerified: true,
        hasPin: false,
        shouldAskUserToEnableBiometrics: false,
      );

      final target = await subject.execute();

      expect(target,
          const RouteAuthenticationTarget(RouteAuthenticationPage.createPin));
    });

    test('home', () async {
      _when(
        hasBeenPreviouslyLoggedIn: true,
        userShouldSeeOnboarding: false,
        isUserVerified: false,
        hasPin: true,
        shouldAskUserToEnableBiometrics: false,
        customer: TestConstants.verifiedCustomer,
      );

      final target =
          await subject.execute(endPage: RouteAuthenticationPage.home);

      verify(_mockLocalSettingsRepository.setUserVerified(isVerified: true))
          .called(1);

      expect(target,
          const RouteAuthenticationTarget(RouteAuthenticationPage.home));
    });

    test('home with cached verify flag', () async {
      _when(
        hasBeenPreviouslyLoggedIn: true,
        userShouldSeeOnboarding: false,
        isUserVerified: true,
        hasPin: true,
        shouldAskUserToEnableBiometrics: false,
      );

      final target =
          await subject.execute(endPage: RouteAuthenticationPage.home);

      verifyNever(
          _mockLocalSettingsRepository.setUserVerified(isVerified: true));

      expect(target,
          const RouteAuthenticationTarget(RouteAuthenticationPage.home));
    });

    test('notLoggedIn', () async {
      _when(
          hasBeenPreviouslyLoggedIn: true,
          userShouldSeeOnboarding: false,
          isUserVerified: false,
          exceptionOnFetchingCustomer: true);

      final target =
          await subject.execute(endPage: RouteAuthenticationPage.home);

      expect(target,
          const RouteAuthenticationTarget(RouteAuthenticationPage.welcome));
    });

    test('shouldShowMandatoryAppUpgradeScreen true', () async {
      _when(
          hasBeenPreviouslyLoggedIn: false,
          userShouldSeeOnboarding: true,
          isUserVerified: false,
          exceptionOnFetchingCustomer: false);

      when(_mockLocalSettingsRepository.getMobileSettings())
          .thenReturn(TestConstants.stubMobileSettings);

      when(_mockLocalSettingsRepository.getCurrentAppVersion()).thenAnswer(
          (_) => Future.value(TestConstants.stubOutdatedAppVersion));

      final target =
          await subject.execute(endPage: RouteAuthenticationPage.home);

      expect(
          target,
          const RouteAuthenticationTarget(
              RouteAuthenticationPage.mandatoryAppUpgrade));
    });

    test('shouldShowMandatoryAppUpgradeScreen false', () async {
      _when(
          hasBeenPreviouslyLoggedIn: false,
          userShouldSeeOnboarding: true,
          isUserVerified: false,
          exceptionOnFetchingCustomer: false);

      when(_mockLocalSettingsRepository.getMobileSettings())
          .thenReturn(TestConstants.stubMobileSettings);

      when(_mockLocalSettingsRepository.getCurrentAppVersion())
          .thenAnswer((_) => Future.value(TestConstants.stubLatestAppVersion));

      final target =
          await subject.execute(endPage: RouteAuthenticationPage.home);

      expect(target,
          const RouteAuthenticationTarget(RouteAuthenticationPage.onboarding));
    });
  });
}

void _when({
  bool hasBeenPreviouslyLoggedIn,
  bool userShouldSeeOnboarding,
  bool isUserVerified,
  bool hasPin,
  bool shouldAskUserToEnableBiometrics,
  CustomerResponseModel customer,
  bool exceptionOnFetchingCustomer = false,
}) {
  when(_mockUserRepository.hasBeenPreviouslyLoggedIn())
      .thenAnswer((_) => Future.value(hasBeenPreviouslyLoggedIn));

  when(_mockLocalSettingsRepository.getUserShouldSeeOnboarding())
      .thenReturn(userShouldSeeOnboarding);

  when(_mockLocalSettingsRepository.didForgetPin()).thenReturn(false);

  when(_mockLocalSettingsRepository.isUserVerified())
      .thenReturn(isUserVerified);

  when(_mockHasPinUseCase.execute()).thenAnswer((_) => Future.value(hasPin));

  when(_mockBiometricBloc.shouldAskUserToEnableBiometrics())
      .thenAnswer((_) => Future.value(shouldAskUserToEnableBiometrics));

  if (exceptionOnFetchingCustomer) {
    when(_mockCustomerRepository.getCustomer()).thenThrow(Exception());
  } else {
    when(_mockCustomerRepository.getCustomer())
        .thenAnswer((_) => Future.value(customer));
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lykke_mobile_mavn/base/dependency_injection/app_module.dart';
import 'package:lykke_mobile_mavn/base/repository/customer/customer_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/local/local_settings_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/token/token_repository.dart';
import 'package:lykke_mobile_mavn/base/repository/user/user_repository.dart';
import 'package:lykke_mobile_mavn/feature_biometrics/bloc/biometric_bloc.dart';
import 'package:lykke_mobile_mavn/library_dependency_injection/core.dart';
import 'package:pedantic/pedantic.dart';
import 'package:version/version.dart';

import 'has_pin_use_case.dart';

class RouteAuthenticationUseCase {
  RouteAuthenticationUseCase(
    this._localSettingsRepository,
    this._userRepository,
    this._hasPinUseCase,
    this._customerRepository,
    this._biometricBloc,
    this._tokenRepository,
  );

  final LocalSettingsRepository _localSettingsRepository;
  final UserRepository _userRepository;
  final HasPinUseCase _hasPinUseCase;
  final CustomerRepository _customerRepository;
  final BiometricBloc _biometricBloc;
  final TokenRepository _tokenRepository;

  Future<RouteAuthenticationTarget> execute({
    RouteAuthenticationPage endPage,
  }) async {
    if (await shouldShowMandatoryAppUpgradeScreen()) {
      return const RouteAuthenticationTarget(
          RouteAuthenticationPage.mandatoryAppUpgrade);
    }

    if (!await _userRepository.hasBeenPreviouslyLoggedIn()) {
      if (_localSettingsRepository.getUserShouldSeeOnboarding()) {
        return const RouteAuthenticationTarget(
            RouteAuthenticationPage.onboarding);
      }

      return const RouteAuthenticationTarget(RouteAuthenticationPage.welcome);
    }

    final verificationState = await _getVerificationState();

    if (verificationState.status == _RouteAuthenticationStatus.notLoggedIn) {
      return const RouteAuthenticationTarget(RouteAuthenticationPage.welcome);
    }

    if (verificationState.status != _RouteAuthenticationStatus.verified) {
      if (verificationState.status ==
          _RouteAuthenticationStatus.emailNeedsVerification) {
        return RouteAuthenticationTarget(
          RouteAuthenticationPage.verifyEmail,
          data: verificationState.data,
        );
      }
    }

    final hasPin = await _hasPinUseCase.execute();

    if (await _biometricBloc.shouldAskUserToEnableBiometrics()) {
      return const RouteAuthenticationTarget(
          RouteAuthenticationPage.biometricAgreement);
    }

    if (!hasPin || _localSettingsRepository.didForgetPin()) {
      unawaited(_localSettingsRepository.clearDidForgetPin());
      return const RouteAuthenticationTarget(RouteAuthenticationPage.createPin);
    }

    return RouteAuthenticationTarget(endPage);
  }

  Future<_VerificationFlowState> _getVerificationState() async {
    if (await _tokenRepository.getLoginToken() == null) {
      return _VerificationFlowState(_RouteAuthenticationStatus.notLoggedIn);
    }

    if (_localSettingsRepository.isUserVerified()) {
      return _VerificationFlowState(_RouteAuthenticationStatus.verified);
    }

    try {
      final customer = await _customerRepository.getCustomer();

      if (customer.isPhoneNumberVerified && customer.isEmailVerified) {
        unawaited(_localSettingsRepository.setUserVerified(isVerified: true));
        return _VerificationFlowState(_RouteAuthenticationStatus.verified);
      }

      if (!customer.isEmailVerified) {
        return _VerificationFlowState(
          _RouteAuthenticationStatus.emailNeedsVerification,
          data: customer.email,
        );
      }
    } catch (_) {
      return _VerificationFlowState(_RouteAuthenticationStatus.notLoggedIn);
    }
  }

  Future<bool> shouldShowMandatoryAppUpgradeScreen() async {
    try {
      final latestMandatoryUpgradeAppVersion = Version.parse(
          _localSettingsRepository
              .getMobileSettings()
              .appVersion
              .latestMandatoryUpgradeAppVersion);

      final currentAppVersion =
          Version.parse(await _localSettingsRepository.getCurrentAppVersion());

      return currentAppVersion < latestMandatoryUpgradeAppVersion;
    } catch (_) {
      return false;
    }
  }
}

enum _RouteAuthenticationStatus {
  notLoggedIn,
  verified,
  emailNeedsVerification,
}

class _VerificationFlowState {
  _VerificationFlowState(
    this.status, {
    this.data,
  });

  final Object data;
  final _RouteAuthenticationStatus status;
}

enum RouteAuthenticationPage {
  mandatoryAppUpgrade,
  onboarding,
  welcome,
  biometricAgreement,
  createPin,
  signInWithPin,
  verifyEmail,
  home,
}

class RouteAuthenticationTarget extends Equatable {
  const RouteAuthenticationTarget(
    this.page, {
    this.data = '',
  });

  final Object data;
  final RouteAuthenticationPage page;

  @override
  List get props => [page, data];
}

RouteAuthenticationUseCase useRouteAuthenticationUseCase() =>
    ModuleProvider.of<AppModule>(useContext()).routeAuthenticationUseCase;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lykke_mobile_mavn/app/resources/localized_strings.dart';
import 'package:lykke_mobile_mavn/app/resources/text_styles.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/logout_use_case.dart';
import 'package:lykke_mobile_mavn/base/router/router.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/analytics/email_verification_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_verification_bloc.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_verification_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/timer_bloc.dart';
import 'package:lykke_mobile_mavn/lib_dynamic_links/dynamic_link_manager.dart';
import 'package:lykke_mobile_mavn/lib_dynamic_links/dynamic_link_manager_mixin.dart';
import 'package:lykke_mobile_mavn/library_bloc/core.dart';
import 'package:lykke_mobile_mavn/library_custom_hooks/app_lifecycle_hook.dart';
import 'package:lykke_mobile_mavn/library_ui_components/buttons/primary_button.dart';
import 'package:lykke_mobile_mavn/library_ui_components/error/inline_error_widget.dart';
import 'package:lykke_mobile_mavn/library_ui_components/error/network_error.dart';
import 'package:lykke_mobile_mavn/library_ui_components/layout/scaffold_with_logo.dart';
import 'package:lykke_mobile_mavn/library_ui_components/misc/heading.dart';

class EmailVerificationPage extends HookWidget with DynamicLinkManagerMixin {
  EmailVerificationPage({
    @required this.email,
    @required this.status,
    Key key,
  }) : super(key: key);

  final String email;
  final VerificationStatus status;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    startListenOnceForDynamicLinks();

    final verificationBloc = useEmailVerificationBloc();
    final verificationBlocState =
        useBlocState<EmailVerificationState>(verificationBloc);
    final confirmationBloc = useEmailConfirmationBloc();
    final timerBloc = useTimerBloc();
    final customerBloc = useCustomerBloc();
    final logoutUseCase = useLogOutUseCase();

    final dynamicLinkManager = useDynamicLinkManager();
    final router = useRouter();
    final emailVerificationAnalyticsManager =
        useEmailVerificationAnalyticsManager();

    final isErrorDismissed = useState(false);

    void onResendLinkButtonTapped() {
      emailVerificationAnalyticsManager.resendLinkTap();
      isErrorDismissed.value = false;
      verificationBloc.sendVerificationEmail();
    }

    void proceedSilently() {
      emailVerificationAnalyticsManager.emailVerificationSuccessful();
      router.pushRootBottomBarPage();
    }

    void showSuccessPage() {
      emailVerificationAnalyticsManager.emailVerificationSuccessful();
      router.replaceWithEmailVerificationSuccessPage();
    }

    useBlocEventListener(timerBloc, (event) {
      customerBloc.getCustomer();
    });

    useBlocEventListener(customerBloc, (event) {
      if (event is CustomerLoadedEvent &&
          event.customer.isEmailVerified &&
          event.customer.isPhoneNumberVerified) {
        router.pushRootBottomBarPage();
      } else if (event is CustomerLoadedEvent &&
          event.customer.isEmailVerified) {
        showSuccessPage();
      }
    });

    useBlocEventListener(verificationBloc, (event) {
      if (event is EmailVerificationAlreadyVerifiedEvent) {
        proceedSilently();
      }
    });

    useBlocEventListener(confirmationBloc, (event) {
      if (event is EmailConfirmationStoredKey) {
        dynamicLinkManager.routeEmailConfirmationRequests(fromEvent: event);
      }
    });

    useEffect(() {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        dynamicLinkManager.routeEmailConfirmationRequests();
      });
    }, [_scaffoldKey]);

    useEffect(() {
      timerBloc.startTimer();
    }, [timerBloc]);

    useEffect(() {
      //send an email if the user was redirected here NOT from registration
      if (status != VerificationStatus.notVerified) {
        verificationBloc.sendVerificationEmail();
      }
    }, [verificationBloc]);

    useAppLifecycle((appLifecycleState) {
      if (appLifecycleState == AppLifecycleState.paused) {
        timerBloc.cancelTimer();
      }

      if (appLifecycleState == AppLifecycleState.resumed) {
        timerBloc.startTimer();
      }
    });

    void onRegisterWithAnotherAccountButtonTapped() {
      emailVerificationAnalyticsManager.registerWithAnotherAccountTap();
      logoutUseCase.execute();
      router.navigateToRegisterPage();
    }

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: ScaffoldWithLogo(
        key: _scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Heading(LocalizedStrings.emailVerificationTitle),
                  const SizedBox(height: 32),
                  ..._getDetails(
                      didResendEmail: verificationBlocState
                          is EmailVerificationSuccessState),
                  const SizedBox(height: 16),
                  Text(
                    LocalizedStrings.emailVerificationMessage2,
                    style: TextStyles.darkBodyBody2RegularHigh,
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      LocalizedStrings.emailVerificationResetText,
                      style: TextStyles.darkBodyBody3RegularHigh,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (verificationBlocState is EmailVerificationErrorState)
                    _buildError(error: verificationBlocState.error),
                  PrimaryButton(
                    isLoading:
                        verificationBlocState is EmailVerificationLoadingState,
                    text: LocalizedStrings.emailVerificationButton,
                    onTap: onResendLinkButtonTapped,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: FlatButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: onRegisterWithAnotherAccountButtonTapped,
                      child: Text(
                        LocalizedStrings.registerWithAnotherAccountButton,
                        style: TextStyles.linksTextLinkBoldHigh,
                      ),
                    ),
                  ),
                ],
              ),
              if (verificationBlocState is EmailVerificationNetworkErrorState)
                _buildNetworkError(onRetryTap: onResendLinkButtonTapped)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getDetails({@required bool didResendEmail}) => [
        if (status == VerificationStatus.invalidCode)
          Text(LocalizedStrings.emailVerificationLinkExpired(email)),
        if (status == VerificationStatus.notVerified ||
            status == VerificationStatus.noCode)
          Text(
            didResendEmail
                ? LocalizedStrings.emailVerificationMessage1Resent
                : LocalizedStrings.emailVerificationMessage1,
            style: TextStyles.darkBodyBody1Bold,
          ),
        Text(email, style: TextStyles.darkBodyBody1Bold),
      ];

  Widget _buildError({String error}) => InlineErrorWidget(errorMessage: error);

  Widget _buildNetworkError({VoidCallback onRetryTap}) => Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(child: NetworkErrorWidget(onRetry: onRetryTap)),
        ],
      ));
}

enum VerificationStatus { notVerified, invalidCode, noCode }

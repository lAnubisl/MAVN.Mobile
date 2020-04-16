import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lykke_mobile_mavn/app/resources/localized_strings.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/common_use_cases/logout_use_case.dart';
import 'package:lykke_mobile_mavn/base/router/router.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/analytics/email_verification_analytics_manager.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/view/email_verification_page.dart';
import 'package:lykke_mobile_mavn/library_bloc/core.dart';
import 'package:lykke_mobile_mavn/library_custom_hooks/on_dispose_hook.dart';
import 'package:lykke_mobile_mavn/library_ui_components/error/generic_error_widget.dart';
import 'package:lykke_mobile_mavn/library_ui_components/error/network_error.dart';
import 'package:lykke_mobile_mavn/library_ui_components/layout/scaffold_with_logo.dart';
import 'package:lykke_mobile_mavn/library_ui_components/misc/heading.dart';
import 'package:lykke_mobile_mavn/library_ui_components/misc/spinner.dart';

class EmailConfirmationPage extends HookWidget {
  const EmailConfirmationPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confirmationBloc = useEmailConfirmationBloc();
    final confirmationBlocState =
        useBlocState<EmailConfirmationState>(confirmationBloc);
    final customerBloc = useCustomerBloc();
    final customerBlocState = useBlocState<CustomerState>(customerBloc);
    final router = useRouter();
    final logoutUseCase = useLogOutUseCase();
    final emailVerificationAnalyticsManager =
        useEmailVerificationAnalyticsManager();

    final isErrorDismissed = useState(false);

    void confirmEmail() {
      customerBloc.getCustomer().then((_) {
        confirmationBloc.confirmEmail();
      });
      isErrorDismissed.value = false;
    }

    useBlocEventListener(confirmationBloc, (event) {
      if (event is EmailConfirmationSuccessEvent) {
        emailVerificationAnalyticsManager.emailVerificationSuccessful();
        router.replaceWithEmailVerificationSuccessPage();
      } else if (event is EmailConfirmationAlreadyVerifiedEvent) {
        router.pushRootBottomBarPage();
      } else if (event is EmailConfirmationInvalidCodeEvent) {
        if (customerBlocState is CustomerLoadedState) {
          confirmationBloc.removeVerificationCode().then((_) {
            router.pushRootEmailVerificationPage(
              email: customerBlocState.customer.email,
              status: VerificationStatus.invalidCode,
            );
          });
        } else {
          logoutUseCase.execute();
          router.navigateToLoginPage();
        }
      }
    });

    useEffect(() {
      confirmEmail();
    }, [customerBloc, confirmationBloc]);

    useOnDispose(router.markAsClosedEmailConfirmationPage);

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: ScaffoldWithLogo(
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Heading(LocalizedStrings.emailVerificationTitle),
                ],
              ),
              if (confirmationBlocState is EmailConfirmationLoadingState ||
                  customerBloc is CustomerLoadingState)
                const Center(child: Spinner()),
              if (confirmationBlocState is EmailConfirmationBaseErrorState)
                _buildError(
                  errorState: confirmationBlocState,
                  onRetryTap: confirmEmail,
                  onCloseTap: () => isErrorDismissed.value = true,
                  isErrorDismissed: isErrorDismissed.value,
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError({
    EmailConfirmationBaseErrorState errorState,
    VoidCallback onRetryTap,
    VoidCallback onCloseTap,
    bool isErrorDismissed,
  }) {
    if (errorState is EmailConfirmationErrorState && !isErrorDismissed) {
      return _buildGenericError(
        error: errorState.error,
        onRetryTap: errorState.canRetry ? onRetryTap : null,
        onCloseTap: onCloseTap,
      );
    } else if (errorState is EmailConfirmationNetworkErrorState) {
      return _buildNetworkError(onRetryTap: onRetryTap);
    }

    return Container();
  }

  Widget _buildGenericError({
    String error,
    VoidCallback onRetryTap,
    VoidCallback onCloseTap,
  }) =>
      Align(
        alignment: Alignment.bottomCenter,
        child: GenericErrorWidget(
          text: error,
          onRetryTap: onRetryTap,
          onCloseTap: onCloseTap,
          valueKey: const Key('emailConfirmationError'),
        ),
      );

  Widget _buildNetworkError({VoidCallback onRetryTap}) => Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(child: NetworkErrorWidget(onRetry: onRetryTap)),
        ],
      ));
}

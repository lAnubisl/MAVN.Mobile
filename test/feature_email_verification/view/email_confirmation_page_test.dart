import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/router/router.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/view/email_confirmation_page.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/view/email_verification_page.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/widget_frames.dart';
import '../../mock_classes.dart';
import '../../test_constants.dart';

Router _mockRouter;
MockCustomerBloc _mockCustomerBloc;
MockEmailConfirmationBloc _mockEmailConfirmationBloc;
WidgetTester _widgetTester;
Widget _subjectWidget;

void main() {
  group('EmailConfirmationPage tests', () {
    testWidgets('success', (widgetTester) async {
      await _givenSubjectWidgetWithInitialBlocState(widgetTester,
          customerState: CustomerUninitializedState());

      await _mockEmailConfirmationBloc.testNewEvent(
        event: EmailConfirmationSuccessEvent(),
        widgetTester: widgetTester,
      );

      verify(_mockRouter.replaceWithEmailVerificationSuccessPage()).called(1);
    });

    testWidgets('EmailConfirmationInvalidCodeEvent', (widgetTester) async {
      await _givenSubjectWidgetWithInitialBlocState(widgetTester,
          customerState:
              CustomerLoadedState(TestConstants.nonVerifiedCustomer));

      await _mockEmailConfirmationBloc.testNewEvent(
        event: EmailConfirmationInvalidCodeEvent(),
        widgetTester: widgetTester,
      );

      verify(_mockRouter.pushRootEmailVerificationPage(
              email: TestConstants.nonVerifiedCustomer.email,
              status: VerificationStatus.invalidCode))
          .called(1);
    });
  });
}

/// GIVEN

Future<void> _givenSubjectWidgetWithInitialBlocState(
  WidgetTester widgetTester, {
  CustomerState customerState,
}) async {
  _widgetTester = widgetTester;
  _subjectWidget =
      _getSubjectWidget(customerState ?? CustomerUninitializedState());
  await _widgetTester.pumpWidget(_subjectWidget);
}

/// HELPERS

Widget _getSubjectWidget(CustomerState customerState) {
  _mockRouter = MockRouter();
  _mockCustomerBloc = MockCustomerBloc(customerState);

  when(_mockCustomerBloc.getCustomer()).thenAnswer((_) => Future.value());

  _mockEmailConfirmationBloc =
      MockEmailConfirmationBloc(EmailConfirmationUninitializedState());

  when(_mockEmailConfirmationBloc.removeVerificationCode())
      .thenAnswer((_) => Future.value());

  return TestAppFrame(
    mockEmailConfirmationBloc: _mockEmailConfirmationBloc,
    mockCustomerBloc: _mockCustomerBloc,
    mockRouter: _mockRouter,
    child: const EmailConfirmationPage(),
  );
}

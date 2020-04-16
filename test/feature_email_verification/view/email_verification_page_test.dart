import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lykke_mobile_mavn/base/common_blocs/customer_bloc_output.dart';
import 'package:lykke_mobile_mavn/base/router/router.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_confirmation_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/email_verification_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/bloc/timer_bloc_output.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/di/email_verification_module.dart';
import 'package:lykke_mobile_mavn/feature_email_verification/view/email_verification_page.dart';
import 'package:lykke_mobile_mavn/library_dependency_injection/core.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/widget_frames.dart';
import '../../mock_classes.dart';
import '../../test_constants.dart';

Router _mockRouter;
MockCustomerBloc _mockCustomerBloc;
MockTimerBloc _mockTimerBloc;
MockEmailVerificationBloc _mockEmailVerificationBloc;
MockEmailConfirmationBloc _mockEmailConfirmationBloc;
WidgetTester _widgetTester;
Widget _subjectWidget;
final MockDynamicLinkManager _mockDynamicLinkManager = MockDynamicLinkManager();

void main() {
  group('EmailVerificationPage tests', () {
    testWidgets('timer tick triggers customer request', (widgetTester) async {
      await _givenSubjectWidgetWithInitialBlocState(widgetTester,
          state: CustomerUninitializedState());

      await _mockTimerBloc.testNewEvent(
          event: TimerFinishedEvent(), widgetTester: widgetTester);

      verify(_mockCustomerBloc.getCustomer()).called(1);
    });

    testWidgets('verified customer', (widgetTester) async {
      await _givenSubjectWidgetWithInitialBlocState(widgetTester,
          state: CustomerUninitializedState());

      await _mockCustomerBloc.testNewEvent(
        event: CustomerLoadedEvent(TestConstants.emailVerifiedCustomer),
        widgetTester: widgetTester,
      );

      verify(_mockRouter.replaceWithEmailVerificationSuccessPage()).called(1);
    });

    testWidgets('stored code triggers dynamic link routing',
        (widgetTester) async {
      await _givenSubjectWidgetWithInitialBlocState(widgetTester,
          state: CustomerUninitializedState());

      final event = EmailConfirmationStoredKey();
      await _mockEmailConfirmationBloc.testNewEvent(
        event: event,
        widgetTester: widgetTester,
      );

      verify(_mockDynamicLinkManager.routeEmailConfirmationRequests(
              fromEvent: event))
          .called(1);
    });
  });
}

/// GIVEN

Future<void> _givenSubjectWidgetWithInitialBlocState(
  WidgetTester widgetTester, {
  CustomerState state,
}) async {
  _widgetTester = widgetTester;
  _subjectWidget = _getSubjectWidget(state ?? CustomerUninitializedState());
  await _widgetTester.pumpWidget(_subjectWidget);
}

/// HELPERS

Widget _getSubjectWidget(CustomerState state) {
  _mockRouter = MockRouter();
  _mockCustomerBloc = MockCustomerBloc(state);
  _mockTimerBloc = MockTimerBloc(TimerUninitializedState());
  _mockEmailVerificationBloc =
      MockEmailVerificationBloc(EmailVerificationUninitializedState());
  _mockEmailConfirmationBloc =
      MockEmailConfirmationBloc(EmailConfirmationUninitializedState());
  final mockEmailVerificationModule = MockEmailVerificationModule();

  when(mockEmailVerificationModule.emailVerificationBloc)
      .thenReturn(_mockEmailVerificationBloc);
  when(mockEmailVerificationModule.timerBloc).thenReturn(_mockTimerBloc);

  return TestAppFrame(
    mockEmailConfirmationBloc: _mockEmailConfirmationBloc,
    mockCustomerBloc: _mockCustomerBloc,
    mockRouter: _mockRouter,
    mockDynamicLinkManager: _mockDynamicLinkManager,
    child: ModuleProvider<EmailVerificationModule>(
        module: mockEmailVerificationModule,
        child: EmailVerificationPage(
          email: TestConstants.stubEmail,
          status: VerificationStatus.notVerified,
        )),
  );
}

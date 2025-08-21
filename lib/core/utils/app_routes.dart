import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shifaa/core/layout/main_layout_screen.dart';
import 'package:shifaa/features/appointments/presentation/views/appointment_view.dart';
import 'package:shifaa/features/auth/presentation/views/login_view.dart';
import 'package:shifaa/features/auth/presentation/views/password_view.dart';
import 'package:shifaa/features/auth/presentation/views/signup_view.dart';
import 'package:shifaa/features/auth/presentation/views/verify_otp_view.dart';
import 'package:shifaa/features/home/presentation/views/home_view.dart';
import 'package:shifaa/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:shifaa/features/notifications/presentation/view/screens/notifications_screen.dart';
import 'package:shifaa/features/onboarding/presentation/views/on_boarding_view.dart';
import 'package:shifaa/features/search/presentation/views/search_screen.dart';
import 'package:shifaa/features/splash/presentation/views/splash_view.dart';


abstract class AppRouter {
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/onboarding',
        name: OnBoardingView.routeName,
        builder: (context, state) => const OnBoardingView(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          int index = 0;
          if (state.location.startsWith('/search')) {
            index = 1;
          } else if (state.location.startsWith('/appointments')) {
            index = 2;
          } else if (state.location.startsWith('/profile')) {
            index = 3;
          }
          return MainLayoutScreen(child: child, selectedIndex: index);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: HomeView.routeName,
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Profile'))),
          ),
        ],
      ),
      GoRoute(
        path: SignupView.routeName,
        name: SignupView.routeName,
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: LoginView.routeName,
        name: LoginView.routeName,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: PasswordView.routeName,
        name: PasswordView.routeName,
        builder: (context, state) => const PasswordView(),
      ),
      GoRoute(
        path: '/verify-otp-view',
        name: VerifyOtpView.routeName,
        builder: (context, state) {
          final phone = state.queryParams['phone'] ?? '';
          return VerifyOtpView(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: NotificationsScreen.routeName,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}

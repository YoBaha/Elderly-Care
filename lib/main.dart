import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/bottom_tab_bar.dart';
import 'services/notification_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/doctor_viewmodel.dart';
import 'services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  try {
    Stripe.publishableKey =
        'pk_test_51RHrcTGd1mOBLMSWZADSUzayt44Zg3JFdp345WK8BFIjTuki6OUj3iU5zCeKT0K8zmfWgMoGX4rBTE24EoCt2in200XMkaiB71';
    await Stripe.instance.applySettings();
  } catch (e) {
    print('Stripe initialization failed: $e');
    // Continue running the app even if Stripe fails to initialize
    // You might want to handle this differently in production
  }

  // Initialize token
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token') ?? '';
  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String initialToken;
  final NotificationService notificationService = NotificationService();

  MyApp({required this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            ApiService(initialToken, notificationService),
          ),
        ),
        ChangeNotifierProxyProvider<LoginViewModel, DoctorViewModel>(
          create: (context) => DoctorViewModel(
            apiService: ApiService(initialToken, notificationService),
            token: initialToken,
          ),
          update: (context, loginViewModel, doctorViewModel) {
            doctorViewModel?.updateToken(loginViewModel.token);
            return doctorViewModel ??
                DoctorViewModel(
                  apiService:
                      ApiService(loginViewModel.token, notificationService),
                  token: loginViewModel.token,
                );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Elderly Care App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/home': (context) => BottomTabBar(
                token: initialToken,
                notificationService: notificationService,
              ),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/doctors': (context) => DoctorsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

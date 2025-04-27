import 'package:flutter/material.dart';
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
// Import HomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token') ?? '';
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/views/authen/choose_way_page.dart';
import 'package:wality_application/wality_app/views/authen/forget_password_page.dart';
import 'package:wality_application/wality_app/views/authen/sign_up_page.dart';
import 'package:wality_application/wality_app/views/choose_change_page.dart';
import 'package:wality_application/wality_app/views/home_page.dart';
import 'package:wality_application/wality_app/views/authen/logo_page.dart';
import 'package:wality_application/wality_app/views/profile_page.dart';
import 'package:wality_application/wality_app/views/change_info_page.dart';
import 'package:wality_application/wality_app/views/authen/sign_in_page.dart';
import 'package:wality_application/wality_app/views/ranking_page.dart';
import 'package:wality_application/wality_app/views/reward_page.dart';
import 'package:wality_application/wality_app/views/setting_page.dart';
import 'package:wality_application/wality_app/views/summary_graph.dart';
import 'package:wality_application/wality_app/views_models/authentication_vm.dart';
import 'package:wality_application/wality_app/views_models/change_info_vm.dart';
import 'package:wality_application/wality_app/views_models/profile_vm.dart';
import 'package:wality_application/wality_app/views_models/water_checking_vm.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChangeInfoViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
        ChangeNotifierProvider(create: (context) => AuthenticationViewModel()),
        ChangeNotifierProvider(create: (context) => WaterSaveViewModel()),
        ChangeNotifierProvider(
            create: (_) => WaterCheckingViewModel(File(Image as String))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wality',
      theme: ThemeData(),
      home: /*const LogoPage(),*/ const HomePage(),
      routes: {
        '/logopage': (context) => const LogoPage(),
        '/choosewaypage': (context) => const ChooseWayPage(),
        '/signinpage': (context) => const SignInPage(),
        '/signuppage': (context) => const SignUpPage(),
        '/forgetpasswordpage': (context) => const ForgetpasswordPage(),
        '/homepage': (context) => const HomePage(),
        '/profilepage': (context) => const ProfilePage(),
        '/changeinfopage': (context) => const ChangeInfoPage(),
        '/settingpage': (context) => const SettingPage(),
        '/summarygraphpage': (context) => const SummaryGraphPage(),
        '/choosechange': (context) => const ChooseChangePage(),
        '/rewardpage': (context) => const RewardPage(),
        '/rankingpage': (context) => const RankingPage(),
      },
    );
  }
}

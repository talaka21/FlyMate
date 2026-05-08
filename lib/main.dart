import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fly_mate/core/networking/dio_client.dart';
import 'package:fly_mate/core/routing/app_router.dart';
import 'package:fly_mate/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fly_mate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fly_mate/features/auth/data/repositories/auth_repository.dart';
import 'package:fly_mate/features/auth/logic/auth_cubit.dart';
import 'package:fly_mate/features/auth/presentation/pages/auth_screen.dart';
import 'package:fly_mate/features/home/presentation/screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            repository: AuthRepositoryImpl(
              remote: AuthRemoteDataSourceImpl(),
              local: AuthLocalDataSourceImpl(),
            ),
          )..checkSession(), // ✅ يتحقق من الجلسة فور ما يفتح التطبيق
        ),

        // لاحقاً تضيف هون:
        // BlocProvider<FlightsCubit>(create: (_) => FlightsCubit(...)),
        // BlocProvider<TrackingCubit>(create: (_) => TrackingCubit(...)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          // return MaterialApp(
          //   debugShowCheckedModeBanner: false,
          //   home: SignInScreen(),
          // );
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}

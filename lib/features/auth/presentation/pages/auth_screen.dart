import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fly_mate/core/routing/app_routes.dart';
import 'package:fly_mate/features/auth/logic/auth_cubit.dart';
import 'package:fly_mate/features/auth/logic/auth_state.dart';
import 'package:fly_mate/features/auth/presentation/widgets/glass_field.dart';
import 'package:fly_mate/features/auth/presentation/widgets/trail_painter.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late AnimationController _planeController;
  late Animation<double> _planeX;
  late Animation<double> _planeY;

  final List<TrailParticle> _trail = [];
  late AnimationController _trailController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _planeController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _planeX = Tween<double>(
      begin: -0.2,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _planeController, curve: Curves.linear));

    _planeY = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _planeController, curve: Curves.linear));

    _trailController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _planeController.forward();
    });

    _trailController.addListener(_updateTrail);
  }

  void _updateTrail() {
    if (!mounted) return;
    if (_planeController.isCompleted) return;

    final size = MediaQuery.of(context).size;
    final waveCenter = size.height * 0.10;
    final px = _planeX.value * size.width;
    final py = waveCenter + math.sin(_planeY.value) * 18.0;

    _trail.add(TrailParticle(x: px, y: py, opacity: 0.7, radius: 10));

    for (final p in _trail) {
      p.opacity -= 0.05;
      p.radius += 0.4;
    }

    _trail.removeWhere((p) => p.opacity <= 0);

    if (_trail.length > 80) {
      _trail.removeRange(0, _trail.length - 80);
    }
  }

  @override
  void dispose() {
    _planeController.dispose();
    _trailController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sh = size.height;
    final sw = size.width;
    final waveCenter = sh * 0.10;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<AuthCubit>().resetState();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ── الخلفية ─────────────────────────────────────────────
            SizedBox.expand(
              child: Image.asset(
                "assets/images/background_image.png",
                fit: BoxFit.cover,
              ),
            ),

            // ── الدخان ──────────────────────────────────────────────
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _trailController,
                builder: (context, _) {
                  return IgnorePointer(
                    ignoring: true,
                    child: CustomPaint(
                      painter: TrailPainter(_trail),
                      size: Size(sw, sh),
                    ),
                  );
                },
              ),
            ),

            // ── الطيارة ─────────────────────────────────────────────
            AnimatedBuilder(
              animation: _planeController,
              builder: (context, _) {
                if (_planeController.isCompleted)
                  return const SizedBox.shrink();

                final px = _planeX.value * sw;
                final py = waveCenter + math.sin(_planeY.value) * 18.0;
                final waveTilt = math.cos(_planeY.value) * 0.15;

                return Positioned(
                  left: px - 5,
                  top: py - 48,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: (math.pi / 180) + waveTilt,
                      child: SvgPicture.asset(
                        'assets/icons/airplane7.svg',
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── الفورم ──────────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                reverse: true,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: sh * 0.40),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                      ).copyWith(bottom: 40.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 32.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Sign in to continue your journey',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 28.h),
                            GlassField(
                              controller: _emailController,
                              hint: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            SizedBox(height: 16.h),
                            GlassField(
                              controller: _passwordController,
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              obscure: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed('forgotPassword');
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 28.h),

                            // ── زر Sign In ───────────────────────
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 54.h,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.read<AuthCubit>().signIn(
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF0072FF),
                                      disabledBackgroundColor: Colors.white
                                          .withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Color(0xFF0072FF),
                                            ),
                                          )
                                        : Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 14.h),

                            // ── فاصل OR ──────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.25),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.25),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 14.h),

                            // ── زر Employee Register ──────────────
                            SizedBox(
                              width: double.infinity,
                              height: 54.h,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: navigate to employee registration screen
                                },
                                icon: const Icon(
                                  Icons.badge_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Employee Register',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.08,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push(AppRoutes.signUp),
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

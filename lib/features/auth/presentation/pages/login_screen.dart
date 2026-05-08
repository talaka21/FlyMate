import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fly_mate/core/constants/strings.dart';
import 'package:fly_mate/core/constants/text_styles.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _vibrationController;
  late Animation<double> _vibrationAnimation;

  late AnimationController _flyController;
  late Animation<double> _liftAnimation;
  late Animation<double> _fadeAnimation;

  late AudioPlayer _audioPlayer;

  double _dragProgress = 0.0;
  bool _submitted = false;
  bool _isFlying = false;

  static const double _buttonSize = 60.0;
  static const double _sliderHeight = 70.0;
  static const double _airplaneSize = 200.0;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    _vibrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _vibrationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _vibrationController, curve: Curves.easeInOut),
    );

    _flyController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _liftAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeInQuint),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _flyController,
        curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _vibrationController.dispose();
    _flyController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    await _audioPlayer.play(AssetSource('audio/4.wav'));

    setState(() {
      _submitted = true;
      _isFlying = true;
    });
    _vibrationController.stop();

    _flyController.forward();

    _flyController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        context.pushNamed('signin');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final startX = screenWidth / 2 - _airplaneSize / 2;
    final startY = screenHeight - 70.h - _sliderHeight / 2 - _airplaneSize / 2;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/background_image.png",
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: const Alignment(0.0, 0.3),
            child: Text(
              AppStrings.programName,
              style: AppTextStyles.programName,
            ),
          ),

          if (!_isFlying)
            Positioned(
              bottom: 70.h,
              left: 20.w,
              right: 20.w,
              child: _CustomSlider(
                progress: _dragProgress,
                submitted: _submitted,
                sliderHeight: _sliderHeight,
                buttonSize: _buttonSize,
                vibrationAnimation: _vibrationAnimation,
                onProgressChanged: (value) {
                  setState(() => _dragProgress = value);
                },
                onSubmit: _onSubmit,
              ),
            ),

          if (_isFlying)
            AnimatedBuilder(
              animation: _flyController,
              builder: (context, child) {
                final liftProgress = _liftAnimation.value;
                final liftY = liftProgress * (startY + _airplaneSize + 100);

                return Positioned(
                  left: startX,
                  top: startY - liftY,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: AirplaneIcon(
                      size: _airplaneSize,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CustomSlider extends StatefulWidget {
  final double progress;
  final bool submitted;
  final double sliderHeight;
  final double buttonSize;
  final Animation<double> vibrationAnimation;
  final ValueChanged<double> onProgressChanged;
  final VoidCallback onSubmit;

  const _CustomSlider({
    required this.progress,
    required this.submitted,
    required this.sliderHeight,
    required this.buttonSize,
    required this.vibrationAnimation,
    required this.onProgressChanged,
    required this.onSubmit,
  });

  @override
  State<_CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<_CustomSlider> {
  double _startDragX = 0.0;
  double _startProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxDrag = maxWidth - widget.buttonSize - 16;
        final buttonOffset = widget.progress * maxDrag;

        return Container(
          height: widget.sliderHeight,
          decoration: BoxDecoration(
            color: const Color(0xff00122B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(widget.sliderHeight / 2),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: Duration.zero,
                width: buttonOffset + widget.buttonSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.sliderHeight / 2),
                  gradient: LinearGradient(
                    colors: [
                      const Color(
                        0xFF00C6FF,
                      ).withOpacity(widget.progress * 0.9),
                      const Color(
                        0xFF0072FF,
                      ).withOpacity(widget.progress * 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF00C6FF,
                      ).withOpacity(widget.progress * 0.6),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              if (!widget.submitted)
                Center(
                  child: Opacity(
                    opacity: (1 - widget.progress * 1.5).clamp(0.0, 1.0),
                    child: Text(
                      AppStrings.slide,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

              Positioned(
                left: 8 + buttonOffset,
                top: (widget.sliderHeight - widget.buttonSize) / 2,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    _startDragX = details.globalPosition.dx;
                    _startProgress = widget.progress;
                  },
                  onHorizontalDragUpdate: (details) {
                    if (widget.submitted) return;
                    final dragDiff = details.globalPosition.dx - _startDragX;
                    final newOffset = (_startProgress * maxDrag + dragDiff)
                        .clamp(0.0, maxDrag);
                    widget.onProgressChanged(newOffset / maxDrag);
                  },
                  onHorizontalDragEnd: (_) {
                    if (widget.submitted) return;
                    if (widget.progress >= 0.85) {
                      widget.onProgressChanged(1.0);
                      widget.onSubmit();
                    } else {
                      widget.onProgressChanged(0.0);
                    }
                  },
                  child: AnimatedBuilder(
                    animation: widget.vibrationAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          math.sin(widget.vibrationAnimation.value) * 6,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: widget.buttonSize,
                      height: widget.buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.submitted
                            ? null
                            : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE8F4FF), Colors.white],
                              ),
                        color: widget.submitted ? Colors.white : null,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0072FF).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: widget.submitted
                          ? Icon(Icons.done, color: Colors.green, size: 36.sp)
                          : Center(
                              child: Transform.rotate(
                                angle: 90 * math.pi / 180,
                                child: const Icon(
                                  Icons.airplanemode_active,
                                  size: 35,
                                  color: Color(0xFF0072FF),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ✅ التغيير الوحيد هنا — استخدام airplane1.svg من Assets
class AirplaneIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AirplaneIcon({
    super.key,
    this.size = 35,
    this.color = const Color(0xFF0072FF),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -45 * math.pi / 180, // ✅ تدوير -45 درجة لتصير قائمة لفوق
      child: SvgPicture.asset(
        'assets/icons/airplane3.svg',
        width: size,
        height: size,
      ),
    );
  }
}

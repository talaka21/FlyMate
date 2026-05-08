import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Neighborhood {
  final String name;
  final String imagePath;
  final Color color;
  final bool wide;

  const Neighborhood(
    this.name,
    this.color, {
    this.wide = false,
    required this.imagePath,
  });
}

class Experience {
  final String emoji;
  final Color bgColor;
  final String name;
  final String desc;
  final List<Badge> badges;
  const Experience(this.emoji, this.bgColor, this.name, this.desc, this.badges);
}

class Badge {
  final String label;
  final Color bg;
  final Color text;
  const Badge(this.label, this.bg, this.text);
}

class FoodItem {
  final String imagePath; // مسار الصورة الحقيقية بدل الإيموجي
  final String name;
  final String locationName; // اسم المنطقة (ديرة، مارينا...)
  final String price;
  final String phone; // رقم التلفون للاتصال
  final double lat; // خط العرض للخرائط
  final double lng; // خط الطول للخرائط
  final Color bg; // في حال بدك تخليه كـ Fallback أو للديزاين

  const FoodItem({
    required this.imagePath,
    required this.name,
    required this.locationName,
    required this.price,
    required this.phone,
    required this.lat,
    required this.lng,
    this.bg = Colors.white, // قيمة افتراضية
  });
}

class MonthData {
  final String name;
  final MonthType type;
  const MonthData(this.name, this.type);
}

enum MonthType { peak, good, hot }

class TripDay {
  final int day;
  final String title;
  final List<TripActivity> activities;
  const TripDay(this.day, this.title, this.activities);
}

class TripActivity {
  final String time;
  final String place;
  final String tip;
  final String emoji;
  const TripActivity(this.time, this.place, this.tip, this.emoji);
}

// ─── Static Data ────────────────────────────────────────────────────────────

const neighborhoods = [
  Neighborhood(
    'Dubai Marina',
    Color(0xFF000000),
    imagePath: "assets/images/dubai_marina2.jpg",
  ),
  Neighborhood(
    'Old Deira',
    Color(0xFF3A2010),
    imagePath: "assets/images/olddeirah.jpg",
  ),
  Neighborhood(
    'Jumeirah',
    Color(0xFF1A3A20),
    imagePath: "assets/images/jumeirah2.jpg",
  ),
  Neighborhood(
    'Downtown Dubai',

    Color(0xFF2A1A3A),
    // wide: true,
    imagePath: "assets/images/downtown dubai2.jpg",
  ),
];

const experiences = [
  Experience(
    '🏙',
    Color(0xFFE6F1FB),
    'Burj Khalifa — Top of the World',
    'Ride to floor 148 and see all of Dubai beneath you. The sunset view is indescribable.',
    [
      Badge('⭐ Very Famous', Color(0xFFFAEEDA), Color(0xFF854F0B)),
      Badge('From 100 AED', Color(0xFFE6F1FB), Color(0xFF185FA5)),
    ],
  ),
  Experience(
    '🏜',
    Color(0xFFEAF3DE),
    'Desert Safari',
    'Dune bashing, Bedouin dinner under the stars, and camel riding — a journey back in time.',
    [
      Badge('🌙 Night Tour', Color(0xFFEAF3DE), Color(0xFF3B6D11)),
      Badge('From 200 AED', Color(0xFFE6F1FB), Color(0xFF185FA5)),
    ],
  ),
  Experience(
    '🛍',
    Color(0xFFFBEAF0),
    'Dubai Mall + Aquarium',
    'The world\'s largest mall has a massive aquarium, ice rink, and indoor theme park.',
    [
      Badge('🐠 Family Friendly', Color(0xFFFAEEDA), Color(0xFF854F0B)),
      Badge('Free Entry', Color(0xFFEAF3DE), Color(0xFF3B6D11)),
    ],
  ),
  Experience(
    '🌊',
    Color(0xFFFAECE7),
    'Palm Jumeirah Island',
    'Monorail tour, Atlantis beach, and the best sea view in Dubai.',
    [
      Badge('🔥 Must Visit', Color(0xFFFCEBEB), Color(0xFFA32D2D)),
      Badge('Open All Day', Color(0xFFE6F1FB), Color(0xFF185FA5)),
    ],
  ),
];

final foodItems = [
  // 1. الشاورما - تم استبدال خالد بـ "عروس دمشق" الأشهر في الديرة
  const FoodItem(
    name: 'Aroos Damascus',
    locationName: 'Deira · Al Muraqqabat',
    price: 'From 10 AED',
    imagePath: 'assets/images/shaowrma.jpg',
    phone: '+97142220222',
    lat: 25.2678,
    lng: 55.3272,
    bg: Color(0xFFFAEEDA),
  ),

  // 2. المأكولات البحرية - مطعم "Pierchic" الشهير في المارينا (فخم جداً)
  const FoodItem(
    name: 'Pierchic Marina',
    locationName: 'Luxury · Madinat Jumeirah',
    price: 'From 250 AED',
    imagePath: 'assets/images/salmom.jpg',
    phone: '+971800323232',
    lat: 25.1328,
    lng: 55.1848,
    bg: Color(0xFFE1F5EE),
  ),

  // 3. سوق الذهب والتوابل - تجربة تراثية
  const FoodItem(
    name: 'Gold & Spice Souk',
    locationName: 'Historic · Bur Dubai',
    price: 'Free to Explore',
    imagePath:
        'assets/images/market-stall-with-colorful-spices-background_582637-3053.jpg',
    phone: '+97142060000', // رقم بلدية دبي/السياحة للمعلومات
    lat: 25.2694,
    lng: 55.2973,
    bg: Color(0xFFFAECE7),
  ),

  // 4. كافيهات JBR - مطعم "The Cheesecake Factory" أو كافيهات ممشى JBR
  const FoodItem(
    name: 'Common Grounds JBR',
    locationName: 'Café · The Beach',
    price: 'From 45 AED',
    imagePath: 'assets/images/eggs-benedict-on-the-beach.jpg',
    phone: '+97144270440',
    lat: 25.0768,
    lng: 55.1294,
    bg: Color(0xFFEEEDFE),
  ),

  // 5. المطاعم الآسيوية - مطعم "Din Tai Fung" الشهير
  const FoodItem(
    name: 'Din Tai Fung',
    locationName: 'Asian · Mall of Emirates',
    price: 'From 60 AED',
    imagePath:
        'assets/images/freshly-steamed-dim-sum-in-bamboo-containers-generated-by-ai-free-photo.jpg',
    phone: '+97142651288',
    lat: 25.1181,
    lng: 55.2006,
    bg: Color(0xFFEAF3DE),
  ),
];

const months = [
  MonthData('Jun', MonthType.hot),
  MonthData('Jul', MonthType.hot),
  MonthData('Aug', MonthType.hot),
  MonthData('Sep', MonthType.good),
  MonthData('Oct', MonthType.peak),
  MonthData('Nov', MonthType.peak),
  MonthData('Dec', MonthType.peak),
  MonthData('Jan', MonthType.peak),
  MonthData('Feb', MonthType.peak),
  MonthData('Mar', MonthType.good),
  MonthData('Apr', MonthType.good),
  MonthData('May', MonthType.hot),
];

const tripDays = [
  TripDay(1, 'Downtown & Heights', [
    TripActivity(
      '9:00 AM',
      'Burj Khalifa (Level 124)',
      'Book tickets online to skip the queue',
      '🏙',
    ),
    TripActivity(
      '12:00 PM',
      'Dubai Mall & Aquarium',
      'The aquarium tunnel is free to walk through',
      '🛍',
    ),
    TripActivity(
      '6:00 PM',
      'Dubai Fountain Show',
      'Best viewed from the waterfront promenade',
      '⛲',
    ),
    TripActivity(
      '8:00 PM',
      'Dinner at Souk Al Bahar',
      'Great views of the lit-up Burj Khalifa',
      '🍽',
    ),
  ]),
  TripDay(2, 'Heritage & Old Dubai', [
    TripActivity(
      '8:30 AM',
      'Al Fahidi Historic District',
      'Start early before it gets hot',
      '🏛',
    ),
    TripActivity(
      '10:00 AM',
      'Dubai Museum',
      'Entry is only 3 AED — best value in the city',
      '🏺',
    ),
    TripActivity(
      '11:30 AM',
      'Abra Ride across the Creek',
      'Traditional wooden boat, just 1 AED',
      '⛵',
    ),
    TripActivity(
      '1:00 PM',
      'Gold & Spice Souk',
      'Bargaining is expected and fun here',
      '🥇',
    ),
  ]),
  TripDay(3, 'Beach & Palm Island', [
    TripActivity(
      '10:00 AM',
      'Jumeirah Public Beach',
      'Free beach with great Burj Al Arab views',
      '🏖',
    ),
    TripActivity(
      '1:00 PM',
      'Palm Jumeirah Monorail',
      'Ride end-to-end for panoramic views',
      '🚝',
    ),
    TripActivity(
      '3:00 PM',
      'Atlantis Aquaventure',
      'Best waterpark in the region',
      '🎢',
    ),
    TripActivity(
      '8:00 PM',
      'NOBU or Atlantis Dinner',
      'Splurge-worthy sunset dining experience',
      '🌅',
    ),
  ]),
  TripDay(4, 'Desert & Culture', [
    TripActivity(
      'Free Morning',
      'Relax at Hotel Pool',
      'Recharge before the evening adventure',
      '🏊',
    ),
    TripActivity(
      '3:00 PM',
      'Desert Safari Pickup',
      'Choose a reputable tour operator',
      '🏜',
    ),
    TripActivity(
      '5:00 PM',
      'Dune Bashing & Sandboarding',
      'Hold on tight — it\'s a wild ride!',
      '🏂',
    ),
    TripActivity(
      '7:00 PM',
      'Bedouin Camp Dinner',
      'Includes live music, henna & stargazing',
      '🌙',
    ),
  ]),
  TripDay(5, 'Marina & Farewell', [
    TripActivity(
      '10:00 AM',
      'JBR Walk & Beach',
      'Best brunch spots along the waterfront',
      '☕',
    ),
    TripActivity(
      '1:00 PM',
      'Dubai Marina Walk',
      'Yacht watching and great lunch spots',
      '⛵',
    ),
    TripActivity(
      '4:00 PM',
      'Global Village (seasonal)',
      'Cultures from 90+ countries in one place',
      '🌍',
    ),
    TripActivity(
      '8:00 PM',
      'Sky Views Observatory',
      'Glass slide on the 53rd floor — surreal!',
      '🎡',
    ),
  ]),
  TripDay(6, 'Future & Flowers', [
    TripActivity(
      '10:00 AM',
      'Museum of the Future',
      'One of the most beautiful buildings in the world',
      '🖼',
    ),
    TripActivity(
      '1:00 PM',
      'Lunch at DIFC',
      'Top-tier restaurants in the financial district',
      '🍽',
    ),
    TripActivity(
      '4:00 PM',
      'Dubai Miracle Garden',
      'World\'s largest natural flower garden (seasonal)',
      '🌺',
    ),
    TripActivity(
      '7:00 PM',
      'Dubai Butterfly Garden',
      'Located right next to Miracle Garden',
      '🦋',
    ),
  ]),
  TripDay(7, 'Luxury & Last Views', [
    TripActivity(
      '10:00 AM',
      'The View at The Palm',
      '360-degree views of Palm Jumeirah',
      '🏝',
    ),
    TripActivity(
      '1:00 PM',
      'Kite Beach',
      'Great vibes, food trucks, and watersports',
      '🏄',
    ),
    TripActivity(
      '4:00 PM',
      'Madinat Jumeirah',
      'Modern souk with "Little Venice" water canals',
      '🛶',
    ),
    TripActivity(
      '8:00 PM',
      'Farewell Dinner at Bluewaters Island',
      'Walk under the Ain Dubai wheel for a grand finale',
      '🎡',
    ),
  ]),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class DubaiCityGuide extends StatelessWidget {
  const DubaiCityGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroSection()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 14),
                _StatsRow(),
                const SizedBox(height: 18),
                _SectionHeader(title: 'Neighborhoods'),
                const SizedBox(height: 10),
                _NeighborhoodsGrid(),
                const SizedBox(height: 18),
                _SectionHeader(title: 'Unforgettable Experiences'),
                const SizedBox(height: 10),
                _ExperiencesList(),
                const SizedBox(height: 18),
                _SectionHeader(title: 'Must-Try Food'),
                const SizedBox(height: 10),
                _FoodScroll(),
                const SizedBox(height: 18),
                _BestTimeSection(),
                const SizedBox(height: 18),
                _PlanTripButton(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient (replace with NetworkImage in production)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/dubai11.jpg"),
                fit: BoxFit.cover, // مهم جداً
              ),
            ),
          ),
          // Dark overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xCC081028)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Top buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  _CircleButton(
                    icon: Icons.favorite_border_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // Bottom content
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 5,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withOpacity(0.15),
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(color: Colors.white.withOpacity(0.3)),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       _PulseDot(),
                //       const SizedBox(width: 6),
                //       const Text(
                //         'City of the Future',
                //         style: TextStyle(color: Colors.white, fontSize: 11),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(
                        text: 'Dubai\n',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'The city of the future',
                        style: TextStyle(
                          color: Color(0xFFF0C060),
                          fontStyle: FontStyle.italic,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);
  late final Animation<double> _a = Tween(begin: 1.0, end: 0.3).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF4ADE80),
        ),
      ),
    );
  }
}

// ─── Stats Row ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            '200+',
            'Nationalities',
            bgColor: Color(0xFF1A2A4A),
            valueColor: Color(0xFFF0C060),
            labelColor: Color(0xFFffffff),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            '34°',
            'Avg Temperature',
            bgColor: Color(0xFFC85A20),
            valueColor: Color(0xFFFFF5E0),
            labelColor: Color(0xFFFCD0B0),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            '#1',
            'Luxury Destination',
            bgColor: Color(0xFFD4A010),
            valueColor: Color(0xFF1A1000),
            labelColor: Color(0xFF000000),
            // labelColor: Color(0xFF5A3A00),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bgColor;
  final Color valueColor;
  final Color labelColor;

  const _StatCard(
    this.value,
    this.label, {
    required this.bgColor,
    required this.valueColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1E),
      ),
    );
  }
}

// ─── Neighborhoods ───────────────────────────────────────────────────────────

class _NeighborhoodsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _NbCard(neighborhoods[0])),
            const SizedBox(width: 8),
            Expanded(child: _NbCard(neighborhoods[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _NbCard(neighborhoods[2])),
            const SizedBox(width: 8),
            Expanded(child: _NbCard(neighborhoods[3])),
          ],
        ),
      ],
    );
  }
}

class _NbCard extends StatelessWidget {
  final Neighborhood nb;
  const _NbCard(this.nb);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              NeighborhoodDetailPage(neighborhood: nb), // هنا نمرر البيانات
        ),
      ),
      child: Container(
        height: nb.wide ? 90 : 110,
        decoration: BoxDecoration(
          color: nb.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(nb.imagePath),
                ),
                borderRadius: BorderRadius.circular(14),
                // gradient: LinearGradient(
                //   colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nb.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 4.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Experiences ─────────────────────────────────────────────────────────────

class _ExperiencesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: experiences
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ExpCard(e),
            ),
          )
          .toList(),
    );
  }
}

class _ExpCard extends StatelessWidget {
  final Experience exp;
  const _ExpCard(this.exp);

  @override
  Widget build(BuildContext context) {
    // روابط صور مباشرة ومستقرة من Unsplash
    String imageUrl =
        "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=1000&auto=format&fit=crop"; // افتراضية (دبي)

    if (exp.name.contains("Khalifa")) {
      // رابط جديد ومباشر لبرج خليفة يعمل 100%
      imageUrl =
          "https://images.unsplash.com/photo-1582672060674-bc2bd808a8b5?q=80&w=1000&auto=format&fit=crop";
    } else if (exp.name.contains("Safari")) {
      imageUrl =
          "https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?q=80&w=1000&auto=format&fit=crop";
    } else if (exp.name.contains("Mall")) {
      imageUrl =
          "https://images.unsplash.com/photo-1582650625119-3a31f8fa2699?q=80&w=1000&auto=format&fit=crop";
    } else if (exp.name.contains("Palm")) {
      imageUrl =
          "https://images.unsplash.com/photo-1578895210405-907db486c111?q=80&w=1000&auto=format&fit=crop";
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // تقليل الشفافية لظلال أوضح
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. صورة الخلفية مع معالجة التحميل والخطأ
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(
                    0xFF1A1A1A,
                  ), // خلفية داكنة فخمة في حال الخطأ
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),

            // 2. التدرج اللوني (أعمق في الأسفل لبروز النصوص)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // 3. المحتوى
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // شارة "Must Experience"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          "MUST EXPERIENCE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exp.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exp.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // الصف السفلي (التقييم والسهم)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildMiniBadge("⭐ 4.9"),
                          const SizedBox(width: 8),
                          if (exp.badges.isNotEmpty)
                            _buildMiniBadge(exp.badges.first.label),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_circle_right_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget مساعد للبطاقات الصغيرة
  Widget _buildMiniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Widget _buildMiniBadge(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ─── Food Scroll ─────────────────────────────────────────────────────────────

class _FoodScroll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: foodItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _FoodCard(foodItems[i]),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodItem item;
  const _FoodCard(this.item);

  // دالة لإظهار الخيارات (اتصال / موقع)
  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('call the restaurant'),
              onTap: () async {
                final Uri launchUri = Uri(scheme: 'tel', path: item.phone);
                await launchUrl(launchUri);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Explore on Map'),
              onTap: () async {
                // إحداثيات مطعم عروس دمشق كمثال
                final String googleMapsUrl =
                    "https://www.google.com/maps/search/?api=1&query=${item.lat},${item.lng}";
                await launchUrl(Uri.parse(googleMapsUrl));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // إضافة التفاعل عند الكبس
      onTap: () => _showActionSheet(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 190, // كبرنا العرض شوي ليناسب الصور الحقيقية
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.3)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الجزء العلوي: الصورة الحقيقية بدل الأيقونة
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImagePreviewPage(imagePath: item.imagePath),
                  ),
                );
              },
              child: Hero(
                tag: item.imagePath, // التاج لازم يكون فريد لكل صورة
                child: Container(
                  height: 85,
                  width: double.infinity,
                  child: Image.asset(item.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  // const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        size: 18,
                        color: Colors.red,
                      ),
                      // const SizedBox(width: 2),
                      Text(
                        item.locationName, // اسم المنطقة (ديرة، مارينا..)
                        style: const TextStyle(
                          fontSize: 12,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Best Time ───────────────────────────────────────────────────────────────

class _BestTimeSection extends StatelessWidget {
  Color _getColor(MonthType t) {
    switch (t) {
      case MonthType.peak:
        return const Color(0xFFF0C060);
      case MonthType.good:
        return const Color(0xFF4ADE80);
      case MonthType.hot:
        return const Color(0xFFF87171);
    }
  }

  Color _getBg(MonthType t) {
    switch (t) {
      case MonthType.peak:
        return const Color(0x40C8860A);
      case MonthType.good:
        return const Color(0x334ADE80);
      case MonthType.hot:
        return const Color(0x33F87171);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1A3A), Color(0xFF1A3A7C), Color(0xFF0A2A50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 Best Time to Visit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.9,
            children: months
                .map(
                  (m) => Container(
                    decoration: BoxDecoration(
                      color: _getBg(m.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          m.name,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getColor(m.type),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getColor(m.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendItem(const Color(0xFFF0C060), 'Golden season'),
              const SizedBox(width: 16),
              _LegendItem(const Color(0xFF4ADE80), 'Good'),
              const SizedBox(width: 16),
              _LegendItem(const Color(0xFFF87171), 'Very Hot'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.75)),
        ),
      ],
    );
  }
}

// ─── Plan Trip Button ────────────────────────────────────────────────────────

class _PlanTripButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTripPlanner(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2557),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Plan My Dubai Trip — 5 Days',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trip Planner Bottom Sheet ────────────────────────────────────────────────

void _showTripPlanner(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _TripPlannerSheet(),
  );
}

class _TripPlannerSheet extends StatefulWidget {
  const _TripPlannerSheet();

  @override
  State<_TripPlannerSheet> createState() => _TripPlannerSheetState();
}

class _TripPlannerSheetState extends State<_TripPlannerSheet> {
  int _selectedDays = 5;

  @override
  Widget build(BuildContext context) {
    final days = tripDays.take(_selectedDays).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dubai Trip Planner',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your day-by-day itinerary',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                // Days selector
                Row(
                  children: [3, 5, 7]
                      .map(
                        (d) => GestureDetector(
                          onTap: () => setState(() => _selectedDays = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedDays == d
                                  ? const Color(0xFF0F2557)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedDays == d
                                    ? const Color(0xFF0F2557)
                                    : Colors.black.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              '${d}d',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedDays == d
                                    ? Colors.white
                                    : const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Days list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _DayCard(days[i]),
            ),
          ),
          // Save button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Expanded(
              child: _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share Trip',
                primary: true,
                onTap: () async {
                  await shareTripAsPDF(tripDays);
                  // String tripSummary = tripDays
                  //     .map(
                  //       (day) =>
                  //           "${day.title}:\n${day.activities.map((a) => "- ${a.time}: ${a.place}").join("\n")}",
                  //     )
                  //     .join("\n\n");

                  // Share.share('this my trip plane:\n\n$tripSummary');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final TripDay day;
  const _DayCard(this.day);

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2557),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'D${widget.day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.day.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        Text(
                          '${widget.day.activities.length} activities',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, indent: 14, endIndent: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  children: widget.day.activities
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ActivityRow(a),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final TripActivity activity;
  const _ActivityRow(this.activity);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activity.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.place,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F1FB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      activity.time,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF185FA5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                activity.tip,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF0F2557) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primary
                ? const Color(0xFF0F2557)
                : Colors.black.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primary ? Colors.white : const Color(0xFF1C1C1E),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: primary ? Colors.white : const Color(0xFF1C1C1E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpotItem {
  final String emoji;
  final Color bgColor;
  final String name;
  final String subtitle;
  const SpotItem(this.emoji, this.bgColor, this.name, this.subtitle);
}

class NeighborhoodDetail {
  final String description;
  final List<SpotItem> highlights;
  final List<TagItem> tags;
  const NeighborhoodDetail({
    required this.description,
    required this.highlights,
    required this.tags,
  });
}

class TagItem {
  final String label;
  final Color bg;
  final Color textColor;
  const TagItem(this.label, this.bg, this.textColor);
}

const neighborhoodDetails = {
  'Dubai Marina': NeighborhoodDetail(
    description:
        'A stunning waterfront district lined with skyscrapers, luxury yachts, and a vibrant promenade packed with restaurants and nightlife.',
    tags: [
      TagItem('🌊 Waterfront', Color(0xFFD1E9FF), Color(0xFF0056A4)),
      TagItem('🌙 Nightlife', Color(0xFFE5DFFF), Color(0xFF4338CA)),
      TagItem('✨ Luxury', Color(0xFFFFE9C2), Color(0xFF92400E)),
    ],
    highlights: [
      SpotItem(
        '🚶',
        Color(0xFF224075),
        'Marina Walk',
        '3.5km waterfront promenade',
      ),
      SpotItem(
        '🏖',
        Color(0xFF18633A),
        'JBR Beach',
        'Public beach · Water sports',
      ),
      SpotItem(
        '🛍',
        Color(0xFF6B1336),
        'The Beach Mall',
        'Shopping · Dining · Cinema',
      ),
      SpotItem(
        '🎡',
        Color(0xFF4A2C6A),
        'Bluewaters Island',
        'Ain Dubai · Entertainment',
      ),
    ],
  ),
  'Old Deira': NeighborhoodDetail(
    description:
        'The historic heart of Dubai — explore traditional souks, heritage museums, and take an abra ride across the iconic Dubai Creek.',
    tags: [
      TagItem('🏛 Heritage', Color(0xFFFAECE7), Color(0xFF993C1D)),
      TagItem('🎭 Culture', Color(0xFFEAF3DE), Color(0xFF3B6D11)),
      TagItem('💰 Budget-Friendly', Color(0xFFFAEEDA), Color(0xFF854F0B)),
    ],
    highlights: [
      SpotItem(
        '🥇',
        Color(0xFFFAEEDA),
        'Gold Souk',
        'World-famous gold market',
      ),
      SpotItem(
        '🌶',
        Color(0xFFFAECE7),
        'Spice Souk',
        'Aromatic spices & herbs',
      ),
      SpotItem(
        '🏛',
        Color(0xFFEAF3DE),
        'Al Fahidi District',
        'Historic wind-tower houses',
      ),
      SpotItem(
        '⛵',
        Color(0xFFE6F1FB),
        'Abra Ride',
        'Creek crossing · 1 AED only',
      ),
    ],
  ),
  'Jumeirah': NeighborhoodDetail(
    description:
        'Upscale beachside neighbourhood famous for its white-sand beaches, luxury hotels, and the iconic sail-shaped Burj Al Arab.',
    tags: [
      TagItem('🏖 Beach', Color(0xFFE6F1FB), Color(0xFF185FA5)),
      TagItem('✨ Luxury', Color(0xFFFAEEDA), Color(0xFF854F0B)),
      TagItem('👨‍👩‍👧 Family', Color(0xFFEAF3DE), Color(0xFF3B6D11)),
    ],
    highlights: [
      SpotItem('🏖', Color(0xFFE6F1FB), 'Jumeirah Beach', 'Free public beach'),
      SpotItem(
        '🏨',
        Color(0xFFFAEEDA),
        'Burj Al Arab View',
        'Iconic sail-shaped hotel',
      ),
      SpotItem(
        '🕌',
        Color(0xFFEEEDFE),
        'Jumeirah Mosque',
        'Open to visitors · Tours daily',
      ),
      SpotItem('🌊', Color(0xFFE1F5EE), 'La Mer', 'Beachfront dining & shops'),
    ],
  ),
  'Downtown Dubai': NeighborhoodDetail(
    description:
        'The beating heart of modern Dubai — home to the world\'s tallest tower, largest mall, and the mesmerising Dubai Fountain show.',
    tags: [
      TagItem('🏙 Iconic', Color(0xFFEEEDFE), Color(0xFF534AB7)),
      TagItem('🛍 Shopping', Color(0xFFFBEAF0), Color(0xFF993556)),
      TagItem('🔥 Must-Visit', Color(0xFFFCEBEB), Color(0xFFA32D2D)),
    ],
    highlights: [
      SpotItem(
        '🏙',
        Color(0xFFE6F1FB),
        'Burj Khalifa',
        'World\'s tallest tower',
      ),
      SpotItem('🛍', Color(0xFFFBEAF0), 'Dubai Mall', 'World\'s largest mall'),
      SpotItem(
        '⛲',
        Color(0xFFE1F5EE),
        'Dubai Fountain',
        'Largest dancing fountain',
      ),
      SpotItem(
        '🍽',
        Color(0xFFFAEEDA),
        'Souk Al Bahar',
        'Dining with Burj views',
      ),
    ],
  ),
};
// ─── Neighborhood Detail Page ─────────────────────────────────────────────

class NeighborhoodDetailPage extends StatelessWidget {
  final Neighborhood neighborhood;
  const NeighborhoodDetailPage({required this.neighborhood, super.key});

  @override
  Widget build(BuildContext context) {
    final detail = neighborhoodDetails[neighborhood.name]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: neighborhood.color,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // لون الحي كخلفية (استبدله بـ Image.network لما تضيف الصور)
                  Container(color: neighborhood.color),
                  // Overlay
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(neighborhood.imagePath),
                      ),
                    ),
                  ),
                  // Title
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          neighborhood.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body Content ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Wrap(
                  spacing: 7.w,
                  runSpacing: 7.w,
                  children: detail.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: tag.bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: tag.textColor,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),

                // ── Description ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Text(
                    detail.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3C3C3E),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Top Spots ──
                const Text(
                  'Top Spots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 10),

                // التعديل هون يا بطل:
                ...detail.highlights.asMap().entries.map((entry) {
                  int index = entry.key; // هاد هو الـ index
                  var spot = entry.value; // هاد هو الـ spot (العنصر)

                  return InkWell(
                    onTap: () {
                      if (index == 0) {
                        showSpotDetails(
                          context,
                          "Marina Walk",
                          "A stunning 7km palm-lined promenade featuring world-class dining and luxury yachts.",
                          const Color(0xFF224075),
                          "https://www.google.com/maps/search/?api=1&query=Dubai+Marina+Walk",
                        );
                      } else if (index == 1) {
                        showSpotDetails(
                          context,
                          "JBR Beach",
                          "One of Dubai's most vibrant public beaches with white sands and water sports.",
                          const Color(0xFF18633A),
                          "https://www.google.com/maps/search/?api=1&query=JBR+Beach+Dubai",
                        );
                      } else if (index == 2) {
                        showSpotDetails(
                          context,
                          "The Beach Mall",
                          "An upscale outdoor shopping and dining destination right on the coast.",
                          const Color(0xFF6B1336),
                          "https://www.google.com/maps/search/?api=1&query=The+Beach+JBR+Dubai",
                        );
                      } else if (index == 3) {
                        showSpotDetails(
                          context,
                          "Bluewaters Island",
                          "Modern man-made island home to 'Ain Dubai' with unique architecture.",
                          const Color(0xFF4A2C6A),
                          "https://www.google.com/maps/search/?api=1&query=Bluewaters+Island+Dubai",
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: spot.bgColor,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                spot.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spot.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  spot.subtitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFCCCCCC),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),

                InkWell(
                  onTap: () => openDubaiMarina(),
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    // استبدل Container بـ Ink
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: neighborhood.color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Explore on Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openDubaiMarina() async {
  // استخدم هذا الرابط الصريح لخرائط جوجل
  final Uri googleMapsUri = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=Dubai+Marina",
  );

  try {
    // جرب الفتح مباشرة بدون canLaunchUrl (أحياناً canLaunchUrl بتعطي false وهي شغالة)
    await launchUrl(
      googleMapsUri,
      mode:
          LaunchMode.externalApplication, // بيفتح تطبيق الخرائط المنصب ع الجوال
    );
  } catch (e) {
    debugPrint("Error launching maps: $e");
    // إذا فشل، جرب تفتحه بالمتصفح كخيار بديل
    await launchUrl(googleMapsUri, mode: LaunchMode.platformDefault);
  }
}

void showSpotDetails(
  BuildContext context,
  String title,
  String description,
  Color themeColor,
  String mapUrl,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // هون منستخدم الـ mapUrl الخاص بكل منطقة
                  launchUrl(
                    Uri.parse(mapUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text("Get Directions"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

class ExperienceCard extends StatelessWidget {
  final String title;
  final String description;
  final String tag1;
  final String tag2;
  final String imagePath; // أو رابط الصورة

  const ExperienceCard({
    required this.title,
    required this.description,
    required this.tag1,
    required this.tag2,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, // العرض إذا كنت ستستخدمه في ListView أفقي
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. حاوية الصورة/الأيقونة
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.orange[50], // لون خلفية خفيف للأيقونة
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imagePath, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 16),

          // 2. المحتوى النصي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),

                // 3. التاغات (الأسفل)
                Row(
                  children: [
                    _buildChip(tag1, Colors.orange[100]!, Colors.orange[800]!),
                    SizedBox(width: 8),
                    _buildChip(tag2, Colors.blue[50]!, Colors.blue[700]!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Future<void> shareTripAsPDF(List<TripDay> days) async {
  final pdf = pw.Document();

  // تنسيق الصفحة
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30), // هوامش أوسع للشكل الاحترافي
      build: (pw.Context context) {
        return [
          // 1. رأس الصفحة المصمم (Header)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey800, // لون خلفية داكن وراقي
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "MY DUBAI ADVENTURE",
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "7-Day Itinerary | Planned with FlyMate",
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.white),
                    ),
                  ],
                ),
                // يمكنك إضافة أيقونة بسيطة هنا (مثل طائرة) إذا كانت مدعومة
                // pw.Text("✈️", style: const pw.TextStyle(fontSize: 40)),
              ],
            ),
          ),

          pw.SizedBox(height: 30), // فراغ كبير بعد الرأس
          // 2. جسم الصفحة: الأيام والأنشطة
          ...days
              .map(
                (day) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // عنوان اليوم بتصميم أجمل
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 25,
                          height: 25,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.blueGrey600,
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              "${day.day}",
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColor.fromInt(0xffffffff),
                              ),
                            ),
                          ), // أيقونة موقع
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          "Day ${day.day}: ${day.title}",
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),

                    // الأنشطة لكل يوم بشكل منظم
                    ...day.activities.map(
                      (activity) => pw.Padding(
                        padding: const pw.EdgeInsets.only(
                          left: 35,
                          bottom: 12,
                        ), // إزاحة للداخل
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // الوقت بتنسيق مميز
                            pw.Container(
                              width: 70,
                              child: pw.Text(
                                activity.time,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey700,
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 10),
                            // اسم النشاط والـ emoji
                            pw.Expanded(
                              child: pw.Text(
                                "${activity.place} | Travel tip: ${activity.tip}",
                                style: pw.TextStyle(color: PdfColors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // خط فاصل رفيع بين الأيام
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 20),
                      child: pw.Divider(
                        color: PdfColors.grey300,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),

          // 3. تذييل الصفحة (Footer)
          pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              "Generated by FlyMate App | FlyMate.com",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey500,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ];
      },
    ),
  );

  // حفظ الملف مؤقتاً ومشاركته (نفس الكود السابق)
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/my_dubai_trip.pdf");
  await file.writeAsBytes(await pdf.save());

  await Share.shareXFiles([
    XFile(file.path),
  ], text: 'Check out my professional 7-day trip plan!');
}

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  const ImagePreviewPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء لتركيز النظر على الصورة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imagePath, // نفس التاج الموجود في البطاقة
          child: InteractiveViewer(
            // بيسمح للمستخدم يعمل Zoom بأصابعه
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

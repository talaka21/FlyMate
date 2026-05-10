import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fly_mate/features/Airlines/presentation/screens/airlines_page..dart';
import 'package:fly_mate/features/tickets/presentation/screens/tickets_page.dart';
import 'package:fly_mate/features/home/data/data_sources/today_flights_data_source.dart';
import 'package:fly_mate/features/home/data/models/flight_display_model.dart';
import 'package:fly_mate/features/home/logic/today_flights_cubit.dart';
import 'package:fly_mate/features/home/logic/today_flights_state.dart';
import 'package:fly_mate/features/home/presentation/widgets/Destinations_list_widget.dart';
import 'package:fly_mate/features/home/presentation/widgets/flight_card_widget.dart';
import 'package:fly_mate/features/home/presentation/widgets/header_widget.dart';
import 'package:fly_mate/features/home/presentation/widgets/hero_card_widget.dart';
import 'package:fly_mate/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:fly_mate/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:fly_mate/features/home/presentation/widgets/section_title_widget.dart';
import 'package:fly_mate/features/home/presentation/widgets/settings_drawer.dart';

class Destination {
  final String city;
  final String country;
  final String imageUrl;
  final Color cardColor;

  const Destination({
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.cardColor,
  });
}

final List<Destination> dummyDestinations = [
  const Destination(
    city: 'Dubai',
    country: 'UAE',
    imageUrl:
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=300&h=200&fit=crop',
    cardColor: Color(0xFFDFB86A),
  ),
  const Destination(
    city: 'Istanbul',
    country: 'Turkey',
    imageUrl:
        'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=300&h=200&fit=crop',
    cardColor: Color(0xFFDF6A6A),
  ),
  const Destination(
    city: 'Doha',
    country: 'Qatar',
    imageUrl:
        'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=300&h=200&fit=crop',
    cardColor: Color(0xFF8B3A6A),
  ),
  const Destination(
    city: 'Amman',
    country: 'Jordan',
    imageUrl:
        'https://images.unsplash.com/photo-1579606032821-4e6161c81bd3?w=300&h=200&fit=crop',
    cardColor: Color(0xFFDF8A6A),
  ),
  const Destination(
    city: 'Damascus',
    country: 'Syria',
    imageUrl:
        'https://images.unsplash.com/photo-1580834341580-8c17a3a630ca?w=300&h=200&fit=crop',
    cardColor: Color(0xFF6A8FDF),
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodayFlightsCubit(TodayFlightsDataSource())..load(),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  final TextEditingController _searchController = TextEditingController();
  int _navIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF3FF),
      drawer: _navIndex == 0 ? const SettingsDrawer() : null,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(searchController: _searchController),
          const _PlaceholderTab(icon: Icons.flight_rounded, label: 'Flights'),
          const TicketsPage(isTab: true),
          const _PlaceholderTab(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final TextEditingController searchController;
  const _HomeTab({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF3FF), Color(0xFFF7FAFF)],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TodayFlightsCubit>().load(),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: HeaderWidget(
                  title: "Fly from Damascus",
                  badgeCount: 3,
                  onNotificationTap: () {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: HeroCardWidget()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              const SliverToBoxAdapter(child: QuickActions()),
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: "Airlines at Damascus",
                  onSeeAll: () {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: AirlinesList(airlines: dummyAirlines)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: SectionTitle(
                  title: "Popular Destinations",
                  onSeeAll: () {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: DestinationsList(destinations: dummyDestinations),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: SectionTitle(title: "Today's Flights", onSeeAll: () {}),
              ),
              SliverToBoxAdapter(
                child: SearchBarWidget(
                  controller: searchController,
                  onFilterPressed: () {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              BlocBuilder<TodayFlightsCubit, TodayFlightsState>(
                builder: (context, state) {
                  if (state is TodayFlightsLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (state is TodayFlightsError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 40,
                              color: Color(0xFFB0BEC5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Could not load flights',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.read<TodayFlightsCubit>().load(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final flights = state is TodayFlightsLoaded
                      ? state.flights
                      : <Flight>[];
                  if (flights.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No flights scheduled for today',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList.separated(
                    itemCount: flights.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FlightCard(flight: flights[index]),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Placeholder Tab ───────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF3FF), Color(0xFFF7FAFF)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 38, color: const Color(0xFF1D5BBF)),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A6E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom Bottom Navigation Bar ─────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.flight_rounded, label: 'Flights'),
    _NavItem(icon: Icons.bookmark_rounded, label: 'Bookings'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D5BBF).withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == selectedIndex;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: selected
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A3A6E), Color(0xFF2979E8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: selected
                              ? Colors.white
                              : const Color(0xFFB0BEC5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : const Color(0xFFB0BEC5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

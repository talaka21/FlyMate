import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fly_mate/features/flight_search/data/models/flight_model.dart';
import 'package:fly_mate/features/flight_search/data/models/flight_result_model.dart';
import 'package:fly_mate/features/flight_search/logic/flight_search_cubit.dart';
import 'package:fly_mate/features/flight_search/logic/flight_search_state.dart';
import 'package:fly_mate/features/flight_search/presentation/widgets/filter_row_widget.dart';
import 'package:fly_mate/features/flight_search/presentation/widgets/flight_card_widget.dart';
import 'package:fly_mate/features/flight_search/presentation/widgets/week_calendar_widget.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key, required this.searchRequest});
  final FlightSearchRequest searchRequest;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  FlightSearchRequest? currentRequest;
  FilterType _filter = FilterType.all;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<FlightsCubit>().searchFlights(widget.searchRequest);
  }

  List<FlightResult> _applyFilter(List<FlightResult> list) {
    List<FlightResult> r = List.from(list);

    switch (_filter) {
      case FilterType.direct:
        r = r.where((f) => f.stopsN == 0).toList();
        break;
      case FilterType.cheap:
        r.sort((a, b) => a.price.compareTo(b.price));
        return r; // cheapest already first
      case FilterType.fast:
        r.sort((a, b) => a.durMin.compareTo(b.durMin));
        break;
      case FilterType.all:
        break;
    }

    // Move the cheapest flight to position 0
    if (r.length > 1) {
      final best = r.reduce((a, b) => a.price < b.price ? a : b);
      final bestIndex = r.indexOf(best);
      if (bestIndex > 0) {
        r
          ..removeAt(bestIndex)
          ..insert(0, best);
      }
    }

    return r;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1565C0)),
        title: Text(
          '${widget.searchRequest.fromCode} → ${widget.searchRequest.toCode}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<FlightsCubit, FlightsState>(
        listener: (context, state) {
          if (state is FlightsLoaded || state is FlightsError) {
            setState(() => _isLoading = false);
          }
        },
        builder: (context, state) {
          /// ❌ Error
          if (state is FlightsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          /// ✅ Loaded
          if (state is FlightsLoaded) {
            final flights = _applyFilter(state.flights);

            return Column(
              children: [
                /// 🔽 Filter Row
                FilterRowWidget(
                  current: _filter,
                  onChanged: (f) {
                    setState(() {
                      _filter = f;
                    });
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),

                  child: WeekCalendarWidget(
                    week: state.weekPrices,
                    onDayTap: (newDateDay) {
                      if (_isLoading) return;
                      final baseRequest =
                          currentRequest ?? widget.searchRequest;
                      final currentDate = baseRequest.date;
                      print("👆 ضغطت على اليوم: $newDateDay");
                      print("📆 التاريخ الحالي: $currentDate");
                      final updatedRequest = baseRequest.copyWith(
                        // ✅ حافظ على الشهر والسنة، غير اليوم بس
                        date: DateTime(
                          currentDate.year,
                          currentDate.month,
                          newDateDay,
                        ),
                      );
                      print("🚀 الطلب الجديد date: ${updatedRequest.date}");

                      setState(() => currentRequest = updatedRequest);
                      context.read<FlightsCubit>().searchFlights(
                        updatedRequest,
                      );
                    },
                  ),
                ),

                /// ✈️ Flights List
                Expanded(
                  child: flights.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          itemCount: flights.length,
                          itemBuilder: (context, index) {
                            final flight = flights[index];
                            final bestPrice = flights
                                .map((f) => f.price)
                                .reduce((a, b) => a < b ? a : b);
                            return FlightCardWidget(
                              flight: flight,
                              showBest: flight.price == bestPrice,
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

/// 🪶 Empty State
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Text(
        'No flights match this filter.',
        style: TextStyle(
          fontSize: 20,
          color: Color(0xFF999999),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

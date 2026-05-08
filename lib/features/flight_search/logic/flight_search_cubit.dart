import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/data_sources/flight_remote_data_source.dart';
import '../data/models/flight_model.dart';
import '../data/models/flight_result_model.dart';
import 'flight_search_state.dart';

class FlightsCubit extends Cubit<FlightsState> {
  final FlightRemoteDataSource dataSource;

  FlightsCubit(this.dataSource) : super(FlightsInitial());

  Future<void> searchFlights(FlightSearchRequest req) async {
    emit(FlightsLoading());

    try {
      // 1. جلب البيانات من السيرفر
      final allFlights = await dataSource.fetchFlights(req);

      // 2. تصفية الرحلات حسب الدرجة المطلوبة (Economy/Business)
      final available = allFlights
          .where((f) => f.isClassAvailable(req.flightClass))
          .toList();

      // 3. تحويل الـ Models إلى FlightResult للعرض في الواجهة
      final results = available
          .asMap()
          .entries
          .map((e) => FlightResult.fromModel(
                e.value,
                e.value.id,
                req.flightClass,
                adultCount: req.adults,
                childCount: req.children,
                infantCount: req.infants,
              ))
          .toList();

      // 4. توليد قائمة أسعار الأسبوع (مؤقتاً حتى يدعمها السيرفر)
      // سنقوم بتوليد 7 أيام تبدأ من التاريخ المختار
      final List<DayPrice> weekPrices = _generateWeekPrices(req.date);

      // 5. إرسال الحالة بنجاح مع القائمتين
      emit(FlightsLoaded(results, weekPrices));
    } catch (e) {
      // معالجة حالة الـ 404 كقائمة فارغة وليس كخطأ
      if (e is DioException && e.response?.statusCode == 404) {
        emit(FlightsLoaded([], _generateWeekPrices(req.date)));
      } else {
        emit(FlightsError(e.toString()));
      }
    }
  }

  /// دالة مساعدة لتوليد أيام الأسبوع بناءً على التاريخ المرسل
  List<DayPrice> _generateWeekPrices(DateTime selectedDate) {
    print("🗓️ selectedDate كاملة: $selectedDate");

    return List.generate(7, (index) {
      DateTime day = selectedDate.add(Duration(days: index - 3));
      print(
        "📅 يوم $index: ${day.day}/${day.month}/${day.year} | selected: $selectedDate",
      );

      return DayPrice(
        date: day.day,
        dayLabel: _getDayLabel(day.weekday),
        price: 200 + (index * 10),
        // ✅ مقارنة كاملة مش بس اليوم
        selected:
            day.year == selectedDate.year &&
            day.month == selectedDate.month &&
            day.day == selectedDate.day,
      );
    });
  }

  String _getDayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/constants/app_strings.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/main.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  testWidgets('WeatherApp smoke test renders app bar and search prompt', (WidgetTester tester) async {
    final mockRepo = MockWeatherRepository();
    when(() => mockRepo.getIsFahrenheit()).thenReturn(false);
    when(() => mockRepo.getIsDarkMode()).thenReturn(false);
    when(() => mockRepo.getSearchHistory()).thenReturn([]);
    when(() => mockRepo.getCachedWeather()).thenReturn(null);
    when(() => mockRepo.getCachedTimestamp()).thenReturn(null);
    when(() => mockRepo.hasCachedData).thenReturn(false);

    await tester.pumpWidget(WeatherApp(repository: mockRepo));
    await tester.pumpAndSettle();

    // Verify AppBar title is present
    expect(find.text(AppStrings.appTitle), findsOneWidget);

    // Verify search bar hint is present
    expect(find.text(AppStrings.searchPrompt), findsOneWidget);

    // Verify empty state is displayed initially
    expect(find.text(AppStrings.emptyStateMessage), findsOneWidget);
  });
}

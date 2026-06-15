/// App-wide constants for MoneyLens.
library;

class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'MoneyLens';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String developerName = 'SYAM';

  // User greeting
  static const String userName = 'Syam';

  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const String currencyLocale = 'en_IN';

  // Navigation route paths
  static const String routeDashboard = '/dashboard';
  static const String routeTransactions = '/transactions';
  static const String routeAnalytics = '/analytics';
  static const String routeSettings = '/settings';
  static const String routeBudget = '/budget';
  static const String routeReports = '/reports';
  static const String routeNotifications = '/notifications';
  static const String routeSmsInbox = '/smart-inbox';

  // SharedPreferences keys
  static const String prefThemeMode = 'theme_mode';

  // Database
  static const String databaseName = 'money_lens.db';
  static const int databaseVersion = 1;

  // Animation
  static const double navBarHeight = 60.0;
  static const double navBarIconSize = 24.0;

  // Layout
  static const double pageHorizontalPadding = 20.0;
  static const double cardBorderRadius = 16.0;

  // Mock categories (IDs used across features)
  static const String categoryFoodId = 'food';
  static const String categoryTransportId = 'transport';
  static const String categoryShoppingId = 'shopping';
  static const String categoryHealthcareId = 'healthcare';
  static const String categoryEntertainmentId = 'entertainment';
  static const String categoryUtilitiesId = 'utilities';
  static const String categoryEducationId = 'education';
  static const String categorySalaryId = 'salary';
  static const String categoryFreelanceId = 'freelance';
}

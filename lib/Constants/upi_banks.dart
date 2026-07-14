/// Client-only sentinel for custom UPI bank / app name entry.
abstract final class UpiBanks {
  static const other = 'Other';

  static bool isOther(String bank) => bank == other;
}

extension StringExtension on String {
  String threeDots(int maxLength) {
    return length > maxLength ? '${substring(0, maxLength)}...' : this;
  }
}

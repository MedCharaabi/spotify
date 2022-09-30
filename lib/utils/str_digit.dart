String strDigit(int digit) => digit.toString().padLeft(2, '0');

milisecondToTimeConverter(int milisecond) {
  int seconds = (milisecond / 1000).round();
  int minutes = (seconds / 60).round();
  int hours = (minutes / 60).round();
  return '${strDigit(minutes)}:${strDigit(seconds)}';
}

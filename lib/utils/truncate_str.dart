// Length of the long string need to be omitted the trailing part.
const int longStrLength = 12;

String truncateString(String text) {
  String result = "";
  result = text.length > longStrLength
      ? "${text.substring(0, longStrLength - 4)}..."
      : text;

  return result;
}

extension NumExtentions on num? {
  String get formattedPrice {
    return '\$${this?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '-'}';
  }
}

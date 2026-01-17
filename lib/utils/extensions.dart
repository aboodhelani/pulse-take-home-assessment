extension NumExtentions on num? {
  String get formattedPrice {
    return '\$${this?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '-'}';
  }

  String get formattedPercentage {
    return '${this != null && this! > 0 ? '+' : ''}${this ?? '-'}%';
  }

  String get formattedVolume {
    if (this == null) return '-';
    if (this! >= 1000000000000) {
      return '\$${(this! / 1000000000000).toStringAsFixed(2)}T';
    } else if (this! >= 1000000000) {
      return '\$${(this! / 1000000000).toStringAsFixed(2)}B';
    } else if (this! >= 1000000) {
      return '\$${(this! / 1000000).toStringAsFixed(2)}M';
    } else if (this! >= 1000) {
      return '\$${(this! / 1000).toStringAsFixed(2)}K';
    } else {
      return '\$${this!.toStringAsFixed(2)}';
    }
  }

  String get formattedLargeNumber {
    if (this == null) return '-';
    if (this! >= 1000000000000) {
      return '${(this! / 1000000000000).toStringAsFixed(2)}T';
    } else if (this! >= 1000000000) {
      return '${(this! / 1000000000).toStringAsFixed(2)}B';
    } else if (this! >= 1000000) {
      return '${(this! / 1000000).toStringAsFixed(2)}M';
    } else if (this! >= 1000) {
      return '${(this! / 1000).toStringAsFixed(2)}K';
    } else {
      return this!.toStringAsFixed(2);
    }
  }
}

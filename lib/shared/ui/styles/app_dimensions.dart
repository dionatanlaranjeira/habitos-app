class AppDimensions {
  static AppDimensions? _instance;
  AppDimensions._();

  static AppDimensions get i {
    _instance ??= AppDimensions._();
    return _instance!;
  }

  /// 24 px
  double get pageMargin => 24;

  /// 16 px
  double get tileSpacing => 16;

  /// 16 px
  double get pageSpacing => 16;

  /// 16 px
  double get tilePadding => 16;
}

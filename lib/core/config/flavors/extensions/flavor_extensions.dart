import '../enums/flavor_enum.dart';

extension FlavorExtensions on Flavor {
  String toShortString() {
    return toString().split('.').last;
  }

  String toUpperCase() {
    return toString().split('.').last.toUpperCase();
  }
}

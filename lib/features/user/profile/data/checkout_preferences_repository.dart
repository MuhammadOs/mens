import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Domain Model ---
class CheckoutPreferences {
  final String city;
  final String street;
  final String building;
  final String floor;
  final String flat;
  final String notes;

  const CheckoutPreferences({
    this.city = '',
    this.street = '',
    this.building = '',
    this.floor = '',
    this.flat = '',
    this.notes = '',
  });

  CheckoutPreferences copyWith({
    String? city,
    String? street,
    String? building,
    String? floor,
    String? flat,
    String? notes,
  }) {
    return CheckoutPreferences(
      city: city ?? this.city,
      street: street ?? this.street,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      flat: flat ?? this.flat,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'street': street,
      'building': building,
      'floor': floor,
      'flat': flat,
      'notes': notes,
    };
  }

  factory CheckoutPreferences.fromMap(Map<String, dynamic> map) {
    return CheckoutPreferences(
      city: map['city'] ?? '',
      street: map['street'] ?? '',
      building: map['building'] ?? '',
      floor: map['floor'] ?? '',
      flat: map['flat'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CheckoutPreferences.fromJson(String source) =>
      CheckoutPreferences.fromMap(json.decode(source));

  bool get isEmpty =>
      city.isEmpty &&
      street.isEmpty &&
      building.isEmpty &&
      floor.isEmpty &&
      flat.isEmpty &&
      notes.isEmpty;
}

// --- Repository ---
// Expose the shared preferences instance via a provider if not already accessible elsewhere
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final checkoutPreferencesRepoProvider = Provider<CheckoutPreferencesRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CheckoutPreferencesRepository(prefs);
});

class CheckoutPreferencesRepository {
  final SharedPreferences _prefs;
  static const String _key = 'checkout_preferences';

  CheckoutPreferencesRepository(this._prefs);

  Future<void> savePreferences(CheckoutPreferences prefs) async {
    await _prefs.setString(_key, prefs.toJson());
  }

  CheckoutPreferences loadPreferences() {
    final data = _prefs.getString(_key);
    if (data != null) {
      try {
        return CheckoutPreferences.fromJson(data);
      } catch (e) {
        // If parsing fails for any reason, return empty
        return const CheckoutPreferences();
      }
    }
    return const CheckoutPreferences();
  }
}

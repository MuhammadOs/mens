import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier-driven suppression flag for the global loading overlay.
/// Using a NotifierProvider avoids API mismatches across Riverpod helper imports.
class OverlaySuppressionNotifier extends Notifier<bool> {
	@override
	bool build() => false;

	void setSuppressed(bool value) => state = value;
}

final overlaySuppressionProvider =
		NotifierProvider<OverlaySuppressionNotifier, bool>(
	OverlaySuppressionNotifier.new,
);

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';

// A simple data class to hold the data for each FAQ item.
class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}

class HelpSupportScreen extends HookConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    // Create a list of FAQ items.
    final faqItems = useMemoized(() => [
          _FaqItem(question: l10n.faqQuestion1, answer: l10n.faqAnswer1),
          _FaqItem(question: l10n.faqQuestion2, answer: l10n.faqAnswer2),
          _FaqItem(question: l10n.faqQuestion3, answer: l10n.faqAnswer3),
          _FaqItem(question: l10n.faqQuestion4, answer: l10n.faqAnswer4),
        ]);

    // ✅ MODIFIED: We now only store the index of the expanded panel.
    // -1 means no panel is expanded.
    final expandedIndex = useState<int>(-1);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.drawerHelpSupport),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // ✅ MODIFIED: Using ExpansionPanelList.radio
        child: ExpansionPanelList.radio(
          elevation: 1,
          dividerColor: theme.dividerColor.withOpacity(0.5),
          expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
          
          // ✅ MODIFIED: Simplified callback logic
          expansionCallback: (int index, bool isExpanded) {
            // If the tapped panel is already open, close it. Otherwise, open the tapped panel.
            expandedIndex.value = isExpanded ? -1 : index;
          },
          
          children: faqItems.map<ExpansionPanelRadio>((_FaqItem item) {
            final index = faqItems.indexOf(item);
            return ExpansionPanelRadio(
              // The value must be unique for each panel. The index is perfect for this.
              value: index,
              backgroundColor: theme.colorScheme.surface,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    item.question,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
                      color: isExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                );
              },
              body: ListTile(
                title: Text(
                  item.answer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              // The 'isExpanded' property is now handled internally by ExpansionPanelList.radio
              // based on whether its 'value' matches the list's state.
              canTapOnHeader: true,
            );
          }).toList(),
        ),
      ),
    );
  }
}
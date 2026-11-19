import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import 'category_dialogs.dart';
import 'people_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final all = ref.watch(categoriesProvider).value ?? const [];
    final system = all.where((c) => c.isSystem).toList();
    final custom = all.where((c) => !c.isSystem).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.manageCategories)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-category'),
        onPressed: () => showCategoryEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.addCategory),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 96),
        children: [
          SectionHeader(l.yourCategories),
          if (custom.isEmpty)
            InlineEmpty(l.noCustomCategories)
          else
            Card(
              child: Column(
                children: [
                  for (final c in custom)
                    ListTile(
                      leading: CircleAvatar(radius: 10, backgroundColor: Color(c.color ?? categoryColors.first)),
                      title: Text(c.label(l)),
                      onTap: () => showCategoryEditor(context, ref, existing: c),
                      trailing: IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final ok = await confirmDialog(context,
                              title: l.confirmDeleteTitle, message: l.deleteCategoryConfirm(c.label(l)));
                          if (ok) await ref.read(categoriesRepositoryProvider).delete(c.id);
                        },
                      ),
                    ),
                ],
              ),
            ),
          SectionHeader(l.builtInCategories),
          Card(
            child: Column(
              children: [
                for (final c in system)
                  ListTile(leading: const Icon(Icons.label_outline), title: Text(c.label(l))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(l.systemCategoriesNote, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

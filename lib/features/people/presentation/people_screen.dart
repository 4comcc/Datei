import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../agenda/agenda.dart';
import '../domain/people_filter.dart';
import 'category_dialogs.dart';
import 'people_filter_sheet.dart';
import 'people_providers.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  late final TextEditingController _search =
      TextEditingController(text: ref.read(peopleFilterProvider).query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _deleteSaved(SavedPeopleFilter s) async {
    final l = context.l10n;
    final ok = await confirmDialog(context, title: l.confirmDeleteTitle, message: l.deleteSavedFilterConfirm(s.name));
    if (ok) await ref.read(savedPeopleFiltersRepositoryProvider).delete(s.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final all = ref.watch(peopleProvider);
    final loaded = ref.watch(peopleStreamProvider).hasValue;
    final filter = ref.watch(peopleFilterProvider);
    final filtered = ref.watch(filteredPeopleProvider);
    final saved = ref.watch(savedPeopleFiltersProvider).value ?? const <SavedPeopleFilter>[];
    final engine = ref.watch(timeEngineProvider);
    final today = ref.watch(todayProvider);
    final controller = ref.read(peopleFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.navPeople)),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : all.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: l.peopleEmptyTitle,
                  body: l.peopleEmptyBody,
                  action: FilledButton.icon(
                    onPressed: () => context.push('/people/new'),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: Text(l.addPerson),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _search,
                              decoration: InputDecoration(
                                hintText: l.searchPeopleHint,
                                prefixIcon: const Icon(Icons.search),
                                isDense: true,
                              ),
                              onChanged: controller.setQuery,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Badge(
                            isLabelVisible: filter.activeCount > 0,
                            label: Text('${filter.activeCount}'),
                            child: IconButton.filledTonal(
                              key: const Key('open-filters'),
                              tooltip: l.filtersActive(filter.activeCount),
                              icon: const Icon(Icons.tune),
                              onPressed: () => showPeopleFilterSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (saved.isNotEmpty || filter.activeCount > 0)
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (filter.activeCount > 0)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8),
                                child: InputChip(
                                  label: Text(l.filtersActive(filter.activeCount)),
                                  onDeleted: controller.clearCriteria,
                                  onPressed: () => showPeopleFilterSheet(context),
                                ),
                              ),
                            for (final s in saved)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8),
                                child: GestureDetector(
                                  onLongPress: () => _deleteSaved(s),
                                  child: ActionChip(
                                    avatar: const Icon(Icons.bookmark_outline, size: 18),
                                    label: Text(s.name),
                                    onPressed: () =>
                                        controller.set(s.filter.copyWith(query: filter.query)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (!filter.isEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(l.resultsCount(filtered.length),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ),
                      ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text(l.noResults))
                          : ListView.separated(
                              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final p = filtered[i];
                                final birth = p.birthDate;
                                final withYear = p.birthDateWithYear;
                                final subtitle = <String>[
                                  if (withYear != null) l.ageYears(engine.ageOn(withYear, today)?.years ?? 0),
                                  if (birth != null)
                                    l.relativeDays(today.daysUntil(engine.nextBirthday(birth, today)))
                                  else
                                    l.noBirthDate,
                                ];
                                return Card(
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    leading: PersonAvatar(p.shownName),
                                    title: Text(p.shownName),
                                    subtitle: Text(subtitle.join(' · ')),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => context.push('/people/${p.id}'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

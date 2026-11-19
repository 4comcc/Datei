import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/l10n_labels.dart';
import '../../../shared/widgets/common.dart';
import '../../agenda/agenda.dart';
import '../data/people_repository.dart';
import '../domain/person.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  String _query = '';
  PersonCategory? _category;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final people = ref.watch(peopleProvider);
    final engine = ref.watch(timeEngineProvider);
    final today = ref.watch(todayProvider);
    final q = _query.trim().toLowerCase();
    final filtered = people.where((p) {
      if (_category != null && !p.categories.contains(_category)) return false;
      if (q.isEmpty) return true;
      return p.fullName.toLowerCase().contains(q) ||
          (p.displayName?.toLowerCase().contains(q) ?? false) ||
          (p.occupation?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.navPeople)),
      body: people.isEmpty
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
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l.searchPeopleHint,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(l.filterAll),
                          selected: _category == null,
                          onSelected: (_) => setState(() => _category = null),
                        ),
                      ),
                      for (final c in PersonCategory.values)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(c.label(l)),
                            selected: _category == c,
                            onSelected: (_) => setState(() => _category = _category == c ? null : c),
                          ),
                        ),
                    ],
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
                            final subtitle = <String>[
                              if (birth != null) ...[
                                l.ageYears(engine.ageOn(birth, today)?.years ?? 0),
                                l.relativeDays(today.daysUntil(engine.nextBirthday(birth, today))),
                              ] else
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

import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../job_request/domain/models/job_request_model.dart';
import '../../../job_request/data/repositories/firebase_job_repository_impl.dart';

class FindStudentsScreen extends StatefulWidget {
  const FindStudentsScreen({super.key});

  @override
  State<FindStudentsScreen> createState() => _FindStudentsScreenState();
}

class _FindStudentsScreenState extends State<FindStudentsScreen> {
  final _repository = FirebaseJobRepositoryImpl();
  
  LocationSelection _location = const LocationSelection(province: '', district: '', area: '');
  String? _selectedSubject;
  int? _minBudget;

  final List<String> _availableSubjects = [
    'Social',
    'Nepali',
    'English',
    'Math',
    'Science',
    'Health',
  ];

  void _showFilterBottomSheet(BuildContext context) {
    LocationSelection tempLocation = _location;
    String? tempSubject = _selectedSubject;
    TextEditingController tempBudgetController = TextEditingController(text: _minBudget?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Filter Requests',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    DynamicLocationSelector(
                      value: tempLocation,
                      onChanged: (v) => setStateSB(() => tempLocation = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    Text('Subject Category', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _availableSubjects.map((subject) {
                        final isSelected = tempSubject == subject;
                        return ChoiceChip(
                          label: Text(subject),
                          selected: isSelected,
                          onSelected: (selected) {
                            setStateSB(() {
                              tempSubject = selected ? subject : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      label: 'Minimum Budget (NPR)',
                      hint: 'e.g. 4000',
                      controller: tempBudgetController,
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Clear',
                            isSecondary: true,
                            onPressed: () {
                              setState(() {
                                _location = const LocationSelection(province: '', district: '', area: '');
                                _selectedSubject = null;
                                _minBudget = null;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'Apply Filters',
                            onPressed: () {
                              setState(() {
                                _location = tempLocation;
                                _selectedSubject = tempSubject;
                                _minBudget = int.tryParse(tempBudgetController.text);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Students'),
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: StreamBuilder<List<JobRequestModel>>(
        stream: _repository.getOpenJobsStream(
          district: _location.district.isNotEmpty ? _location.district : null,
          subject: _selectedSubject,
          minBudget: _minBudget,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading requests.\n${snapshot.error}', textAlign: TextAlign.center));
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No requests found matching your filters.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              return _StudentRequestCard(job: jobs[index]);
            },
          );
        },
      ),
    );
  }
}

class _StudentRequestCard extends StatelessWidget {
  final JobRequestModel job;

  const _StudentRequestCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.large))),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.subjects.isNotEmpty ? job.subjects.join(', ') : 'General Subjects',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    job.grade,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(icon: Icons.location_on_outlined, text: '${job.district} - ${job.area}'),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(icon: Icons.account_balance_wallet_outlined, text: 'Rs. ${job.budgetNpr} / month'),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Interest expressed successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.large)),
                ),
                child: const Text('Express Interest'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

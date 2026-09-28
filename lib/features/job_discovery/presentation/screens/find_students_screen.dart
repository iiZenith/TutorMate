import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../../../shared/widgets/dynamic_subject_selector.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../job_request/domain/models/job_request_model.dart';
import '../../../job_request/domain/models/tutor_interest_model.dart';
import '../../../job_request/data/repositories/firebase_job_repository_impl.dart';
import '../../../../app/app.dart';

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
                    DynamicSubjectSelector(
                      selectedSubjects: tempSubject != null ? [tempSubject!] : [],
                      multiSelect: false,
                      onChanged: (subjects) {
                        setStateSB(() {
                          tempSubject = subjects.isNotEmpty ? subjects.first : null;
                        });
                      },
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
    final user = AuthProviderInherited.of(context).user;

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
      body: StreamBuilder<List<TutorInterestModel>>(
        stream: user != null ? _repository.getMyInterestsStream(user.id) : const Stream.empty(),
        builder: (context, interestsSnapshot) {
          final appliedJobIds = (interestsSnapshot.data ?? []).map((i) => i.jobId).toSet();

          return StreamBuilder<List<JobRequestModel>>(
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Error loading requests.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final jobs = snapshot.data ?? [];

              if (jobs.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
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
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _StudentRequestCard(
                      job: job,
                      isApplied: appliedJobIds.contains(job.jobId),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StudentRequestCard extends StatefulWidget {
  final JobRequestModel job;
  final bool isApplied;

  const _StudentRequestCard({
    required this.job,
    this.isApplied = false,
  });

  @override
  State<_StudentRequestCard> createState() => _StudentRequestCardState();
}

class _StudentRequestCardState extends State<_StudentRequestCard> {
  bool _isLoading = false;

  void _expressInterest() async {
    final user = AuthProviderInherited.of(context).user;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    try {
      await FirebaseJobRepositoryImpl().expressInterest(
        jobId: widget.job.jobId, 
        tutorId: user.id, 
        tutorName: user.fullName
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interest expressed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                    widget.job.subjects.isNotEmpty ? widget.job.subjects.join(', ') : 'General Subjects',
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
                    widget.job.grade,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(icon: Icons.location_on_outlined, text: '${widget.job.district} - ${widget.job.area}'),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(icon: Icons.account_balance_wallet_outlined, text: 'Rs. ${widget.job.budgetNpr} / month'),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: widget.isApplied
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      label: const Text('Interest Expressed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    )
                  : ElevatedButton(
                      onPressed: _isLoading ? null : _expressInterest,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.large)),
                      ),
                      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Express Interest'),
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

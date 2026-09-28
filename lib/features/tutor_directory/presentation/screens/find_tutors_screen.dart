import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/dynamic_location_selector.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/models/tutor_model.dart';
import '../../data/repositories/firebase_tutor_repository_impl.dart';

class FindTutorsScreen extends StatefulWidget {
  const FindTutorsScreen({super.key});

  @override
  State<FindTutorsScreen> createState() => _FindTutorsScreenState();
}

class _FindTutorsScreenState extends State<FindTutorsScreen> {
  final _repository = FirebaseTutorRepositoryImpl();
  
  LocationSelection _location = const LocationSelection(province: '', district: '', area: '');
  String? _selectedSubject;
  int? _maxSalary;

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
    TextEditingController tempBudgetController = TextEditingController(text: _maxSalary?.toString() ?? '');

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
                      'Filter Tutors',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    DynamicLocationSelector(
                      value: tempLocation,
                      onChanged: (v) => setStateSB(() => tempLocation = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    Text('Subject', style: theme.textTheme.labelLarge),
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
                      label: 'Maximum Budget (NPR)',
                      hint: 'e.g. 5000',
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
                                _maxSalary = null;
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
                                _maxSalary = int.tryParse(tempBudgetController.text);
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
        title: const Text('Browse Tutors'),
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: StreamBuilder<List<TutorModel>>(
        stream: _repository.getTutorsStream(
          district: _location.district.isNotEmpty ? _location.district : null,
          subject: _selectedSubject,
          maxSalary: _maxSalary,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tutors.\n${snapshot.error}', textAlign: TextAlign.center));
          }

          final tutors = snapshot.data ?? [];

          if (tutors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No tutors found matching your filters.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              return _TutorProfileCard(tutor: tutors[index]);
            },
          );
        },
      ),
    );
  }
}

class _TutorProfileCard extends StatelessWidget {
  final TutorModel tutor;

  const _TutorProfileCard({required this.tutor});

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
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    tutor.fullName.isNotEmpty ? tutor.fullName[0].toUpperCase() : 'T',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tutor.district,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            Text(
              'Subjects: ${tutor.subjects.isNotEmpty ? tutor.subjects.join(', ') : 'Not specified'}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expected Monthly Rate: Rs. ${tutor.expectedMonthlyRate > 0 ? tutor.expectedMonthlyRate : '-'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push('/hire-tutor');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.large)),
                  ),
                  child: const Text('Hire Tutor'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

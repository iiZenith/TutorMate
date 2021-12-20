import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../domain/models/job_request_model.dart';
import '../../domain/models/tutor_interest_model.dart';
import '../../data/repositories/firebase_job_repository_impl.dart';

class RequestDetailsScreen extends StatefulWidget {
  final JobRequestModel job;

  const RequestDetailsScreen({super.key, required this.job});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final _repository = FirebaseJobRepositoryImpl();

  void _acceptInterest(String interestId) async {
    try {
      await _repository.acceptInterest(widget.job.jobId, interestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor accepted!')));
        context.pop(); // Go back after accepting
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to accept: $e')));
      }
    }
  }

  void _rejectInterest(String interestId) async {
    try {
      await _repository.rejectInterest(interestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor rejected.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reject: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusLarge),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.subjects.join(', '),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Status: ${widget.job.status.toUpperCase()}'),
                    const SizedBox(height: AppSpacing.md),
                    Text('Grade: ${widget.job.grade}'),
                    Text('Location: ${widget.job.district} - ${widget.job.area}'),
                    Text('Budget: Rs. ${widget.job.budgetNpr} / month'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Interested Tutors', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<List<TutorInterestModel>>(
              stream: _repository.getInterestsForJob(widget.job.jobId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading interests.', style: TextStyle(color: theme.colorScheme.error)));
                }

                final interests = snapshot.data ?? [];
                if (interests.isEmpty) {
                  return const Center(child: Text('No tutors have expressed interest yet.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    final interest = interests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                        title: Text(interest.tutorName),
                        subtitle: Text('Status: ${interest.status}'),
                        trailing: interest.status == 'submitted' && widget.job.status == 'open'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _acceptInterest(interest.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _rejectInterest(interest.id),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

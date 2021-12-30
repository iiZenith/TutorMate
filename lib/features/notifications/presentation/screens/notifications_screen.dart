import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../domain/models/notification_model.dart';
import '../../data/repositories/firebase_notification_repository_impl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = FirebaseNotificationRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthProviderInherited.of(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Authentication required')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _repository.getUserNotificationsStream(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
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
                        Icon(Icons.notifications_off_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No notifications yet.',
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  elevation: notif.isRead ? 1 : 3,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusLarge),
                  color: notif.isRead ? theme.colorScheme.surface : theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                  child: ListTile(
                    leading: Icon(
                      notif.isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: notif.isRead ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.primary,
                    ),
                    title: Text(
                      notif.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notif.body),
                    trailing: Text(
                      '${notif.createdAt.day}/${notif.createdAt.month}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                    onTap: () {
                      if (!notif.isRead) {
                        _repository.markAsRead(notif.id);
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

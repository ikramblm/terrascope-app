import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'ad_service.dart';

/// "Privacy & ad choices" — only appears where Google's consent rules
/// require an always-available way to change the ad consent choice
/// (EEA, UK and similar). Everywhere else it takes no space.
class PrivacyChoicesCard extends StatelessWidget {
  const PrivacyChoicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: AdService.instance.privacyOptionsRequired,
      builder: (context, required, _) {
        if (!required) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: AdService.instance.showPrivacyOptions,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.privacy_tip_rounded,
                        color: AppColors.skyBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy & ad choices',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Change your ad consent',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

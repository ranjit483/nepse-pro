import 'package:flutter/material.dart';
import '../theme.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  
  const LegalScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Generate boilerplate content based on title
    final isPrivacy = title.contains('Privacy');
    final content = isPrivacy ? _privacyPolicyText : _termsOfServiceText;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        foregroundColor: AppTheme.onSurface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.outlineVariant.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  static const _termsOfServiceText = '''
Terms of Service

Last updated: May 26, 2026

1. Acceptance of Terms
By accessing and using the NEPSE Pro application, you accept and agree to be bound by the terms and provision of this agreement.

2. User Registration
To use certain features of the app, you may be required to register. You agree to provide accurate and complete information and keep it updated.

3. Privacy and Data
Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information. By using the app, you agree to our Privacy Policy.

4. User Conduct
You agree not to use the application for any unlawful purpose or in any way that might harm, damage, or disparage any other party.

5. Intellectual Property
All content included in the app, such as text, graphics, logos, images, and software, is the property of NEPSE Pro or its content suppliers and protected by international copyright laws.

6. Limitation of Liability
NEPSE Pro shall not be liable for any direct, indirect, incidental, special, or consequential damages resulting from the use or inability to use the application.

7. Modifications to Terms
We reserve the right to modify these terms at any time. Your continued use of the application following the posting of changes will mean you accept those changes.
''';

  static const _privacyPolicyText = '''
Privacy Policy

Last updated: May 26, 2026

1. Information We Collect
We collect information you provide directly to us, such as when you create or modify your account, or interact with the app. This may include your name, email address, and portfolio data.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services. We may also use the information to communicate with you, such as to send you updates or respond to your inquiries.

3. Sharing of Information
We do not share your personal information with third parties except as described in this privacy policy or with your consent. We may share information with vendors, consultants, and other service providers who need access to such information to carry out work on our behalf.

4. Data Security
We take reasonable measures to help protect your information from loss, theft, misuse, and unauthorized access, disclosure, alteration, and destruction. We use industry-standard encryption for data storage.

5. Data Retention
We retain your personal information for as long as necessary to provide you with our services and as described in our privacy policy.

6. Your Rights
You have the right to access, correct, or delete your personal information. You can do this by managing your account settings or contacting us directly.

7. Changes to Privacy Policy
We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page.
''';
}

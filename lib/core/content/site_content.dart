class LegalDocument {
  const LegalDocument({
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.effectiveDate,
    required this.lastUpdated,
    required this.sections,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final String effectiveDate;
  final String lastUpdated;
  final List<LegalSection> sections;
}

class LegalSection {
  const LegalSection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

abstract final class SiteContent {
  static const supportEmail = 'support@groome.net';
  static const supportEmailUrl = 'mailto:support@groome.net';
  static const phone = '+91 98765 43210';
  static const phoneUrl = 'tel:+919876543210';
  static const website = 'groome.net';

  // Edit these dummy social handles and URLs before launch.
  static const instagramHandle = '@groome.in';
  static const instagramUrl = 'https://www.instagram.com/joingroome?utm_source=qr';
  static const linkedInHandle = 'Groome';
  static const linkedInUrl = 'https://www.linkedin.com/company/groome-app';
  static const youtubeHandle = '@groome';
  static const youtubeUrl = 'https://www.youtube.com/@groome';
  static const xHandle = '@groome_app';
  static const xUrl = 'https://x.com/groome_app';

  static const footerSummary =
      'Groome helps salon owners bring bookings, customers, reminders, and daily business visibility into one calm digital workspace.';

  static const footerHighlights = [
    'Online booking for salon teams',
    'Secure lead handling',
    'Built for better salon days',
  ];
}

abstract final class LegalDocuments {
  static const privacyPolicy = LegalDocument(
    eyebrow: 'Policy',
    title: 'Privacy Policy',
    effectiveDate: '22 June 2026',
    lastUpdated: '22 June 2026',
    summary:
        'Groome is committed to protecting your privacy. This policy explains how we collect, use, share, and protect information when you use our website, mobile application, and platform.',
    sections: [
      LegalSection(
        title: '1. Information We Collect',
        paragraphs: [
          'We collect information you provide directly, information collected automatically when you use the Platform, and limited information from trusted third parties.',
        ],
        bullets: [
          'Name and phone number when you create an account or make a booking.',
          'Email address if provided during registration or contact.',
          'Salon details including name, address, services, pricing, and team information if you register as a salon partner.',
          'Booking details including service selected, stylist preference, date, and time.',
          'Communications you send us through support channels.',
          'Device information, usage data, permitted location data, IP address, access times, and referring URLs.',
          'WhatsApp Business API data for booking confirmations and reminders.',
          'Payment information processed through third-party payment providers. We do not store full payment details.',
        ],
      ),
      LegalSection(
        title: '2. How We Use Your Information',
        paragraphs: [
          'We use the information we collect to operate, improve, secure, and support Groome.',
        ],
        bullets: [
          'Create and manage your account on the Platform.',
          'Process and confirm bookings between customers and salon partners.',
          'Send booking confirmations, reminders, and updates via WhatsApp and SMS.',
          'Enable salon partners to manage appointments, customers, and business analytics.',
          'Improve and personalise your experience on the Platform.',
          'Communicate with you about your account, bookings, or support requests.',
          'Analyse usage patterns to improve the Platform and develop new features.',
          'Ensure the security and integrity of the Platform and comply with applicable laws.',
        ],
      ),
      LegalSection(
        title: '3. How We Share Your Information',
        paragraphs: [
          'We do not sell your personal information. We may share your information only in limited circumstances.',
          'When you make a booking, we share your name and phone number with the relevant salon partner so they can confirm and manage your appointment.',
          'We work with trusted service providers for cloud hosting, messaging, analytics, and similar services. These providers are expected to protect your information and use it only for the services they provide to us.',
          'We may disclose information if required by law, regulation, or legal process, or if necessary to protect Groome, our users, or others.',
          'If Groome is involved in a merger, acquisition, or sale of assets, your information may be transferred as part of that transaction.',
        ],
      ),
      LegalSection(
        title: '4. Data Retention',
        paragraphs: [
          'We retain personal information for as long as necessary to provide our services and fulfil the purposes described in this Policy.',
        ],
        bullets: [
          'Account information is retained as long as your account is active.',
          'Booking history is retained for 3 years to allow salons and customers to reference past visits.',
          'Support communications are retained for 1 year.',
          'You may request deletion of your account and associated data at any time by contacting support@groome.net.',
        ],
      ),
      LegalSection(
        title: '5. Data Security',
        paragraphs: [
          'We implement appropriate technical and organisational measures to protect information against unauthorised access, alteration, disclosure, or destruction.',
          'No method of transmission over the internet or electronic storage is completely secure. While we use commercially acceptable means to protect your information, we cannot guarantee absolute security.',
        ],
        bullets: [
          'Encrypted data transmission using HTTPS.',
          'Secure cloud infrastructure with access controls.',
          'Limited access to personal data on a need-to-know basis.',
          'Regular security reviews of our systems and processes.',
        ],
      ),
      LegalSection(
        title: '6. Your Rights and Choices',
        paragraphs: [
          'You may contact us to exercise rights over your personal information. We will respond to requests within 30 days.',
        ],
        bullets: [
          'Access: request a copy of the personal information we hold about you.',
          'Correction: request correction of inaccurate or incomplete information.',
          'Deletion: request deletion of your personal information, subject to legal obligations.',
          'Objection: object to certain uses of your information.',
          'Portability: request your data in a structured, machine-readable format.',
        ],
      ),
      LegalSection(
        title: '7. Cookies and Tracking',
        paragraphs: [
          'Our Platform may use cookies and similar tracking technologies to enhance your experience and analyse usage. You can control cookies through your browser settings, although disabling cookies may affect some features.',
          'We use analytics tools to understand how users interact with the Platform. This data is aggregated and anonymised where possible.',
        ],
      ),
      LegalSection(
        title: "8. Children's Privacy",
        paragraphs: [
          'Groome is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that we have collected such information without parental consent, we will take steps to delete it promptly.',
        ],
      ),
      LegalSection(
        title: '9. Third-Party Links',
        paragraphs: [
          'Our Platform may contain links to third-party websites or services. We are not responsible for the privacy practices of those third parties. Please review their privacy policies before providing personal information.',
        ],
      ),
      LegalSection(
        title: '10. WhatsApp Communications',
        paragraphs: [
          'By providing your phone number and making a booking on Groome, you consent to receive booking confirmations, appointment reminders, and service updates via WhatsApp. These messages are transactional and essential to the booking service.',
          'You may opt out of WhatsApp communications by replying STOP to any message or by contacting support@groome.net. Opting out may affect your ability to receive booking confirmations.',
        ],
      ),
      LegalSection(
        title: '11. Changes to This Policy',
        paragraphs: [
          'We may update this Privacy Policy from time to time for legal, regulatory, operational, or product reasons. We will post the updated Policy on our Platform with a revised effective date.',
          'Your continued use of the Platform after changes are posted constitutes acceptance of the updated Policy.',
        ],
      ),
      LegalSection(
        title: '12. Governing Law',
        paragraphs: [
          'This Privacy Policy is governed by the laws of India. Any disputes arising from this Policy shall be subject to the jurisdiction of courts in New Delhi, India.',
        ],
      ),
      LegalSection(
        title: '13. Contact Us',
        paragraphs: [
          'If you have questions, concerns, or requests regarding this Privacy Policy or how we handle personal information, contact Groome at support@groome.net or visit groome.net.',
        ],
      ),
    ],
  );

  static const termsConditions = LegalDocument(
    eyebrow: 'Policy',
    title: 'Terms & Conditions',
    effectiveDate: '22 June 2026',
    lastUpdated: '22 June 2026',
    summary:
        'These Terms explain the rules for using Groome, including our website, mobile application, booking tools, salon partner features, and related services.',
    sections: [
      LegalSection(
        title: '1. Acceptance of Terms',
        paragraphs: [
          'By accessing or using Groome, you agree to these Terms & Conditions. If you do not agree, please do not use the Platform.',
          'Groome may update these Terms from time to time. Continued use of the Platform after changes are posted means you accept the updated Terms.',
        ],
      ),
      LegalSection(
        title: '2. About Groome',
        paragraphs: [
          'Groome provides digital tools for salon discovery, appointment booking, customer management, reminders, and business operations. Some services are used by customers, and some are used by salon partners.',
          'Groome is a technology platform. Salon services are provided by independent salon partners, not by Groome directly.',
        ],
      ),
      LegalSection(
        title: '3. Accounts and Information',
        bullets: [
          'You must provide accurate and current information when creating an account, making a booking, or contacting us.',
          'You are responsible for keeping account access secure and for activity under your account.',
          'We may suspend or restrict access if information is inaccurate, misuse is detected, or these Terms are violated.',
        ],
      ),
      LegalSection(
        title: '4. Bookings and Salon Services',
        paragraphs: [
          'Bookings made through Groome are subject to salon availability, service duration, pricing, and partner policies shown at the time of booking.',
          'Salon partners are responsible for delivering their listed services, maintaining accurate availability, and handling customer service matters related to appointments.',
        ],
      ),
      LegalSection(
        title: '5. Payments, Cancellations, and Refunds',
        paragraphs: [
          'Where payments are available through the Platform, payment processing may be handled by third-party providers. Groome does not store full payment details.',
          'Cancellation, rescheduling, refund, and no-show policies may vary by salon partner and will apply as communicated during booking or by the relevant salon.',
        ],
      ),
      LegalSection(
        title: '6. Salon Partner Responsibilities',
        bullets: [
          'Keep salon details, services, pricing, team information, and availability accurate.',
          'Use customer data only to provide booked services and related support.',
          'Comply with applicable business, tax, consumer protection, privacy, and safety laws.',
          'Avoid misleading listings, spam, abusive behaviour, or unauthorised use of customer information.',
        ],
      ),
      LegalSection(
        title: '7. WhatsApp, SMS, and Email Communications',
        paragraphs: [
          'By providing contact details, you agree to receive transactional messages such as booking confirmations, reminders, service updates, support replies, and account-related notices.',
          'Marketing messages, if any, will be sent only where permitted by law and may include opt-out instructions.',
        ],
      ),
      LegalSection(
        title: '8. Acceptable Use',
        bullets: [
          'Do not use Groome for unlawful, fraudulent, harmful, or abusive activity.',
          'Do not interfere with Platform security, availability, or performance.',
          'Do not scrape, copy, reverse engineer, or misuse Platform data except as allowed by law.',
          'Do not upload malicious code, spam, false content, or content that infringes others rights.',
        ],
      ),
      LegalSection(
        title: '9. Intellectual Property',
        paragraphs: [
          'Groome, its branding, website, app design, software, text, graphics, and related materials are owned by Groome or its licensors. You may not copy, modify, distribute, or create derivative works without permission.',
          'Salon partners retain ownership of their business content but grant Groome permission to display and use that content to operate and promote the Platform.',
        ],
      ),
      LegalSection(
        title: '10. Third-Party Services',
        paragraphs: [
          'The Platform may connect with third-party services such as payment processors, maps, analytics, cloud infrastructure, and messaging tools. Those services are governed by their own terms and policies.',
        ],
      ),
      LegalSection(
        title: '11. Availability and Changes',
        paragraphs: [
          'We aim to keep Groome reliable, but we do not guarantee uninterrupted or error-free access. Features may be updated, suspended, or discontinued as the Platform evolves.',
        ],
      ),
      LegalSection(
        title: '12. Limitation of Liability',
        paragraphs: [
          'To the maximum extent permitted by law, Groome will not be liable for indirect, incidental, special, consequential, or punitive damages arising from use of the Platform.',
          'Groome is not responsible for the quality, safety, timing, pricing, or fulfilment of salon services provided by independent salon partners.',
        ],
      ),
      LegalSection(
        title: '13. Termination',
        paragraphs: [
          'We may suspend or terminate access to Groome if you violate these Terms, create risk for other users, misuse the Platform, or if required by law.',
        ],
      ),
      LegalSection(
        title: '14. Governing Law',
        paragraphs: [
          'These Terms are governed by the laws of India. Any disputes arising from these Terms shall be subject to the jurisdiction of courts in New Delhi, India.',
        ],
      ),
      LegalSection(
        title: '15. Contact Us',
        paragraphs: [
          'For questions about these Terms, contact Groome at support@groome.net or visit groome.net.',
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {'q': 'How do I track my shipment?', 'a': 'Go to Home, enter your tracking ID in the search bar, and tap Track. You will see the live status and location of your package.'},
    {'q': 'How is the shipping cost calculated?', 'a': 'Cost is based on package weight and delivery type. Standard starts at ৳80 + ৳50/kg. Express starts at ৳150 + ৳50/kg.'},
    {'q': 'What package types are accepted?', 'a': 'We accept Documents, Parcels, Fragile items, and Electronics. Select the correct type when creating a shipment.'},
    {'q': 'How long does delivery take?', 'a': 'Standard delivery takes 3–5 business days. Express delivery takes 1–2 business days.'},
    {'q': 'Can I cancel a shipment?', 'a': 'You can cancel a shipment only if it has not been picked up yet. Contact support immediately if you need to cancel.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('How can we help?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              SizedBox(height: 4),
              Text('Browse FAQs or contact our support team',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 24),

          // FAQs
          const Text('Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...(_faqs.map((faq) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ExpansionTile(
              title: Text(faq['q']!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(faq['a']!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                ),
              ],
            ),
          ))),

          const SizedBox(height: 24),

          // Contact
          const Text('Contact Us',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _contactTile(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@shiptrack.app',
            onTap: () => launchUrl(Uri.parse('mailto:support@shiptrack.app')),
          ),
          const SizedBox(height: 8),
          _contactTile(
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: '+880 1700-000000',
            onTap: () => launchUrl(Uri.parse('tel:+8801700000000')),
          ),
          const SizedBox(height: 8),
          _contactTile(
            icon: Icons.chat_outlined,
            title: 'Live Chat',
            subtitle: 'Available 9AM – 6PM',
            onTap: () {},
          ),
        ]),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}
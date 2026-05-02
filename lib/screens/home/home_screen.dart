import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/shipment_model.dart';
import '../../utils/constants.dart';
import 'create_shipment_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _firestoreService = FirestoreService();
  final _trackingCtrl = TextEditingController();

  @override
  void dispose() {
    _trackingCtrl.dispose();
    super.dispose();
  }

  void _goToTracking(String trackingId) {
    if (trackingId.trim().isEmpty) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TrackingScreen(trackingId: trackingId.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final uid = authProvider.firebaseUser?.uid ?? '';
    final userName = authProvider.userModel?.name ?? 'there';

    final pages = [
      _buildDashboard(uid, userName),
      CreateShipmentScreen(userId: uid),
      HistoryScreen(userId: uid),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box), label: 'Ship'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboard(String uid, String userName) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryBlue,
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good day, $userName 👋',
                        style: const TextStyle(color: Color(0xFFB5D4F4), fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Your shipments at a glance',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // Tracking search bar
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _trackingCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter tracking ID…',
                            hintStyle: const TextStyle(color: Color(0x88FFFFFF)),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: _goToTracking,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _goToTracking(_trackingCtrl.text),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.search, color: Colors.white, size: 20),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: StreamBuilder<List<ShipmentModel>>(
                stream: _firestoreService.getUserShipments(uid),
                builder: (context, snap) {
                  final shipments = snap.data ?? [];
                  final active = shipments.where((s) => s.status != 'Delivered').length;
                  final delivered = shipments.where((s) => s.status == 'Delivered').length;

                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      _statCard('Active', active.toString(), AppColors.lightBlue, AppColors.primaryBlue),
                      const SizedBox(width: 12),
                      _statCard('Delivered', delivered.toString(), const Color(0xFFEAF3DE), AppColors.green),
                    ]),
                    const SizedBox(height: 24),
                    const Text('Recent Shipments',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (shipments.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Column(children: [
                            Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary),
                            SizedBox(height: 8),
                            Text('No shipments yet', style: TextStyle(color: AppColors.textSecondary)),
                          ]),
                        ),
                      )
                    else
                      ...shipments.take(5).map((s) => _shipmentTile(s)),
                  ]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color bg, Color fg) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: fg)),
        Text(label, style: TextStyle(fontSize: 13, color: fg)),
      ]),
    ),
  );

  Widget _shipmentTile(ShipmentModel s) {
    Color badgeColor; Color textColor;
    switch (s.status) {
      case 'Delivered': badgeColor = const Color(0xFFEAF3DE); textColor = AppColors.green; break;
      case 'In Transit': badgeColor = AppColors.lightAmber; textColor = AppColors.amber; break;
      default: badgeColor = AppColors.lightBlue; textColor = AppColors.primaryBlue;
    }
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => TrackingScreen(trackingId: s.trackingId),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.trackingId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(s.packageType, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
            child: Text(s.status, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }
}
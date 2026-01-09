import 'package:flutter/material.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/models/app_user.dart';
import 'package:travel_planner/models/destination.dart';
import 'package:travel_planner/repositories/admin_repository.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_planner/features/auth/ui/login_screen.dart';
import 'package:travel_planner/core/config.dart';
import 'dart:ui';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminRepository _adminRepository = AdminRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: _adminRepository.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          
          return Column(
            children: [
              _buildHeader(users.length),
              Expanded(
                child: users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return FadeInUp(
                            delay: Duration(milliseconds: 100 * index),
                            child: _buildUserCard(users[index]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.person_add, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Registered Users',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
            ),
            child: Text(
              '$count Users',
              style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                backgroundImage: NetworkImage(user.photoUrl ?? AppConfig.defaultProfilePic),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () => _showUserDialog(user: user),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirmation(user.uid),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetails(AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDetailsView(user: user, repository: _adminRepository),
    );
  }

  void _showUserDialog({AppUser? user}) {
    final nameController = TextEditingController(text: user?.displayName);
    final emailController = TextEditingController(text: user?.email);
    final photoController = TextEditingController(text: user?.photoUrl);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: user == null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: photoController,
              decoration: const InputDecoration(labelText: 'Photo URL'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (user == null) {
                final newUser = AppUser(
                  uid: DateTime.now().millisecondsSinceEpoch.toString(), // Simplified for POC
                  email: emailController.text,
                  displayName: nameController.text,
                  photoUrl: photoController.text.isEmpty ? null : photoController.text,
                  createdAt: DateTime.now(),
                );
                await _adminRepository.createUser(newUser);
              } else {
                final updatedUser = user.copyWith(
                  displayName: nameController.text,
                  photoUrl: photoController.text.isEmpty ? null : photoController.text,
                );
                await _adminRepository.updateUser(updatedUser);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: Text(user == null ? 'Add' : 'Update', style: const TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user? This action is irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _adminRepository.deleteUser(uid);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Logout'),
        content: const Text('Do you want to logout from admin panel?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: const Text('Logout', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }
}

class _UserDetailsView extends StatelessWidget {
  final AppUser user;
  final AdminRepository repository;

  const _UserDetailsView({required this.user, required this.repository});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileHeader(),
                const SizedBox(height: 32),
                _buildSectionHeader('Favorites', Icons.favorite),
                _buildFavoritesList(),
                const SizedBox(height: 32),
                _buildSectionHeader('Bookings', Icons.book_online),
                _buildBookingsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.accentColor.withOpacity(0.2),
          backgroundImage: NetworkImage(user.photoUrl ?? AppConfig.defaultProfilePic),
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'No Name',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          user.email,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 16),
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'UID: ${user.uid}',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildFavoritesList() {
    return StreamBuilder<List<Destination>>(
      stream: repository.getUserFavoritesStream(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return _buildEmptyState('No favorites found');
        return Column(
          children: items.map((item) => _buildItemCard(context, item, isFavorite: true)).toList(),
        );
      },
    );
  }

  Widget _buildBookingsList() {
    return StreamBuilder<List<Destination>>(
      stream: repository.getUserBookingsStream(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return _buildEmptyState('No bookings found');
        return Column(
          children: items.map((item) => _buildItemCard(context, item, isFavorite: false)).toList(),
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, Destination item, {required bool isFavorite}) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(item.location, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmRemove(context, item, isFavorite),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.2))),
      ),
    );
  }

  void _confirmRemove(BuildContext context, Destination item, bool isFavorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        title: Text('Remove ${isFavorite ? 'Favorite' : 'Booking'}'),
        content: Text('Are you sure you want to remove ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (isFavorite) {
                await repository.removeUserFavorite(user.uid, item.id);
              } else {
                await repository.removeUserBooking(user.uid, item.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

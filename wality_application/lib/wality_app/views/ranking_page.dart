// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/custom_dropdown.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:flutter/src/widgets/async.dart' as flutter_async;
import 'package:wality_application/wality_app/utils/navigator_utils.dart';

final App app = App(AppConfiguration('wality-1-djgtexn'));
String imgURL = "";

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  Future<String?> usernameFuture = Future.value(null);
  Future<String?> userImage = Future.value(null);
  String _selectedFilter = 'All Time';
  List<dynamic> _users = [];
  bool _isLoading = true;

  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();

  String? currentUserId;

  @override
  void initState() {
    super.initState();

    // Set the currentUserId from the realm service
    currentUserId = _realmService.getCurrentUserId();
    _loadUsers(); // Load users for the current user

    if (currentUserId != null) {
      usernameFuture =
          _userService.fetchUsername(currentUserId!); // Fetch username
      _userService.fetchUserImage(currentUserId!).then((value) {
        setState(() {
          imgURL = value!;
        });
      });
    }
  }

  String getBottleKey() {
    switch (_selectedFilter) {
      case 'Today':
        return 'dayBot';
      case 'This Month':
        return 'monthBot';
      case 'This Year':
        return 'yearBot';
      default:
        return 'botLiv'; // Default to 'All Time'
    }
  }

  Future<void> _loadUsers() async {
    if (currentUserId == null) {
      LogOutToOutsite(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.fetchUsers();
      List<dynamic> filteredUsers;

      // Adjusted filter logic based on simple values without date logic
      if (_selectedFilter == 'Today') {
        filteredUsers = users.where((user) => user['dayBot'] > 0).toList();
      } else if (_selectedFilter == 'This Month') {
        filteredUsers = users.where((user) => user['monthBot'] > 0).toList();
      } else if (_selectedFilter == 'This Year') {
        filteredUsers = users.where((user) => user['yearBot'] > 0).toList();
      } else {
        // All Time
        filteredUsers = users.where((user) => user['botLiv'] > 0).toList();
      }

      setState(() {
        final bottleKey =
            getBottleKey(); // Get the correct key based on the filter
        _users = filteredUsers
          ..sort((a, b) => b[bottleKey].compareTo(a[bottleKey]));

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        throw Exception("Error loading users: $e");
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If the userId changes (like after a login/logout), reload the users
    final newUserId = _realmService.getCurrentUserId();
    if (currentUserId != newUserId) {
      setState(() {
        currentUserId = newUserId;
      });
      _loadUsers(); // Re-load the users for the new user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0083AB), Color(0xFF003545)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildFilterDropdown(),
              if (!_isLoading && _users.isNotEmpty) _buildUserRank(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                        ? const Center(
                            child: Text('No users found',
                                style: TextStyle(color: Colors.white)))
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) =>
                                _buildRankItem(index + 1, _users[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => GoBack(context),
          ),
          const Expanded(
            child: Text(
              'Ranking',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoCondensed',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomDropdown(
        value: _selectedFilter,
        items: const ['All Time', 'Today', 'This Month', 'This Year'],
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedFilter = newValue;
            });
            _loadUsers(); // Reload users with the new filter
          }
        },
      ),
    );
  }

  Widget _buildUserRank() {
    return FutureBuilder<String?>(
      future: _userService.fetchUsername(currentUserId!), // Fetch the username
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == flutter_async.ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while fetching
        }

        // Find the current user by matching the user ID
        final currentUser = _users.firstWhere(
            (user) => user['user_id'] == currentUserId,
            orElse: () =>
                {getBottleKey(): 0}); // Default to the chosen key with 0

        // Use the correct key based on the selected filter
        final bottleKey = getBottleKey();
        final hasRank = currentUser[bottleKey] > 0;
        final userRank = hasRank
            ? _users.indexOf(currentUser) + 1
            : 0; // Adjusted for rank calculation

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipOval(
                child: imgURL.isNotEmpty
                    ? Image.network(
                        imgURL,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/cat.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.data ?? 'Username',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
                    Text(
                      hasRank ? '${currentUser[bottleKey]} Bottles' : 'No rank',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasRank ? 'No.$userRank' : 'No rank',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankItem(int rank, dynamic user) {
    final bottleKey =
        getBottleKey(); // Use correct key based on the selected filter
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundImage:
                _userService.getProfileImage(user['profileImg_link']),
            radius: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user['username'] ?? 'User Name',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            '${user[bottleKey]} Bottles',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

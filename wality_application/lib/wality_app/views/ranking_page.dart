import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wality_application/wality_app/utils/custom_dropdown.dart';
import 'package:wality_application/wality_app/utils/constant.dart';
import 'package:realm/realm.dart';
import 'package:wality_application/wality_app/repo/realm_service.dart';
import 'package:wality_application/wality_app/repo/user_service.dart';
import 'package:flutter/src/widgets/async.dart' as flutter_async;

final App app = App(AppConfiguration('wality-1-djgtexn'));
final userId = app.currentUser?.id;
String imgURL = "";

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String _selectedFilter = 'All Time';
  List<dynamic> _users = [];
  bool _isLoading = true;

  final UserService _userService = UserService();
  final RealmService _realmService = RealmService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _fetchUserImage(userId!);
    });

    try {
      final users = await fetchUsers();
      setState(() {
        _users = users.where((user) => user['botLiv'] > 0).toList()
          ..sort((a, b) => b['botLiv'].compareTo(a['botLiv']));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
      // You might want to show an error message to the user here
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllUsers'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<String?> fetchUserImage(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['profileImg_link'];
    } else {
      print('Failed to fetch profileImg_link');
      return null;
    }
  }

      Future<String?> fetchUserName(String userId) async { 
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['username']; 
    } else {
      print('Failed to fetch username'); 
      return null;
    }
  }

  Future<void> _fetchUserImage(String userId) async {
    final profileImgLink = await _userService.fetchUserImage(userId);
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      setState(() {
        imgURL = profileImgLink;
      });
    }
  }

  ImageProvider _getProfileImage(String? profileImgLink) {
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      return NetworkImage(profileImgLink);
    } else {
      return const AssetImage('assets/images/cat.jpg');
    }
  }

    Future<int?> fetchUserBotLiv(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userId/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['botLiv'];
    } else {
      print('Failed to fetch botLivt');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                    ? Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                        ? Center(
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
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Ranking',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomDropdown(
        value: _selectedFilter,
        items: ['All Time', 'Today','This Month','This Year'],
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedFilter = newValue;
            });
            // You might want to implement filtering logic here
          }
        },
      ),
    );
  }

Widget _buildUserRank() {
  return FutureBuilder<String?>(
    future: fetchUserName(userId!), // Fetch the username
    builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
      if (snapshot.connectionState == flutter_async.ConnectionState.waiting) {
        return CircularProgressIndicator(); // Show loading indicator while fetching
      }

      // Find the current user by matching the user ID
      final currentUser = _users.firstWhere(
        (user) => user['user_id'] == userId,
        orElse: () => {'botLiv': 0} // Default to an object with botLiv = 0
      );

      // Check if botLiv is greater than 0 to determine rank display
      final hasRank = currentUser['botLiv'] > 0;
      final userRank = hasRank ? _users.indexOf(currentUser) + 1 : 0; // Adjusted for rank calculation

      return Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: _getProfileImage(currentUser['profileImg_link']),
              radius: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snapshot.data ?? 'Username',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(
                    hasRank ? '${currentUser['botLiv']} Bottles' : 'No rank',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hasRank ? 'No.$userRank' : 'No rank',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      );
    },
  );
}






  Widget _buildRankItem(int rank, dynamic user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 16),
          CircleAvatar(
            backgroundImage: _getProfileImage(user['profileImg_link']),
            radius: 20,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              user['username'] ?? 'User Name',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            '${user['botLiv']} Bottles',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

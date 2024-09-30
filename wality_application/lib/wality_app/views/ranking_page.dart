import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wality_application/wality_app/utils/custom_dropdown.dart';
import 'package:wality_application/wality_app/utils/constant.dart';


class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String _selectedFilter = 'All Time';
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await fetchUsers();
      setState(() {
        _users = users
            .where((user) => user['botLiv'] > 0)
            .toList()
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

  ImageProvider _getProfileImage(String? profileImgLink) {
    if (profileImgLink != null && profileImgLink.isNotEmpty) {
      return NetworkImage(profileImgLink);
    } else {
      return AssetImage('assets/default_avatar.png');
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
                        ? Center(child: Text('No users found', style: TextStyle(color: Colors.white)))
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
        items: ['All Time', 'Recently'],
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
    // Assuming the first user in the list is the current user
    // You might want to implement a more robust way to identify the current user
    final currentUser = _users.first;
    final userRank = _users.indexOf(currentUser) + 1;

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
                Text(currentUser['username'] ?? 'Username',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('${currentUser['botLiv']} Bottles',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('No.$userRank',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
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
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 16),
          CircleAvatar(
            backgroundImage: NetworkImage(user['profileImg_link'] ?? 'assets/default_avatar.png'),
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
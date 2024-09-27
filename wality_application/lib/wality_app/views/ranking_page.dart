import 'package:flutter/material.dart';
import 'package:wality_application/wality_app/utils/custom_dropdown.dart'; // Import the new file

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String _selectedFilter = 'All Time';

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
              _buildUserRank(),
              Expanded(
                child: ListView.builder(
                  itemCount: 13,
                  itemBuilder: (context, index) => _buildRankItem(index + 1),
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
          SizedBox(width: 40), // To balance the back button
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
          }
        },
      ),
    );
  }
  Widget _buildUserRank() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/user_avatar.png'),
            radius: 30,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username', style: TextStyle(color: Colors.white, fontSize: 18)),
                Text(_selectedFilter == 'Recently' ? '8876 Bottles' : '156280 Bottles', 
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
            child: Text(_selectedFilter == 'Recently' ? 'No.6' : 'No.3', 
                        style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(int rank) {
    final todaySteps = 15628 - (rank - 1) * 1000;
    final allTimeSteps = todaySteps * 30; // Just for demonstration

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
            backgroundImage: AssetImage('assets/avatar_$rank.png'),
            radius: 20,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'User Name $rank',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            '${_selectedFilter == 'Recently' ? todaySteps : allTimeSteps} Bottles',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}


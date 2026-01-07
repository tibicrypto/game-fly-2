import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/game_state_manager.dart';
import '../localization/app_localizations.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: Colors.white, size: size.width * 0.08),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        localizations.leaderboard,
                        style: TextStyle(
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: size.width * 0.08),
                  ],
                ),
              ),

              // Trophy Icon
              Icon(
                Icons.emoji_events,
                size: size.width * 0.2,
                color: Colors.amber,
              ),
              SizedBox(height: size.height * 0.02),

              Text(
                localizations.topFlights,
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // Leaderboard List
              Expanded(
                child: gameState.leaderboard.isEmpty
                    ? Center(
                        child: Text(
                          localizations.noRecordsYet,
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            color: Colors.white60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        itemCount: gameState.leaderboard.length,
                        itemBuilder: (context, index) {
                          final record = gameState.leaderboard[index];
                          final isTopRank = index == 0;

                          return Container(
                            margin:
                                EdgeInsets.only(bottom: size.height * 0.015),
                            padding: EdgeInsets.all(size.width * 0.04),
                            decoration: BoxDecoration(
                              gradient: isTopRank
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500)
                                      ],
                                    )
                                  : null,
                              color: isTopRank ? null : Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isTopRank ? Colors.amber : Colors.white30,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Rank Badge
                                Container(
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                  decoration: BoxDecoration(
                                    color: isTopRank
                                        ? Colors.white
                                        : Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: size.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: isTopRank
                                            ? Colors.orange
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.04),

                                // Record Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Distance
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.flight,
                                            size: size.width * 0.05,
                                            color: isTopRank
                                                ? Colors.white
                                                : Colors.lightBlue,
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          Text(
                                            '${record.distance}m',
                                            style: TextStyle(
                                              fontSize: size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                              color: isTopRank
                                                  ? Colors.white
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.005),

                                      // Plane & Cargo
                                      Row(
                                        children: [
                                          Text(
                                            '${localizations.plane}: ${record.plane}',
                                            style: TextStyle(
                                              fontSize: size.width * 0.032,
                                              color: isTopRank
                                                  ? Colors.white70
                                                  : Colors.white70,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          Text(
                                            '${localizations.cargo}: ${record.cargo}',
                                            style: TextStyle(
                                              fontSize: size.width * 0.032,
                                              color: isTopRank
                                                  ? Colors.white70
                                                  : Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Date
                                      Text(
                                        dateFormat.format(record.date),
                                        style: TextStyle(
                                          fontSize: size.width * 0.028,
                                          color: isTopRank
                                              ? Colors.white60
                                              : Colors.white54,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

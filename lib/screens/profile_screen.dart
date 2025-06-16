import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data (to be replaced with actual user data later)
    final String userName = 'Nome Sobrenome';
    final String level = 'Level 2: Folinha';

    final achievements = [
      {
        'name': 'Primeira Colheita',
        'description': 'Colheu a primeira planta!',
        'earned': true,
      },
      {
        'name': 'Amante da Luz',
        'description': 'Ajustou corretamente a luz 10 vezes',
        'earned': false,
      },
      {
        'name': 'Solo Perfeito',
        'description': 'Manteve a humidade ideal por 7 dias',
        'earned': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: const MicroGardenAppBar(
        titleWidget: const Text(
          'PROFILE',
          style: TextStyle(color: Colors.grey),
        ),
        showBackButton: true,
      ),
      body: Column(
        children: [
          // --- Profile Info Header ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.yellow,
                  child: Text(
                    'Profile\npic',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      level,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Achievement List ---
          Expanded(
            child: ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> achievement = achievements[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                    border: achievement['earned']
                        ? Border.all(color: Colors.greenAccent, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(height: 40, width: 40, color: Colors.white),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            achievement['description'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

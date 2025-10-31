import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../models/plant_card.dart';

class CardDetailPage extends StatelessWidget {
  final PlantCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: MicroGardenAppBar(
        titleWidget: Text(
          card.name.toUpperCase(),
          style: const TextStyle(color: Colors.amber),
        ),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Image and Basic Info
            _buildHeader(context),

            // Quick Stats
            _buildQuickStats(),

            // Description
            _buildSection(
              title: 'Sobre',
              icon: Icons.info_outline,
              child: Text(
                card.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            // Growing Information
            _buildSection(
              title: 'Informações de Cultivo',
              icon: Icons.agriculture,
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.thermostat,
                    label: 'Temperatura Ideal',
                    value: card.idealTemperature,
                    color: Colors.redAccent,
                  ),
                  _buildInfoRow(
                    icon: Icons.wb_sunny,
                    label: 'Luz Ideal',
                    value: card.idealLight,
                    color: Colors.yellow,
                  ),
                  _buildInfoRow(
                    icon: Icons.water_drop,
                    label: 'Frequência de Rega',
                    value: card.wateringFrequency,
                    color: Colors.blue,
                  ),
                  _buildInfoRow(
                    icon: Icons.grass,
                    label: 'Humidade do Solo',
                    value: card.soilMoisture,
                    color: Colors.brown,
                  ),
                  _buildInfoRow(
                    icon: Icons.height,
                    label: 'Altura de Colheita',
                    value: card.harvestHeight,
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            // Nutritional Benefits
            _buildSection(
              title: 'Benefícios Nutricionais',
              icon: Icons.favorite,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: card.nutritionalBenefits
                    .map((benefit) => _buildBenefitChip(benefit))
                    .toList(),
              ),
            ),

            // Tips
            _buildSection(
              title: 'Dicas de Cultivo',
              icon: Icons.lightbulb_outline,
              child: Column(
                children: card.tips
                    .map((tip) => _buildTipItem(tip))
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[850]!,
            const Color(0xFF1E1E1E),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Plant Image
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 3),
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                card.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.eco,
                    size: 100,
                    color: Colors.green,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Plant Name
            Text(
              card.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Scientific Name
            Text(
              card.scientificName,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Text(
                card.summary,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.timer,
              label: 'Tempo',
              value: card.growthTime,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: card.difficultyIcon,
              label: 'Dificuldade',
              value: card.difficulty,
              color: card.difficultyColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_today,
              label: 'Época',
              value: card.season,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String benefit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Text(
            benefit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_right,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
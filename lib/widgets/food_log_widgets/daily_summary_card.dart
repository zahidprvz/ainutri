import 'package:flutter/material.dart';

class DailySummaryCard extends StatefulWidget {
  final double caloriesConsumed;
  final double caloriesGoal;
  final double proteinConsumed;
  final double proteinGoal;
  final double carbsConsumed;
  final double carbsGoal;
  final double fatConsumed;
  final double fatGoal;

  const DailySummaryCard({
    Key? key,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.fatConsumed,
    required this.fatGoal,
  }) : super(key: key);

  @override
  _DailySummaryCardState createState() => _DailySummaryCardState();
}

class _DailySummaryCardState extends State<DailySummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: 1.0 + (_animation.value * 0.05),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: screenWidth * 0.055, // Scale text size
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: screenWidth * 0.05),
              _buildProgressRow(
                "Calories",
                widget.caloriesConsumed,
                widget.caloriesGoal,
                Colors.orange,
              ),
              _buildProgressRow(
                "Protein",
                widget.proteinConsumed,
                widget.proteinGoal,
                Colors.green,
              ),
              _buildProgressRow(
                "Carbs",
                widget.carbsConsumed,
                widget.carbsGoal,
                Colors.blue,
              ),
              _buildProgressRow(
                "Fat",
                widget.fatConsumed,
                widget.fatGoal,
                Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(
      String label, double consumed, double goal, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "$label: ${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize:
                    MediaQuery.of(context).size.width * 0.04, // Scale text
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: goal > 0 ? consumed / goal : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 12,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Text(
                  goal > 0
                      ? "${(consumed / goal * 100).toStringAsFixed(0)}%"
                      : "0%",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width * 0.035, // Scale
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

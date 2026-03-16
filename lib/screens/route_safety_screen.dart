import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/route_model.dart';

class SafetyInfoDisplay extends StatelessWidget {
  final RouteModel route;
  final bool isDarkMode;

  const SafetyInfoDisplay({
    super.key,
    required this.route,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final safetyColor = AppColors.getSafetyColor(route.safety);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBlue.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: safetyColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: safetyColor,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                'Route Safety Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                title: 'Safety Score',
                value: '${route.safety}%',
                color: safetyColor,
              ),
              _buildStatCard(
                title: 'User Rating',
                value: '${route.rating}/5',
                color: safetyColor,
              ),
              _buildStatCard(
                title: 'Total Reviews',
                value: '${route.reviews}',
                color: safetyColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBlue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafetyRatingForm extends StatefulWidget {
  final RouteModel route;
  final Function(bool) onRatingSubmitted;
  final bool isDarkMode;

  const SafetyRatingForm({
    super.key,
    required this.route,
    required this.onRatingSubmitted,
    required this.isDarkMode,
  });

  @override
  State<SafetyRatingForm> createState() => _SafetyRatingFormState();
}

class _SafetyRatingFormState extends State<SafetyRatingForm> {
  int selectedRating = 0;
  String comment = '';
  bool isSubmitting = false;

  final List<String> ratingOptions = [
    'Very Unsafe',
    'Unsafe',
    'Neutral',
    'Safe',
    'Very Safe',
  ];

  void _submitRating() {
    if (selectedRating == 0) {
      _showError('Please select a rating');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isSubmitting = false;
      });
      widget.onRatingSubmitted(true);
      _showSuccess('Thank you for your rating!');
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.darkBlue.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                'Rate This Route',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              ratingOptions.length,
              (index) => ChoiceChip(
                label: Text(ratingOptions[index]),
                selected: selectedRating == index + 1,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  }
                },
                selectedColor: AppColors.primaryBlue,
                backgroundColor: widget.isDarkMode 
                    ? AppColors.darkBlue.withOpacity(0.3) 
                    : Colors.grey.withOpacity(0.2),
                avatar: selectedRating == index + 1
                    ? const Icon(Icons.check, size: 16)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Share your experience (optional)',
              labelStyle: TextStyle(
                color: textColor.withOpacity(0.7),
              ),
              filled: true,
              fillColor: widget.isDarkMode 
                  ? AppColors.darkBlue.withOpacity(0.2) 
                  : Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.isDarkMode ? Colors.white30 : Colors.black12,
                  width: 1,
                ),
              ),
            ),
            style: TextStyle(
              color: textColor,
            ),
            onChanged: (value) => comment = value,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedRating > 0 ? AppColors.primaryBlue : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class RouteSafetyRatingScreen extends StatefulWidget {
  final RouteModel route;
  final bool isDarkMode;

  const RouteSafetyRatingScreen({
    super.key,
    required this.route,
    required this.isDarkMode,
  });

  @override
  State<RouteSafetyRatingScreen> createState() => _RouteSafetyRatingScreenState();
}

class _RouteSafetyRatingScreenState extends State<RouteSafetyRatingScreen> {
  bool isRatingSubmitted = false;

  void _handleRatingSubmitted(bool success) {
    setState(() {
      isRatingSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Safety Rating'),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafetyInfoDisplay(
              route: widget.route,
              isDarkMode: widget.isDarkMode,
            ),
            const SizedBox(height: 20),
            SafetyRatingForm(
              route: widget.route,
              onRatingSubmitted: _handleRatingSubmitted,
              isDarkMode: widget.isDarkMode,
            ),
            if (isRatingSubmitted)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? AppColors.darkBlue.withOpacity(0.3) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(
                          'Rating Submitted!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for contributing to the SafeStride community!',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

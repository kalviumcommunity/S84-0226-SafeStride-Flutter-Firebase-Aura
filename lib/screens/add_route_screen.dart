import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AddRouteScreen extends StatefulWidget {
  final bool isDarkMode;

  const AddRouteScreen({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  int step = 1;
  String? routeType;
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers
  final _routeNameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _routeNameController.dispose();
    _distanceController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.neonGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Route "${_routeNameController.text}" submitted successfully!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: widget.isDarkMode ? AppColors.mediumBlue : AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      
      setState(() => step = 4);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            step = 1;
            routeType = null;
            _routeNameController.clear();
            _distanceController.clear();
            _emailController.clear();
            _descriptionController.clear();
          });
        }
      });
    } else {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Please fix the errors before submitting',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (step == 4) {
      return Scaffold(
        backgroundColor: widget.isDarkMode ? AppColors.darkBlue : AppColors.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Route Added!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your route has been successfully submitted for review.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.isDarkMode ? AppColors.darkBlue : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkMode
                    ? [AppColors.lightBlue, Colors.transparent]
                    : [AppColors.lightBackground, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(left: 24, right: 24, top: 64, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Route',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your favorite route with the community',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Progress Steps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    for (int i = 1; i <= 3; i++) ...[
                      _buildStepIndicator(i),
                      if (i < 3)
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: step > i ? AppColors.neonGradient : null,
                              color: step > i
                                  ? null
                                  : widget.isDarkMode
                                      ? AppColors.mediumBlue
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepLabel('Details', 1),
                    _buildStepLabel('Location', 2),
                    _buildStepLabel('Media', 3),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNum) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: step >= stepNum ? AppColors.neonGradient : null,
        color: step >= stepNum
            ? null
            : widget.isDarkMode
                ? AppColors.mediumBlue
                : Colors.grey[200],
        shape: BoxShape.circle,
        boxShadow: step >= stepNum
            ? [
                BoxShadow(
                  color: AppColors.neonGreen.withOpacity(0.3),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          stepNum.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: step >= stepNum
                ? AppColors.textDark
                : widget.isDarkMode
                    ? Colors.grey[500]
                    : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildStepLabel(String label, int stepNum) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: step >= stepNum
            ? widget.isDarkMode
                ? AppColors.neonGreen
                : AppColors.primaryBlue
            : widget.isDarkMode
                ? Colors.grey[500]
                : Colors.grey[400],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return Container();
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _routeNameController,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Enter route name',
              hintStyle: TextStyle(
                color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[400]!, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a route name';
              }
              if (value.trim().length < 3) {
                return 'Route name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Contact Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'example@email.com',
              hintStyle: TextStyle(
                color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[400]!, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              // Email regex pattern
              final emailRegex = RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Route Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildRouteTypeCard('runner', '🏃‍♂️', 'Runner')),
              const SizedBox(width: 16),
              Expanded(child: _buildRouteTypeCard('cyclist', '🚴‍♀️', 'Cyclist')),
            ],
          ),
          if (routeType == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select a route type',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[400],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Distance (km)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _distanceController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: '0.0',
              hintStyle: TextStyle(
                color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[400]!, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter distance';
              }
              final distance = double.tryParse(value.trim());
              if (distance == null) {
                return 'Please enter a valid number';
              }
              if (distance <= 0) {
                return 'Distance must be greater than 0';
              }
              if (distance > 200) {
                return 'Distance seems too large (max 200km)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Description (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Describe your route...',
              hintStyle: TextStyle(
                color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_routeNameController.text.trim().isNotEmpty &&
                    _emailController.text.trim().isNotEmpty &&
                    routeType != null &&
                    _distanceController.text.trim().isNotEmpty) {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => step = 2);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please fill in all required fields'),
                      backgroundColor: Colors.orange[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRouteTypeCard(String type, String emoji, String label) {
    final isSelected = routeType == type;
    return GestureDetector(
      onTap: () => setState(() => routeType = type),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.neonGradient : null,
          color: isSelected
              ? null
              : widget.isDarkMode
                  ? AppColors.mediumBlue
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textDark
                    : widget.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isDarkMode ? AppColors.lightBlue : Colors.grey[200]!,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? AppColors.lightBlue
                      : const Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.map,
                  size: 32,
                  color: widget.isDarkMode ? AppColors.neonGreen : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mark Your Route',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap on the map to mark the starting point and route path',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Open Map',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => step = 3),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => step = 1),
          child: Text(
            'Back',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMediaOption(Icons.camera_alt, 'Take Photo'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMediaOption(Icons.upload, 'Upload'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? AppColors.mediumBlue
                : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '💡 Tip: Adding photos helps others discover your route!',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: const Text(
              'Submit Route',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => step = 2),
          child: Text(
            'Back',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMediaOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? AppColors.lightBlue
                    : const Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: widget.isDarkMode ? AppColors.neonGreen : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

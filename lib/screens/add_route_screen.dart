import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../services/firestore_service.dart';
import '../widgets/location_step.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  // Debug-only probe to verify Step 2 render path quickly.
  static const bool _debugStep2Probe = false;
  int step = 1;
  String? routeType;
  List<LatLng> _routePoints = <LatLng>[];
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedMedia = <XFile>[];

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

  bool _isSaving = false;

  void handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (routeType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a route type'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (_routePoints.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please create a route on the map first'),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      _formKey.currentState?.save();
      _saveToFirestore();
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final routeId = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
      final photoUrls = await _uploadRoutePhotos(uid, routeId);

      await FirestoreService().addRoute(routeId, {
        'routeId': routeId,
        'name': _routeNameController.text.trim(),
        'category': routeType == 'runner' ? 'Runner' : 'Cyclist',
        'distance': '${_distanceController.text.trim()} km',
        'description': _descriptionController.text.trim(),
        'contactEmail': _emailController.text.trim(),
        'submittedBy': uid,
        'safety': 0,
        'rating': 0.0,
        'reviews': 0,
        'routePoints': _routePoints
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
        'photoUrls': photoUrls,
      });

      if (!mounted) return;
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
          backgroundColor: (Theme.of(context).brightness == Brightness.dark)
              ? AppColors.mediumBlue
              : AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            _routePoints = <LatLng>[];
            _selectedMedia.clear();
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save route: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<List<String>> _uploadRoutePhotos(String uid, String routeId) async {
    if (_selectedMedia.isEmpty) {
      return <String>[];
    }

    final FirebaseStorage storage = FirebaseStorage.instance;
    final List<String> uploadedUrls = <String>[];

    for (int index = 0; index < _selectedMedia.length; index++) {
      final XFile image = _selectedMedia[index];
      final Reference ref = storage.ref().child(
        'routes/$uid/$routeId/photo_$index.jpg',
      );

      final bytes = await image.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

      final url = await ref.getDownloadURL();
      uploadedUrls.add(url);
    }

    return uploadedUrls;
  }

  Future<void> _pickMedia(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedMedia.add(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (step == 4) {
      return Scaffold(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark)
            ? AppColors.darkBlue
            : AppColors.lightBackground,
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
                  color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your route has been successfully submitted for review.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark)
          ? AppColors.darkBlue
          : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: (Theme.of(context).brightness == Brightness.dark)
                    ? [AppColors.lightBlue, Colors.transparent]
                    : [AppColors.lightBackground, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 64,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Route',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: (Theme.of(context).brightness == Brightness.dark)
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your favorite route with the community',
                  style: TextStyle(
                    fontSize: 14,
                    color: (Theme.of(context).brightness == Brightness.dark)
                        ? Colors.grey[400]
                        : Colors.grey[600],
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
                              gradient: step > i
                                  ? AppColors.neonGradient
                                  : null,
                              color: step > i
                                  ? null
                                  : (Theme.of(context).brightness == Brightness.dark)
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
            : (Theme.of(context).brightness == Brightness.dark)
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
                : (Theme.of(context).brightness == Brightness.dark)
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
            ? (Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.neonGreen
                  : AppColors.primaryBlue
            : (Theme.of(context).brightness == Brightness.dark)
            ? Colors.grey[500]
            : Colors.grey[400],
      ),
    );
  }

  Widget _buildStepContent() {
    debugPrint('[AddRouteScreen] Rendering step $step');
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
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _routeNameController,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Enter route name',
              hintStyle: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: (Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.mediumBlue
                  : Colors.white,
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
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'example@email.com',
              hintStyle: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: (Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.mediumBlue
                  : Colors.white,
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
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildRouteTypeCard('runner', '🏃‍♂️', 'Runner')),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRouteTypeCard('cyclist', '🚴‍♀️', 'Cyclist'),
              ),
            ],
          ),
          if (routeType == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select a route type',
                style: TextStyle(fontSize: 12, color: Colors.red[400]),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Distance (km)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _distanceController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: '0.0',
              hintStyle: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: (Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.mediumBlue
                  : Colors.white,
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
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Describe your route...',
              hintStyle: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[500] : Colors.grey[400],
              ),
              filled: true,
              fillColor: (Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.mediumBlue
                  : Colors.white,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              : (Theme.of(context).brightness == Brightness.dark)
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
                    : (Theme.of(context).brightness == Brightness.dark)
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
    debugPrint('[AddRouteScreen] Building LocationStep (step=2)');

    if (_debugStep2Probe) {
      return Container(
        height: 320,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Step 2 probe: Location step render path is active',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return ConstrainedBox(
      // SingleChildScrollView gives unbounded height; keep Step 2 visible
      // with a minimum height so the child cannot collapse unexpectedly.
      constraints: const BoxConstraints(minHeight: 560),
      child: LocationStep(
        isDarkMode: (Theme.of(context).brightness == Brightness.dark),
        routePoints: _routePoints,
        onRoutePointsChanged: (points) {
          setState(() {
            _routePoints = points;
          });
        },
        onContinue: () {
          if (_routePoints.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please create a route on the map first'),
                backgroundColor: Colors.orange[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            return;
          }
          setState(() => step = 3);
        },
        onBack: () => setState(() => step = 1),
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMediaOption(
                Icons.camera_alt,
                'Take Photo',
                onTap: () => _pickMedia(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMediaOption(
                Icons.upload,
                'Upload',
                onTap: () => _pickMedia(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (_selectedMedia.isNotEmpty) ...[
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_selectedMedia.length} photo(s) selected',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedMedia.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final media = _selectedMedia[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        media.path,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 92,
                          height: 92,
                          color: (Theme.of(context).brightness == Brightness.dark)
                              ? AppColors.mediumBlue
                              : Colors.grey[200],
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMedia.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? AppColors.mediumBlue
                : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '💡 Tip: Adding photos helps others discover your route!',
            style: TextStyle(
              fontSize: 14,
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Route',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => step = 2),
          child: Text(
            'Back',
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMediaOption(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.mediumBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark)
                    ? AppColors.lightBlue
                    : const Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: (Theme.of(context).brightness == Brightness.dark)
                    ? AppColors.neonGreen
                    : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

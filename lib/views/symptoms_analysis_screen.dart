import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/symptoms_analysis_provider.dart';
import '../models/analysis_result.dart';

class SymptomsAnalysisScreen extends StatefulWidget {
  const SymptomsAnalysisScreen({super.key});

  @override
  State<SymptomsAnalysisScreen> createState() => _SymptomsAnalysisScreenState();
}

class _SymptomsAnalysisScreenState extends State<SymptomsAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  
  String _selectedAnimal = 'গরু';
  String _selectedDuration = '১ দিন';
  String _selectedAgeGroup = 'বাচ্চা';

  final List<String> _animals = ['গরু', 'ছাগল', 'ভেড়া', 'মহিষ', 'হাঁস', 'মুরগি'];
  final List<String> _durations = ['১ দিন', '৩ দিন', '৭ দিন', '৭ দিনের বেশি'];
  final List<String> _ageGroups = ['বাচ্চা', 'প্রাপ্তবয়স্ক'];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        context.read<SymptomsAnalysisProvider>().setImage(File(image.path));
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<SymptomsAnalysisProvider>().analyze(
        symptoms: _symptomsController.text,
        animalType: _selectedAnimal,
        duration: _selectedDuration,
        ageGroup: _selectedAgeGroup,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Clear state when leaving the screen reliably
          Future.microtask(() {
            if (context.mounted) {
              context.read<SymptomsAnalysisProvider>().reset();
            }
          });
        }
      },
      child: Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AI উপসর্গ বিশ্লেষণ', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<SymptomsAnalysisProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.health_and_safety, size: 48, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'আপনার প্রাণীর স্বাস্থ্য পরীক্ষা করুন',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildForm(provider),
                      
                      if (provider.isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(color: Colors.green),
                              const SizedBox(height: 16),
                              Text(
                                'AI বিশ্লেষণ করছে...',
                                style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        
                      if (provider.error != null)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  provider.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                      if (provider.result != null)
                        _buildResults(provider.result!),
                        
                      const SizedBox(height: 24),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '“এটি AI অনুমান—চূড়ান্ত রোগ নির্ণয়ের জন্য ভেটের পরামর্শ নিন।”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildForm(SymptomsAnalysisProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'উপসর্গগুলো বর্ণনা করুন',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _symptomsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'আপনার প্রাণীর লক্ষণগুলো এখানে লিখুন...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'দয়া করে উপসর্গগুলো লিখুন' : null,
            ),
            const SizedBox(height: 20),
            
            _buildDropdownLabel('প্রাণীর ধরন'),
            DropdownButtonFormField<String>(
              value: _selectedAnimal,
              decoration: _inputDecoration(),
              items: _animals.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedAnimal = newValue!),
            ),
            const SizedBox(height: 20),
            
            // Fixed Overflow: Stack dropdowns on smaller widths or use better constraints
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdownLabel('স্থায়িত্ব'),
                      DropdownButtonFormField<String>(
                        isExpanded: true, // Key to handle some overflow
                        value: _selectedDuration,
                        decoration: _inputDecoration(),
                        items: _durations.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (newValue) => setState(() => _selectedDuration = newValue!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdownLabel('প্রাণীর বয়স'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedAgeGroup,
                        decoration: _inputDecoration(),
                        items: _ageGroups.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (newValue) => setState(() => _selectedAgeGroup = newValue!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green[200]!, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green[50],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      provider.selectedImage == null ? 'ছবি আপলোড করুন' : 'ছবি পরিবর্তন করুন',
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            if (provider.selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        provider.selectedImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => provider.setImage(null),
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                        style: IconButton.styleFrom(backgroundColor: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: provider.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('উপসর্গ বিশ্লেষণ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        _buildSectionHeader('বিশ্লেষণ রিপোর্ট'),
        const SizedBox(height: 20),
        
        // Grouped Probable Diseases Section
        _buildDiseaseSection(result.diseases),
        
        const SizedBox(height: 12),
        
        // Treatment & Actions Grid
        _buildActionSection(
          title: 'প্রাথমিক ওষুধ',
          subtitle: 'জরুরি অবস্থায় প্রাথমিক চিকিৎসা',
          icon: Icons.medication_rounded,
          color: Colors.blue,
          items: result.primaryMedicines,
        ),
        
        _buildActionSection(
          title: 'ঘরোয়া চিকিৎসা',
          subtitle: 'স্বাস্থ্যসম্মত ঘরোয়া সমাধান',
          icon: Icons.eco_rounded,
          color: Colors.teal,
          items: result.homeCare,
        ),
        
        _buildActionSection(
          title: 'প্রয়োজনীয় পদক্ষেপ',
          subtitle: 'রোগ নিয়ন্ত্রণে যা করতে হবে',
          icon: Icons.gpp_maybe_rounded,
          color: Colors.orange.shade800,
          items: result.actions,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseSection(List<Disease> diseases) {
    if (diseases.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'সম্ভাব্য রোগসমূহ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'প্রাপ্ত আলামতের ভিত্তিতে বিশ্লেষণ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...diseases.map((disease) => _buildDiseaseItem(disease)),
        ],
      ),
    );
  }

  Widget _buildDiseaseItem(Disease disease) {
    final bool isHighRisk = disease.probability >= 70;
    final Color statusColor = isHighRisk ? Colors.red : Colors.orange;
    
    return ClipRRect(
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    disease.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isHighRisk) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'High Risk',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: disease.probability / 100,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${disease.probability.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'কেন এই রোগ হতে পারে:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  disease.reason,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            // ignore: deprecated_member_use
            color.withOpacity(0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: color),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      ),
    );
  }
}

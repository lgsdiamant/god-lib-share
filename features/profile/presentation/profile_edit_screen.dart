import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:god_of_debate/core/constants/constants_keys.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:god_of_debate/core/constants/constants.dart';
import 'package:god_of_debate/core/constants/constants_string.dart';
import 'package:god_of_debate/core/providers/firebase_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _favoriteTopicController = TextEditingController();
  final _phoneController = TextEditingController();
  String _gender = kGenderSecret;
  String _ageGroup = kAgeGroupSecret;
  String _countryCode = '+82';
  File? _selectedImage;
  String _email = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;

    final snapshot = await ref
        .read(firebaseFirestoreProvider)
        .collection(kUsersCollection)
        .doc(user.uid)
        .get();

    final data = snapshot.data();
    if (data != null) {
      _nameController.text = data[kFieldName] ?? '';
      _nicknameController.text = data[kFieldNickname] ?? '';
      _bioController.text = data[kFieldBio] ?? '';
      _favoriteTopicController.text = data[kFieldFavoriteTopic] ?? '';
      _phoneController.text =
          data[kFieldPhone]?.replaceFirst(RegExp(r'^\+\d+\s'), '') ?? '';
      _gender = data[kFieldGender] ?? kGenderSecret;
      _ageGroup = data[kFieldAgeGroup] ?? kAgeGroupSecret;
    }

    _email = user.email ?? '';
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _nicknameController.text.trim().isEmpty ||
        _gender.isEmpty ||
        _ageGroup.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = ref.read(firebaseAuthProvider);
    final firestore = ref.read(firebaseFirestoreProvider);
    final storage = ref.read(firebaseStorageProvider);
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    String? photoUrl;
    if (_selectedImage != null) {
      final originalBytes = await _selectedImage!.readAsBytes();
      final image = img.decodeImage(originalBytes);
      if (image != null) {
        final resized = img.copyResize(image, width: 300);
        final resizedBytes = img.encodeJpg(resized, quality: 80);
        final refStorage = storage.ref('profile_images/$uid.jpg');
        await refStorage.putData(Uint8List.fromList(resizedBytes));
        photoUrl = await refStorage.getDownloadURL();
      }
    }

    final data = {
      kFieldName: _nameController.text.trim(),
      kFieldNickname: _nicknameController.text.trim(),
      kFieldBio: _bioController.text.trim(),
      kFieldFavoriteTopic: _favoriteTopicController.text.trim(),
      kFieldPhone:
          '$_countryCode ${_phoneController.text.trim().replaceAll(' ', '')}',
      kFieldGender: _gender,
      kFieldAgeGroup: _ageGroup,
      if (photoUrl != null) kFieldPhotoUrl: photoUrl,
    };

    await firestore
        .collection(kUsersCollection)
        .doc(uid)
        .set(data, SetOptions(merge: true));

    if (!mounted) return;
    context.go('/profile-view');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(strProfileEditTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.add_a_photo, size: 48)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_nameController, '이름'),
                  const SizedBox(height: 8),
                  _buildTextField(_nicknameController, '닉네임'),
                  const SizedBox(height: 8),
                  _buildTextField(_bioController, '한줄 소개'),
                  const SizedBox(height: 8),
                  _buildTextField(_favoriteTopicController, '좋아하는 토론 주제'),
                  const SizedBox(height: 8),
                  _buildCountryPicker(),
                  const SizedBox(height: 8),
                  _buildTextField(_phoneController, '전화번호'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                      '성별',
                      _gender,
                      [kGenderMale, kGenderFemale, kGenderSecret],
                      (value) => setState(() => _gender = value)),
                  const SizedBox(height: 8),
                  _buildDropdown(
                      '나이대',
                      _ageGroup,
                      [
                        kAgeGroupUnder17,
                        kAgeGroup10s,
                        kAgeGroup20s,
                        kAgeGroup30s,
                        kAgeGroup40s,
                        kAgeGroup50s,
                        kAgeGroup60s,
                        kAgeGroup70Plus,
                        kAgeGroupSecret
                      ],
                      (value) => setState(() => _ageGroup = value)),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCountryPicker() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (country) {
                setState(() {
                  _countryCode = '+${country.phoneCode}';
                });
              },
            );
          },
          child: Text(_countryCode),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildTextField(_phoneController, '전화번호')),
      ],
    );
  }
}

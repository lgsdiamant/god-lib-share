import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController nicknameController;
  final TextEditingController phoneController;
  final String? gender;
  final String? ageGroup;
  final File? profileImage;
  final Function(File file) onImagePicked;
  final Function(String gender) onGenderChanged;
  final Function(String ageGroup) onAgeGroupChanged;

  const ProfileForm({
    super.key,
    required this.nameController,
    required this.nicknameController,
    required this.phoneController,
    required this.gender,
    required this.ageGroup,
    required this.profileImage,
    required this.onImagePicked,
    required this.onGenderChanged,
    required this.onAgeGroupChanged,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      widget.onImagePicked(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: widget.profileImage != null
                ? FileImage(widget.profileImage!)
                : null,
            child: widget.profileImage == null
                ? const Icon(Icons.add_a_photo, size: 40)
                : null,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: widget.nameController,
          decoration: const InputDecoration(
            labelText: '이름',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.nicknameController,
          decoration: const InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: widget.gender,
          decoration: const InputDecoration(
            labelText: '성별',
            border: OutlineInputBorder(),
          ),
          items: ['남성', '여성', '미공개'].map((gender) {
            return DropdownMenuItem(value: gender, child: Text(gender));
          }).toList(),
          onChanged: (value) {
            if (value != null) widget.onGenderChanged(value);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: widget.ageGroup,
          decoration: const InputDecoration(
            labelText: '나이대',
            border: OutlineInputBorder(),
          ),
          items: ['10대', '20대', '30대', '40대 이상'].map((age) {
            return DropdownMenuItem(value: age, child: Text(age));
          }).toList(),
          onChanged: (value) {
            if (value != null) widget.onAgeGroupChanged(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.phoneController,
          decoration: const InputDecoration(
            labelText: '전화번호 (+82)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

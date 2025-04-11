// lib/core/constants/constants.dart

import 'package:flutter/material.dart';

// 기본 패딩
const double kDefaultPadding = 16.0;

// 아고라 색상 테마
const Color kPrimaryColor = Color(0xFF6C63FF); // 보라색 계열
const Color kSecondaryColor = Color(0xFFFFC107); // 엠버 (포인트)
const Color kBackgroundColor = Color(0xFFF5F5F5); // 연한 회색
const Color kTextColor = Color(0xFF333333); // 진한 회색

// 버튼 스타일 공통
final ButtonStyle kButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kPrimaryColor,
  foregroundColor: Colors.white,
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);

// 둥근 모양 아이콘 버튼 스타일
const double kIconButtonRadius = 24.0;

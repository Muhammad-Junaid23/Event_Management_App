import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFFCF3232);
  static const Color primaryTransparent = Color(
    0x33CF3232,
  ); // #CF323233 (20% opacity for Group Profile button)
  static const Color danger = Color(0xFFEA252D); // Logout text/icon

  // Text Shades (Dark to Light)
  static const Color textMain = Color(0xFF000000); // Black headings & labels
  static const Color textActiveTab = Color(
    0xFF0E0E0E,
  ); // Active bottom tab text
  static const Color textHeading = Color(
    0xFF1F1F1F,
  ); // Login title ("into your account")
  static const Color textDark = Color(0xFF272727); // Settings list item text
  static const Color textLocation = Color(0xFF3C3C3C); // Location text on cards
  static const Color textOption = Color(0xFF424242); // Poll option main text
  static const Color textBody = Color(
    0xFF505050,
  ); // Subtitle & placeholder text
  static const Color textMuted = Color(
    0xFF555555,
  ); // Icons, titles, unselected tabs
  static const Color textDetails = Color(0xFF5B5B5B); // Event details text
  static const Color textSubtle = Color(
    0xFF727272,
  ); // Onboarding body & list view icon
  static const Color textCardSubtitle = Color(0xFF7A7A7A); // Card subtitle text
  static const Color textUserEmail = Color(0xFF848484); // Settings user email
  static const Color textVote = Color(0xFF9F9F9F); // Poll vote count text
  static const Color textWhite = Color(0xFFFFFFFF); // White text

  // Borders & Outlines
  static const Color borderInput = Color(0xFF9A9A9A); // Input fields (0.4px)
  static const Color borderCard = Color(0xFFBABABA); // Feature cards
  static const Color borderCommunityCard = Color(0xFF3E3E3E); // Community card
  static const Color borderTagInactive = Color(
    0xFF545454,
  ); // Filter inactive tags
  static const Color borderFilter = Color(0xFF838383); // Filter selection field
  static const Color borderDivider = Color(
    0xFFA2A2A2,
  ); // Settings bottom divider
  static const Color borderTechCard = Color(0xFFCFCFCF); // Tech meetup card
  static const Color borderFilterIcon = Color(0xFFDDDDDD); // Filter icon border

  // Feature-Specific Colors (Calendar & Navigation)
  static const Color calendarMonth = Color(0xFF222B45);
  static const Color calendarYearDay = Color(0xFF8F9BB3);
  static const Color calendarBottomBorder = Color(0xFF5E5E5E);
  static const Color filterIcon = Color(0xFF5A5A5A);
  static const Color endingIcon = Color(0xFF4D4D4D);

  // Indicators & Backgrounds
  static const Color dotInactive = Color(
    0xFFE6E6E6,
  ); // Onboarding inactive dots
  static const Color tileBackground = Color(0xFFF5F5F5); // Notification tile bg
  static const Color background = Color(0xFFFFFFFF); // White background
}

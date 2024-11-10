import 'package:flutter/material.dart';

class CouponViewModel extends ChangeNotifier {
  String? couponNameError;
  String? couponBriefDescriptionError;
  String? couponImportanceDescriptionError;
  String? couponBotRequirementError;
  String? couponDescriptionError;
  String? replenishError;
  String? allErrorCoupon;


  final bool _isScrollable = false;
  bool _showValidationMessage = false;

  bool get isScrollable => _isScrollable;
  bool get showValidationMessage => _showValidationMessage;

  void setcouponNameError(String? error) {
    couponNameError = error;
    notifyListeners();
  }

  String? validateCouponName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Coupon name is required';
    }
    return null;
  }

  String? validateBriefDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Brief description is required';
    }
    return null;
  }

  String? validateImportanceDescription(String? value) {
    // Making this optional - returning null means no error
    return null;
  }

  String? validateBotRequirement(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bottle requirement is required';
    }
    // Validate that it's a positive number
    try {
      int bottles = int.parse(value);
      if (bottles <= 0) {
        return 'Bottle requirement must be greater than 0';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    return null;
  }

String? validateReplenish(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Replenish is required';
    }
    return null;
  }
  void setBriefDescriptionError(String? error) {
    couponBriefDescriptionError = error;
    notifyListeners();
  }

  void setImportanceDescriptionError(String? error) {
    couponImportanceDescriptionError = error;
    notifyListeners();
  }

  void setBotRequirementError(String? error) {
    couponBotRequirementError = error;
    notifyListeners();
  }

  void setDescriptionError(String? error) {
    couponDescriptionError = error;
    notifyListeners();
  }

  void setReplenish(String? error) {
    replenishError = error;
    notifyListeners();
  }

  void clearErrors() {
    couponNameError = null;
    couponBriefDescriptionError = null;
    couponImportanceDescriptionError = null;
    couponBotRequirementError = null;
    couponDescriptionError = null;
    replenishError = null;
    allErrorCoupon = null;
    _showValidationMessage = false;
    notifyListeners();
  }

  bool validateAllCouponFields({
    required String name,
    required String briefDescription,
    required String importanceDescription,
    required String botRequirement,
    required String description,
    required String replenish,
  }) {
    // Trim all inputs to handle whitespace-only inputs
    name = name.trim();
    briefDescription = briefDescription.trim();
    importanceDescription = importanceDescription.trim();
    botRequirement = botRequirement.trim();
    description = description.trim();
    replenish = replenish.trim();
    bool isValid = true;

    // Validate required fields
    if (validateCouponName(name) != null) isValid = false;
    if (validateBriefDescription(briefDescription) != null) isValid = false;
    if (validateBotRequirement(botRequirement) != null) isValid = false;
    if (validateDescription(description) != null) isValid = false;
    if (validateDescription(replenish) != null) isValid = false;
    // Note: importanceDescription is optional, so we don't check it here

    return isValid;
  }
}
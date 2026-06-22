/// Shared password validation and strength calculation service
class PasswordValidationService {
  /// Check if email is valid format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength (detailed validation)
  static PasswordValidationResult validatePassword(String password) {
    final result = PasswordValidationResult();

    // Minimum length
    if (password.length >= 8) {
      result.hasMinimumLength = true;
    }

    // Lowercase
    if (password.contains(RegExp(r'[a-z]'))) {
      result.hasLowercase = true;
    }

    // Uppercase
    if (password.contains(RegExp(r'[A-Z]'))) {
      result.hasUppercase = true;
    }

    // Numbers
    if (password.contains(RegExp(r'[0-9]'))) {
      result.hasNumbers = true;
    }

    // Special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      result.hasSpecialCharacters = true;
    }

    return result;
  }

  /// Calculate password strength (0.0 to 1.0)
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0;

    // Length
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

    // Contains numbers
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    return strength.clamp(0, 1);
  }

  /// Get password strength label (returns localization key)
  static String getPasswordStrengthLabel(double strength) {
    if (strength < 0.4) return 'password_weak';
    if (strength < 0.7) return 'password_fair';
    if (strength < 0.9) return 'password_good';
    return 'password_strong';
  }

  /// Get password strength color
  static String getPasswordStrengthColor(double strength) {
    if (strength < 0.4) return 'red';
    if (strength < 0.7) return 'orange';
    if (strength < 0.9) return 'amber';
    return 'green';
  }

  /// Check if password meets minimum requirements
  static bool meetsMinimumRequirements(String password) {
    final validation = validatePassword(password);
    return validation.hasMinimumLength &&
        validation.hasLowercase &&
        validation.hasUppercase &&
        validation.hasNumbers;
  }

  /// Get validation error message (first failing requirement)
  static String? getValidationError(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    final validation = validatePassword(password);

    if (!validation.hasMinimumLength) {
      return 'Password must be at least 8 characters';
    }
    if (!validation.hasLowercase) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!validation.hasUppercase) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!validation.hasNumbers) {
      return 'Password must contain at least one number';
    }

    return null;
  }
}

/// Password validation result with detailed breakdown
class PasswordValidationResult {
  bool hasMinimumLength = false;
  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasNumbers = false;
  bool hasSpecialCharacters = false;

  bool get isValid =>
      hasMinimumLength && hasLowercase && hasUppercase && hasNumbers;

  /// Get list of validation status strings (returns localization keys)
  List<PasswordValidationRequirement> getRequirements() {
    return [
      PasswordValidationRequirement(
        label: 'at_least_8_chars',
        isValid: hasMinimumLength,
      ),
      PasswordValidationRequirement(
        label: 'contains_lowercase',
        isValid: hasLowercase,
      ),
      PasswordValidationRequirement(
        label: 'contains_uppercase',
        isValid: hasUppercase,
      ),
      PasswordValidationRequirement(
        label: 'contains_numbers',
        isValid: hasNumbers,
      ),
      PasswordValidationRequirement(
        label: 'contains_special',
        isValid: hasSpecialCharacters,
        isOptional: true,
      ),
    ];
  }
}

/// Single password validation requirement
class PasswordValidationRequirement {
  final String label;
  final bool isValid;
  final bool isOptional;

  PasswordValidationRequirement({
    required this.label,
    required this.isValid,
    this.isOptional = false,
  });
}

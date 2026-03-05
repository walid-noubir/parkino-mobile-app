import 'package:flutter/material.dart';
import '../services/password_validation_service.dart';

/// Widget that displays password validation requirements
/// Shows a checklist of password requirements with visual feedback
class PasswordRequirementsWidget extends StatelessWidget {
  final String password;
  final TextStyle? requirementTextStyle;
  final TextStyle? labelTextStyle;

  const PasswordRequirementsWidget({
    super.key,
    required this.password,
    this.requirementTextStyle,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final validation = PasswordValidationService.validatePassword(password);
    final requirements = validation.getRequirements();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Requirements',
          style: labelTextStyle ??
              TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...requirements.map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildRequirementRow(req, context),
        )),
      ],
    );
  }

  Widget _buildRequirementRow(
    PasswordValidationRequirement req,
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: req.isValid
                ? Colors.green.shade300
                : Colors.grey.shade300,
            border: Border.all(
              color: req.isValid
                  ? Colors.green.shade700
                  : Colors.grey.shade600,
              width: 1.5,
            ),
          ),
          child: req.isValid
              ? Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.green.shade700,
                )
              : Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            req.label,
            style: (requirementTextStyle ??
                    TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ))
                .copyWith(
              color: req.isValid ? Colors.green.shade900 : Colors.grey[700],
              fontWeight: req.isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        if (req.isOptional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Optional',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget that displays password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final Color? backgroundColor;
  final TextStyle? labelTextStyle;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.backgroundColor,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final strength = PasswordValidationService.calculatePasswordStrength(password);
    final label = PasswordValidationService.getPasswordStrengthLabel(strength);
    final colorString = PasswordValidationService.getPasswordStrengthColor(strength);

    final strengthColor = _getColorFromString(colorString);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password strength',
              style: labelTextStyle ??
                  TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 6,
            backgroundColor: backgroundColor ?? Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          ),
        ),
      ],
    );
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'amber':
        return Colors.amber;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

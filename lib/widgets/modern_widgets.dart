import 'package:flutter/material.dart';
import '../theme/parkino_theme.dart';

/// Modern Glass Card with Glassmorphism effect
/// 
/// Creates a beautiful glass-effect card that's modern and elegant.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double opacity;
  final VoidCallback? onTap;
  final bool showBorder;
  final BoxShadow? shadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.opacity = 0.08,
    this.onTap,
    this.showBorder = true,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: ParkinoTheme.white.withOpacity(opacity),
            borderRadius: borderRadius,
            border: showBorder
                ? Border.all(
                    color: ParkinoTheme.white.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
            boxShadow: shadow != null
                ? [shadow!]
                : [
                    BoxShadow(
                      color: ParkinoTheme.veryDarkGray.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Modern Gradient Card
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final LinearGradient? gradient;
  final List<BoxShadow> shadows;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double elevation;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.gradient,
    this.shadows = const [],
    this.onTap,
    this.backgroundColor = ParkinoTheme.white,
    this.elevation = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? backgroundColor : null,
            borderRadius: borderRadius,
            boxShadow: shadows.isNotEmpty
                ? shadows
                : [
                    BoxShadow(
                      color: ParkinoTheme.veryDarkGray.withOpacity(0.1),
                      blurRadius: elevation * 2,
                      offset: Offset(0, elevation),
                    ),
                  ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Modern Input Field with floating label animation
class ModernTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final Color focusColor;

  const ModernTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.focusColor = ParkinoTheme.goldenYellow,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: widget.focusColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, size: 20)
              : null,
          suffixIcon: widget.suffixIcon != null
              ? Icon(widget.suffixIcon, size: 20)
              : null,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}

/// Modern animated button with ripple effect
class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isOutlined;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = ParkinoTheme.goldenYellow,
    this.textColor = ParkinoTheme.primaryDarkBlue,
    this.height = 56,
    this.prefixIcon,
    this.suffixIcon,
    this.isOutlined = false,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPressed() {
    _animationController.forward().then((_) {
      _animationController.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: widget.isOutlined
            ? OutlinedButton(
                onPressed: widget.isLoading ? null : _onPressed,
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.textColor,
                          ),
                        ),
                      )
                    : _buildButtonContent(),
              )
            : ElevatedButton(
                onPressed: widget.isLoading ? null : _onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.backgroundColor,
                  foregroundColor: widget.textColor,
                ),
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.textColor,
                          ),
                        ),
                      )
                    : _buildButtonContent(),
              ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null) ...[
          Icon(widget.prefixIcon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: widget.isOutlined ? widget.textColor : null,
              ),
        ),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.suffixIcon, size: 20),
        ],
      ],
    );
  }
}

/// Modern stat card with animated counter
class ModernStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isAnimated;

  const ModernStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor = ParkinoTheme.goldenYellow,
    this.backgroundColor = ParkinoTheme.primaryDarkBlue,
    this.isAnimated = true,
  });

  @override
  State<ModernStatCard> createState() => _ModernStatCardState();
}

class _ModernStatCardState extends State<ModernStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _scaleAnimation =
          Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      );
      _opacityAnimation =
          Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
      );
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = ModernCard(
      backgroundColor: ParkinoTheme.white,
      padding: const EdgeInsets.all(16),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: 28,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                widget.unit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ParkinoTheme.darkGray,
                    ),
              ),
            ],
          ),
          Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    if (!widget.isAnimated) {
      return child;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      ),
    );
  }
}

/// Smooth divider
class ModernDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final Color color;
  final double height;

  const ModernDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.color = ParkinoTheme.mediumGray,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height / 2),
      child: Divider(
        indent: indent,
        endIndent: endIndent,
        color: color,
        thickness: 1,
      ),
    );
  }
}

import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

import '../art.dart';
import '../common.dart';

/// Glass text fields and buttons over a wallpaper.
class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State<SignInDemo> createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final muted = Colors.white.withValues(alpha: 0.75);
    return Scaffold(
      // Keep the wallpaper still while the keyboard opens; resizing it would
      // make the glass refract a moving background.
      resizeToAvoidBottomInset: false,
      body: GlassBackground(
        background: const SunsetWallpaper(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            24,
            padding.top + 12,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: GlassBackButton(),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue',
              style: TextStyle(fontSize: 16, color: muted),
            ),
            const SizedBox(height: 28),
            const _GlassField(
              icon: Icons.alternate_email_rounded,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _GlassField(
              icon: Icons.lock_outline_rounded,
              hint: 'Password',
              obscure: _obscure,
              trailing: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: muted,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('Forgot password?', style: TextStyle(color: muted)),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: SizedBox(
                height: 58,
                child: FigmaGlass(
                  settings: buttonGlass.copyWith(lightIntensity: 0.6),
                  borderRadius: BorderRadius.circular(29),
                  fill: Colors.white.withValues(alpha: 0.28),
                  strokeColor: Colors.white.withValues(alpha: 0.4),
                  child: const Center(
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final icon in const [
                  Icons.fingerprint_rounded,
                  Icons.qr_code_2_rounded,
                  Icons.key_rounded,
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox.square(
                      dimension: 56,
                      child: FigmaGlass(
                        settings: buttonGlass,
                        borderRadius: BorderRadius.circular(28),
                        fill: Colors.white.withValues(alpha: 0.1),
                        strokeColor: Colors.white.withValues(alpha: 0.2),
                        child: Icon(icon, size: 26),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
  });

  final IconData icon;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FigmaGlass(
        // Figma's "Sign-up input" values: strong edge refraction.
        settings: GlassSettings.input,
        borderRadius: BorderRadius.circular(18),
        fill: Colors.white.withValues(alpha: 0.06),
        strokeColor: Colors.white.withValues(alpha: 0.22),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Icon(icon, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                obscureText: obscure,
                keyboardType: keyboardType,
                cursorColor: Colors.white,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            ?trailing,
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

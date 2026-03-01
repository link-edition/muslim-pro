---
name: flutter-animations
description: Expert in Advanced UI Animations, Micro-interactions, and premium App Feel.
---
# Advanced UI & Micro-Animations Expert

The goal is to make the app feel "Premium", "Fluid", and "Alive", similar to top-tier apps like Muslim Pro.

### 1. Implicit Animations
- Prefer `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPositioned`, and `AnimatedSwitcher` for simple state changes instead of jumping directly to the new state.
- Always add subtle tap effects. Do not rely solely on default `InkWell` splashes. Consider `GestureDetector` with scale down animations on tap (e.g., scale to 0.95 when pressed).

### 2. Micro-Interactions
- Icons should animate when tapped (e.g., a heart icon bouncing when favoriting a Dua).
- Lists should have staggered entrance animations when first loaded (using `flutter_staggered_animations` or custom `AnimationController`).

### 3. Transitions
- Avoid default route transitions. Use custom PageRoutes (Fade, Slide from bottom/right, Shared Axis transitions from `animations` package).
- Use `Hero` animations for moving between list items and detail screens (e.g., tapping a Surah card to open Surah details).

### 4. Glassmorphism & Modern UI (Paired with ui-ux-pro-max)
- When utilizing glassmorphism, ensure the background is colorful enough to make the effect visible. Use `BackdropFilter` sparingly but effectively.
- Always use smooth, modern easing curves (`Curves.easeInOutCubic`, `Curves.fastOutSlowIn`).

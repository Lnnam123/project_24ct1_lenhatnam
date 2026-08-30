---
name: Modern Financial Intelligence
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e1e7ff'
  surface-container-highest: '#dae2fc'
  on-surface: '#131b2e'
  on-surface-variant: '#434655'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#712ae2'
  on-secondary: '#ffffff'
  secondary-container: '#8b4bfc'
  on-secondary-container: '#fffbff'
  tertiary: '#943700'
  on-tertiary: '#ffffff'
  tertiary-container: '#b44e1a'
  on-tertiary-container: '#ffece5'
  error: '#EF4444'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#eaddff'
  secondary-fixed-dim: '#d2bbff'
  on-secondary-fixed: '#25005a'
  on-secondary-fixed-variant: '#5a00c6'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fc'
  success: '#10B981'
  warning: '#F59E0B'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  numeric-data:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 20px
  gutter: 16px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
  section-padding: 32px
---

## Brand & Style

The design system is built on the pillars of **clarity, intelligence, and restraint**. As a fintech platform with integrated AI, the interface functions as a dependable, sophisticated assistant.

The chosen style is **Modern Minimalism**. By leveraging generous white space and a content-first hierarchy, the UI reduces the cognitive load associated with complex financial management. The aesthetic is professional and airy, utilizing subtle tonal shifts and refined geometry rather than heavy lines to define structure. This approach ensures that AI-driven insights are prioritized, fostering a sense of calm control and trust.

## Colors

The color palette is anchored by a trustworthy **Primary Blue (#2563eb)**, used for core actions and navigation to signify stability. To denote the "AI" layer of the product, a **Secondary Violet** is introduced, reserved for automated insights, smart categorization, and premium features.

The neutral palette leans toward cool slates to maintain a modern, technical feel, while the background remains predominantly white/off-white to maximize the "breathability" of the layout. High-contrast text ensures accessibility across various lighting conditions, which is critical for a mobile-first financial experience.

## Typography

**Manrope** is the sole typeface for this design system, providing a modern, geometric, and highly legible foundation across all digital touchpoints. Its balanced proportions offer a professional yet approachable tone.

- **Numeric Clarity:** For financial balances and data tables, always enable tabular figures (`tnum`) to ensure vertical alignment of digits.
- **Hierarchy:** Use bold weights for primary data points and balances to create immediate visual anchors.
- **Micro-copy:** Use medium weights (500-600) for small labels to ensure they remain crisp and readable on low-contrast surfaces.

## Layout & Spacing

This design system employs an **8px linear scale** to maintain rhythmic consistency. 

For mobile devices, a 20px horizontal safe margin is enforced. The layout relies on **Vertical Stacking** to organize information. Use `stack-lg` to separate distinct functional blocks (e.g., a "Current Balance" card from "Transaction History") and `stack-md` for related elements within those blocks. On larger screens, the grid expands to a 12-column layout with a fixed max-width to preserve readability of financial statements.

## Elevation & Depth

Depth is conveyed through **Soft Ambient Shadows** and **Tonal Layering** to create a structured but soft hierarchy.

- **Level 0 (Background):** The base surface (`#faf8ff`).
- **Level 1 (Cards/Containers):** Uses a diffused shadow with 15% opacity, tinted slightly by the primary color. This lifts the card away from the background without creating harsh edges.
- **Level 2 (Modals/Overlays):** Significant elevation with a 24px blur radius and a backdrop blur (glassmorphism effect) to isolate high-priority interactions.

Avoid using shadows on interactive components like buttons; instead, use distinct color fills to indicate state and affordance.

## Shapes

The shape language is **Rounded**, echoing the geometric nature of the Manrope typeface and providing a friendly, accessible feel to financial data.

- **Data Containers:** 1rem (`rounded-lg`) corner radius for standard cards.
- **Action Elements:** 0.75rem for buttons, providing a distinct but harmonious profile.
- **Categorization:** Use pill-shapes for chips and status indicators for instant recognition.

## Components

### Buttons
Primary buttons use a solid primary fill with white text. Secondary buttons utilize a subtle stroke or tonal background. Ensure the Manrope semibold weight is used for button labels to maintain clarity.

### Cards
Cards are the primary unit of information. They feature 20px of internal padding and a Level 1 shadow. Headers within cards should use `headline-md`.

### TextFields
Inputs use a minimalist design with a light-gray background and a 1px border. Upon focus, the border transitions to the primary blue. Labels are placed above the field using the `label-caps` style.

### AI Insight Component
Specialized cards that feature a subtle gradient (Primary to Secondary) and distinct iconography. These cards use the `numeric-data` style for highlighted metrics to distinguish automated insights from standard ledger entries.
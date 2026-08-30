---
name: CoinTap Visual Identity
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
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
  secondary-container: '#8a4cfc'
  on-secondary-container: '#fffbff'
  tertiary: '#943700'
  on-tertiary: '#ffffff'
  tertiary-container: '#bc4800'
  on-tertiary-container: '#ffede6'
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
  surface-variant: '#dae2fd'
  success: '#10B981'
  warning: '#F59E0B'
  surface-alt: '#F8FAFC'
  border-subtle: '#E2E8F0'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  numeric-data:
    fontFamily: Inter
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

The design system for this product is built on the pillars of **clarity, intelligence, and restraint**. As a personal finance app with AI integration, the UI must feel like a dependable assistant rather than a complex spreadsheet. 

The chosen style is **Modern Minimalism**. By leveraging generous white space and a "content-first" hierarchy, the interface reduces the cognitive load associated with financial management. The aesthetic is professional and airy, utilizing subtle tonal shifts rather than heavy lines to define structure. This approach ensures that AI-driven insights stand out as the most important elements on the screen, fostering a sense of calm control over one's finances.

## Colors

The color palette is anchored by a trustworthy **Primary Blue**, used for core actions and navigation. To signify the "AI" layer of the product, a **Secondary Violet** is introduced, reserved for automated insights, smart categorization, and premium features.

Functional colors (Success, Error, Warning) follow industry standards to ensure immediate recognition of financial health status. The neutral palette leans toward cool slates to maintain a modern, technical feel, while the background remains predominantly white to maximize the "breathability" of the layout. High-contrast text ensures accessibility across various lighting conditions, critical for a mobile-first experience.

## Typography

**Inter** is the sole typeface for this design system, chosen for its exceptional legibility on mobile screens and its neutral, "system-standard" aesthetic. 

- **Hierarchy:** Use bold weights and tight letter-spacing for large displays of financial balances. 
- **Numeric Clarity:** When displaying currency, utilize the `tnum` (tabular figures) OpenType feature to ensure numbers align vertically in lists and reports.
- **Micro-copy:** Small labels and captions use a medium weight to maintain legibility against light-gray backgrounds.

## Layout & Spacing

This design system employs an **8px linear scale** for all spacing and layout decisions. For mobile, a 20px safe margin is enforced on the horizontal axis to prevent content from feeling cramped against the device edges.

The layout philosophy relies on **Vertical Stacking**. Use `stack-lg` to separate distinct functional sections (e.g., "Monthly Budget" vs. "Recent Transactions") and `stack-md` for elements within a group. Content should be grouped within cards that span the full width of the safe area.

## Elevation & Depth

Depth is conveyed through **Soft Ambient Shadows** and **Tonal Layering** rather than heavy borders. 

- **Level 0 (Surface):** The main background (`#FFFFFF`).
- **Level 1 (Cards/Containers):** Utilizes a very soft, diffused shadow with a 15% opacity primary-tinted blur. This makes the cards appear as if they are floating slightly above the background.
- **Level 2 (Modals/Popovers):** Higher elevation with a larger blur radius (24px) and a subtle backdrop dimming to focus the user's attention.

Avoid using shadows for small interactive elements like buttons; use solid color fills to denote interactivity instead.

## Shapes

The shape language is consistently **Rounded**, providing a friendly and accessible feel to a potentially stressful subject like finance. 

- **Primary Containers:** Standardized 16px (`rounded-lg`) corner radius.
- **Buttons:** Use a 12px radius to maintain a distinct but harmonious profile against cards.
- **Small Elements:** Chips, tags, and icons utilize a 6px or fully pill-shaped radius for quick visual differentiation.

## Components

### Buttons
- **Primary:** Solid primary color fill with white text. High-emphasis for "Add Transaction" or "Save."
- **Secondary:** Surface-colored with a subtle border-subtle stroke. For less critical actions.
- **Ghost:** No background, primary-colored text. Used for "Cancel" or "See All."

### Cards
- Standard containers for financial data. Background is white with a Level 1 shadow. Internal padding is strictly 16px or 20px. 

### TextFields (Inputs)
- Clean, minimalist design. No bottom-line-only borders. Use a light-gray (`surface-alt`) background with a 1px border that becomes primary-colored on focus. Labels sit above the field in `label-caps` style.

### Chips & Badges
- Used for transaction categories (e.g., Food, Transport). Use a low-opacity background tint of the category color with a high-saturation text version for maximum legibility.

### AI Insight Component
- A specialized card using a subtle gradient background (Primary to Secondary) and the Secondary Violet for its iconography to distinguish automated intelligence from manual data.
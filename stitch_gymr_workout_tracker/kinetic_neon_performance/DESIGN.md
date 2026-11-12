---
name: Kinetic Neon Performance
colors:
  surface: '#121316'
  surface-dim: '#121316'
  surface-bright: '#38393c'
  surface-container-lowest: '#0d0e11'
  surface-container-low: '#1b1b1f'
  surface-container: '#1f1f23'
  surface-container-high: '#292a2d'
  surface-container-highest: '#343538'
  on-surface: '#e3e2e6'
  on-surface-variant: '#bbcbb8'
  inverse-surface: '#e3e2e6'
  inverse-on-surface: '#2f3034'
  outline: '#859583'
  outline-variant: '#3c4a3c'
  surface-tint: '#2ce368'
  primary: '#46f577'
  on-primary: '#003913'
  primary-container: '#10d85e'
  on-primary-container: '#005821'
  inverse-primary: '#006e2b'
  secondary: '#6bff83'
  on-secondary: '#003910'
  secondary-container: '#00e55a'
  on-secondary-container: '#006021'
  tertiary: '#3cf678'
  on-tertiary: '#003914'
  tertiary-container: '#00d861'
  on-tertiary-container: '#005823'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#69ff89'
  primary-fixed-dim: '#2ce368'
  on-primary-fixed: '#002108'
  on-primary-fixed-variant: '#00531f'
  secondary-fixed: '#6bff83'
  secondary-fixed-dim: '#00e55a'
  on-secondary-fixed: '#002107'
  on-secondary-fixed-variant: '#00531b'
  tertiary-fixed: '#67ff8c'
  tertiary-fixed-dim: '#19e469'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
  background: '#121316'
  on-background: '#e3e2e6'
  surface-variant: '#343538'
  neon-green-start: '#10D85E'
  neon-green-end: '#00DE64'
  neon-green-glow: rgba(16, 216, 94, 0.28)
  surface-base: '#0B0C0E'
  surface-card: '#131418'
  surface-elevated: '#1C1E24'
  surface-stroke: rgba(255, 255, 255, 0.07)
  text-primary: '#FFFFFF'
  text-secondary: '#8E939E'
  text-on-neon: '#0B150E'
  warning-amber: '#FFB800'
  error-red: '#FF4D4D'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 38px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  metric-display:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '800'
    lineHeight: 34px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system expresses athletic momentum, precision biometric tracking, and clean modern fitness performance. It blends an **OLED Dark Minimalist** architecture with energetic **Athletic Neon Accents**, creating an ultra-focused interface optimized for high-intensity training environments and rapid readability.

- **Deep Focus:** Pure, true-dark obsidian foundations reduce visual fatigue and maximize contrast on modern mobile displays.
- **Gymr Kinetic Energy:** The vivid electric green gradient from the brand emblem serves as the core catalyst—signaling motion, milestone achievements, and primary calls to action.
- **Precision Surfaces:** Crisp hairline boundaries, muted secondary surfaces, and disciplined atmospheric neon glows produce a high-tech instrument aesthetic without decorative clutter.

## Colors

The color system transitions from the previous volt-yellow palette to the energetic, multi-stop athletic neon green derived from the brand emblem (`#10D85E` through `#00DE64`).

### Hierarchy & Tiers
- **Canvas Base (`#0B0C0E`):** Pure deep charcoal-black ground layer engineered for OLED power efficiency and boundless contrast.
- **Card Containers (`#131418`):** The primary architectural surface for exercises, metrics, lists, and summary cards.
- **Elevated Controls (`#1C1E24`):** Interactive inputs, passive chips, search surfaces, and floating bottom navigation docks.
- **Primary Kinetic Accent (`#10D85E` / `#00E65B`):** Brand neon green reserved for key actions, progress tracks, active states, and focal metrics.
- **Athletic Gradient:** Use a linear transition (`linear-gradient(135deg, #10D85E 0%, #00DE64 100%)`) for hero buttons, active progress rings, and the signature center action trigger.
- **Text & Hierarchy:**
  - `text-primary` (`#FFFFFF`): For metric values, bold titles, and active tabs.
  - `text-secondary` (`#8E939E`): For unit markers (kg, reps, bpm), secondary captions, and inactive dates.
  - `text-on-neon` (`#0B150E`): Ultra-dark slate-green providing maximum WCAG contrast when placed over the neon green fills.

## Typography

Typography relies on **Plus Jakarta Sans** for crisp geometric structure and clear numerical tracking under motion.

- **Telemetry & Numbers:** `metric-display` is tuned for high-contrast counters, heartbeat tallies, workout timers, and repetition clusters.
- **Section Headers:** Bold `headline-md` and `headline-sm` establish quick visual hierarchy across modular exercise rows.
- **Metadata Badges:** `label-sm` utilizes uppercase tracking (`+0.5px`) for short athletic tags such as "TARGET SET", "CARDIO", and "COMPLETED".

## Layout & Spacing

A compact, thumb-driven layout system calibrated for handheld performance:

- **Baseline Step:** 4px incremental scale ensuring tight, aligned telemetry widgets.
- **Canvas Edge Margins:** `1.25rem` (20px) outer margin on mobile form factors, respecting screen corners, home indicators, and bezel perimeters.
- **Component Clustering:** Related data points (e.g., set reps and weight) use `space-xs` (4px) to `space-sm` (8px). Sibling workout cards maintain `space-md` (12px) separation, while major screen milestones use `space-xl` (24px).

## Elevation & Depth

Depth is established primarily via subtle tonal contrast and refined specular illumination rather than murky, unfocused drop shadows:

1. **Canvas Surface:** Flat ground `#0B0C0E`.
2. **Standard Surface (Cards):** `#131418` framed by a crisp hairline border (`1px solid rgba(255, 255, 255, 0.07)`).
3. **Elevated Surface (Inputs / Dock):** `#1C1E24` with zero drop shadow to preserve minimalistic clarity.
4. **Neon Bloom / Interactive Elevation:** Primary actions and hero metric rings use an energetic ambient glow: `box-shadow: 0px 8px 24px rgba(16, 216, 94, 0.28)`.
5. **Floating Action Trigger:** The brand centerpiece floating button elevates seamlessly above the navigation bar with a concentrated kinetic green halo.

## Shapes

The design system incorporates smooth, ergonomic radii that feel tactile and fluid:

- **Pills (`9999px`):** Used universally for primary CTA buttons, filter chips, calendar day toggles, and status markers.
- **Modular Cards (`16px–20px`):** Applied to telemetry summary widgets, workout blocks, and nested dashboards.
- **Media Thumbnails (`12px`):** Used for exercise movement previews and video thumbnails.
- **Circles (`9999px`):** Reserved for user avatars, step progress markers, icon containers, and floating triggers.

## Components

### Buttons
- **Primary CTA:** Fully rounded pill with the brand gradient (`linear-gradient(135deg, #10D85E 0%, #00DE64 100%)`), dark text (`#0B150E`), bold weight, and an energetic outer glow (`0 8px 24px rgba(16, 216, 94, 0.28)`).
- **Secondary / Ghost Button:** Pill shape with surface fill `#1C1E24`, white typography, and hairline border (`rgba(255, 255, 255, 0.08)`).
- **Icon Action Button:** Circular container (`44px x 44px` or `48px x 48px`), `#1C1E24` background with crisp white icon iconography.

### Metric Cards & Telemetry
- **Standard Card:** Background `#131418`, hairline stroke, featuring `headline-md` titles, `text-secondary` descriptions, and dynamic SVG progress rings tinted with `#10D85E`.
- **Hero Focus Card:** Dark surface punctuated by an active neon progress track or badge counter highlighting daily volume or training pace.

### Filter Chips & Navigation Tabs
- **Default State:** Pill shape, `#131418` fill, `#8E939E` label.
- **Active State:** Solid `#10D85E` or `#00E65B` fill with `#0B150E` text and icon, instantly communicating selection.

### Exercise & Workout List Items
- **Card Format:** Horizontal row using `#131418` fill, rounded corner radius (16px), containing a 60px rounded media thumbnail, bold exercise title, repetition metadata in `body-sm`, and an interactive completion checkmark or chevron.

### Date & Calendar Strip
- **Daily Unit:** Compact vertical pill containing day abbreviation and date numeral.
- **Active Day:** Filled in vibrant `#10D85E` with bold `#0B150E` text; non-active days use `#131418` with `#8E939E` muted text.

### Floating Bottom Navigation Bar
- **Base Dock:** Floating obsidian dock (`#131418`) with 20px bottom/side margins, blurred translucent backdrop, and hairline top border.
- **Center Action Button:** Prominent circular trigger containing the brand kinetic emblem, finished in `#10D85E` gradient with deep slate icon artwork.
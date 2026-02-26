---
name: design-system
description: Rules for generating professional UI designs consistent with the user's standards.
---

# Design System Rules

## General Philosophy
Follow minimalist and premium design principles inspired by Notion, Linear, Apple, and Stripe.
Never generate childish, colorful, or Material Design-standard UI.
Always reference the work of recognized designers such as Rauno Frímannsson and Adam Wathan.

## Typography
Default font: Plus Jakarta Sans — always use it unless explicitly told otherwise.
Never use system fonts or generic sans-serif unless specifically requested.

Typographic scale:
- Display: 48px / 700 weight / -0.02em letter-spacing
- H1: 36px / 700 weight / -0.02em
- H2: 28px / 600 weight / -0.01em
- H3: 22px / 600 weight / -0.01em
- H4: 18px / 500 weight / 0em
- Body Large: 16px / 400 weight / 0em / 1.6 line-height
- Body: 14px / 400 weight / 0em / 1.6 line-height
- Small / Caption: 12px / 400 weight / 0.01em
- Label: 12px / 500 weight / 0.04em / uppercase

Rules:
- Never use decorative or overly styled headings
- Never mix more than 2 font weights in the same component
- Always maintain consistent line-height across the UI

## Color System
Use neutral, sober palettes with a single accent color.
Avoid gradients, neon colors, and oversaturated tones.

Base palette structure:
- Background: #FFFFFF or #F9F9F9 (light) / #0F0F0F or #111111 (dark)
- Surface: #F4F4F5 (light) / #1A1A1A (dark)
- Border: #E4E4E7 (light) / #2A2A2A (dark)
- Text Primary: #09090B (light) / #FAFAFA (dark)
- Text Secondary: #71717A (light) / #A1A1AA (dark)
- Accent: one single brand color (e.g. #2563EB for blue)
- Accent Hover: slightly darker variant of accent
- Destructive: #EF4444
- Success: #22C55E
- Warning: #F59E0B

## Spacing — 4px Rule
All spacing must be multiples of 4px.
Base unit: 4px

Scale:
- 4px — xs (tight padding, icon gaps)
- 8px — sm (inner component padding)
- 12px — md-sm
- 16px — md (default padding)
- 24px — lg (section padding)
- 32px — xl
- 48px — 2xl
- 64px — 3xl (section gaps)
- 80px — 4xl (page-level spacing)

Never use arbitrary values like 5px, 7px, 13px, or 22px.

## Border Radius
Use moderate, professional border-radius values only.
- Small elements (badges, tags): 4px
- Buttons and inputs: 6px
- Cards and panels: 8px
- Modals and dialogs: 12px
- Avatars: 999px (circles only)

Never use pill-shaped buttons (border-radius: 9999px on rectangles).
Never use border-radius above 12px except for avatars and circular elements.

## Shadows
Use subtle, low-opacity shadows only.
- Level 1 (cards): 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)
- Level 2 (dropdowns, popovers): 0 4px 12px rgba(0,0,0,0.08)
- Level 3 (modals): 0 8px 24px rgba(0,0,0,0.12)

Never use hard, colored, or oversized shadows.

## Components

### Buttons
- Default padding: 8px 16px
- Font size: 14px / 500 weight
- Border-radius: 6px
- Always define: default, hover, active, disabled, and loading states
- Variants: Primary, Secondary (outlined), Ghost, Destructive, Icon Button

### Inputs & Forms
- Height: 36px (default) / 32px (compact)
- Border: 1px solid border color
- Border-radius: 6px
- Focus ring: 2px offset, accent color
- Always include: label, placeholder, helper text, error state

### Cards
- Border-radius: 8px
- Border: 1px solid border color
- Padding: 24px
- Shadow: Level 1
- No heavy gradients or decorative backgrounds

### Navigation
- Sidebar width: 240px (desktop)
- Nav item height: 36px
- Active state: subtle background (Surface color) + accent text
- Never use heavy active indicators like thick left borders or pill backgrounds

### Modals & Dialogs
- Max width: 480px (small) / 640px (medium) / 800px (large)
- Border-radius: 12px
- Always include: title, content, action buttons, close button
- Overlay: rgba(0,0,0,0.4) backdrop

## Icons
Default icon library: Tabler Icons — always use it unless explicitly told otherwise.
- Default size: 20px (inline) / 16px (compact) / 24px (standalone)
- Stroke width: 1.5px
- Never mix icon libraries in the same project

## Admin Dashboards (React Router v7)
For admin dashboard interfaces, always use ShadCN UI as the component base.
- Build on top of ShadCN components: Table, Dialog, DropdownMenu, Sheet, Tabs, Card, Badge, etc.
- Customize ShadCN tokens to match this design system (font, colors, radius, spacing)
- Never override ShadCN with a completely custom component when a ShadCN equivalent exists
- Always use Tabler Icons within ShadCN components

## Responsive Design
Always design mobile-first.
Breakpoints:
- sm: 640px
- md: 768px
- lg: 1024px
- xl: 1280px
- 2xl: 1536px

## Dark Mode
Always anticipate dark mode from the start.
Use CSS variables or Tailwind dark: variants.
Never hardcode color values — always reference design tokens.

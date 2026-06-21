# MoneyLens Design System (MLDS) v1.0 — Technical Specifications
## Internal Codename: Project AURA

MLDS is a standalone design package designed to support years of future application development. MoneyLens is simply the first client. Future applications will import MLDS as a core dependency.

---

## 1. Expanded Architecture Folder Structure

```
lib/design_system/
├── foundations/         # Atomic design tokens (Colors, Typography, Spacing, Radius)
├── theme/               # Light/Dark themes and ThemeExtensions
├── components/          # Reusable UI component stubs (MLButton, MLCard, MLInput, MLText, MLMoneyDisplay, FCS stubs)
├── layouts/             # Multi-product Page, Section, Grid, Scaffold boundaries
├── animations/          # Spring physics transitions, haptics, and triggers
├── feedback/            # Banner, alert, snackbar, empty state modules
├── effects/             # backdrop sigmas, liquid glass effect, brand gradients
├── navigation/          # Menu tabs, navigation rails, app bars
├── playground/          # Laboratory gallery page for live previewing
└── docs/
    └── MLDS.md          # This master architecture guide
```

---

## 2. Component & Layout Roadmaps

### Component Library Roadmap
Every atomic widget follows a typesafe factory pattern, avoiding custom internal configurations:
*   `MLButton`: Primary (solid fill), Secondary (outlined), Text (borderless subtle action).
*   `MLCard`: Standard (soft background border), Elevated (tactile shadows), Glass (back-blurred liquid glass).
*   `MLInput`: Text (standard input box), Number (currency formatted with suffix options).
*   `MLDialog`: Quick confirmation modals (`MLDialog.confirm`) and info alerts (`MLDialog.alert`).
*   `MLSheet`: Modal sheets using spring slide-ups, dimming background by scaling main layout by `0.95`.
*   `MLChip`: Categorical selection tags and toggles.
*   `MLListTile`: Standardized lists including Transaction history rows and navigation Menu lists.
*   `MLChart`: Donut summaries and historical spline charts.
*   `MLText`: Typesafe semantic text constructor wrapping typography tokens.
*   `MLMoneyDisplay`: Segmented rich formatting of financial figures with proportional weights.

### Layout System Roadmap
Provides standard layout constraints across the screen tree:
*   `MLScaffold`: Root scaffolding wrapping the screen in backdrop filters and transitions.
*   `MLPage`: Standard page margins (`MLSpacing.pagePadding`) and layout spacing.
*   `MLSection`: Visual sections separating dashboards with vertical headers.
*   `MLGrid`: Adaptive columns for widgets, scaling grids contextually.

---

## 3. Financial Typography System (FTS)

Typography in MoneyLens represents the core emotional channel. Rather than viewing text as static pixels, FTS defines specific guidelines on how numbers, letters, and currency tokens establish visual authority, reduce user anxiety, and build trust.

### A. Font Strategy
MoneyLens employs exactly **two** fonts to minimize cognitive friction:
1.  **Inter (Primary Font)**: Used for all readable content including money, transactions, dialogs, analytics labels, and forms.
2.  **NothingDotMatrix (Secondary Font)**: Used only for small uppercase metadata, status tags, and timeline labels. Monospace style inspired by industrial mechanical clocks. **Never** used for paragraphs, currency values, or descriptions.

### B. Financial Typography Rules
Money must always be easier to read than words. FTS enforces a strict hierarchical weight structure on currency values:
*   **Currency Symbol (₹, $, €)**: Rendered slightly smaller (`fontSize * 0.65` to `0.8` of the base size) and in medium weight to give background context rather than distracting from the magnitude.
*   **Main Amount (Integer)**: Largest size, highest weight, high visual priority.
*   **Decimals (.50, .00)**: Reduced emphasis (`fontSize * 0.6` to `0.75` of the base size) and slightly muted opacity (`0.7`) to clear visual noise.
*   **Thousands Separator**: Must be clearly visible (e.g. `48,520` instead of `48520`).
*   **Tabular Figures**: All financial numbers must use `FontFeature.tabularFigures()` to keep digits aligned in columns. This prevents characters from jumping horizontally during budget increases or balance sweeps.

```
Example Hierarchy:
[ ₹ ] (Medium/Smaller)   [ 48,520 ] (Bold/Hero)   [ .50 ] (Regular/Smaller/Muted)
```

---

## 4. Emotional Color System (ECS)

MoneyLens users should never consciously notice the color system. ECS establishes a calming, premium environment designed to reduce financial stress and encourage rational, long-term behavior.

### A. Color Psychology Mapping
Every semantic color serves an emotional, non-decorative purpose:
*   **Primary (Trust & Confidence)**: Deep rich blue. Establishes stability and acts as the interactive focus target.
*   **Secondary (Hierarchy)**: Dark violet. Supports primary actions, navigation tags, and minor interactive states.
*   **Income (Hope & Growth)**: Soft emerald green. Avoids bright neon or casino-style excitement, representing progress and security.
*   **Expense (Awareness & Reflection)**: Soft crimson red. Avoids aggressive warning tones, inviting reflection rather than inducing fear or shame.
*   **Budget (Discipline & Balance)**: Calm cyan. Communicates structure and boundaries.
*   **Savings (Peace & Security)**: Soft teal. Represents future security and calm progress.
*   **Warning (Attention, Not Panic)**: Muted warm amber. Tells the user to look closer without causing panic.
*   **Error (Correction, Not Failure)**: Deep rust red. Guides the user to adjust input without invoking shame.
*   **Success (Calm Satisfaction)**: Calmed green. A quiet celebration of completion.

### B. Surface System & Elevation
Surfaces use a strict layering pattern to communicate containment and depth:
1.  **Scaffold Background (`scaffoldBackgroundColor`)**:
    *   *Light Mode*: Soft grey (`0xFFF9F9F9`) to feel fresh and spacious.
    *   *Dark Mode*: Pure pitch black (`0xFF000000`) for absolute contrast, OLED efficiency, and relaxed eyes.
2.  **Surface Card (`surfaceCard`)**:
    *   *Light Mode*: Crisp pure white (`0xFFFFFFFF`).
    *   *Dark Mode*: Dark charcoal (`0xFF121212`) to act as the primary containment layer.

---

## 5. Financial Interaction Language (FIL)

FIL dictates how MoneyLens behaves. All movement inside Project AURA must follow physical momentum, predict structural changes, reduce visual noise, and reinforce trust.

### A. Core Motion Principles
1.  **Motion Has Purpose**: Every transition answers the question: *"What changed?"* We never animate purely for decoration.
2.  **Motion Explains State Change**: Spatial continuity guides transitions (e.g., card expanding smoothly into detail views).
3.  **Motion Reduces Cognitive Load**: Layout shifts are gradual rather than abrupt. We use staged staggered entrances for lists and dashboards.
4.  **Motion Never Delays Users**: Durations remain short (`150ms` – `350ms`) to feel highly responsive. User interaction instantly interrupts active transitions.
5.  **Motion Feels Physical**: Mass, damping, and inertia dictate momentum. Easing curves utilize overshoot springs instead of linear loops.
6.  **Motion Respects Accessibility**: Support for system-wide Reduced Motion scales down slide distances and turns off spring scaling, falling back to simple fades.
7.  **Motion Uses Unified Tokens**: All timings match `MLDuration` and `MLCurves` tokens to maintain visual harmony.

### B. Physicality & Gesture Language
*   **Tactile Button Springs**: Pressing a button scales it down (`scale: 0.98`), mimicking physical key compression. Releasing triggers a spring-back overshoot bounce.
*   **Card Lifting**: Touching a card lifts it slightly (`translateY: -2.0`), scaling it by `1.01` and increasing shadow diffusion, indicating a draggable layer.
*   **iOS-Style Sheet Resistance**: Dragging bottom sheets incorporates elastic drag resistance beyond bounds and velocity-based snaps.
*   **Haptic Patterns**: Tactical vibrations are mapped semantically to confirm actions without spamming (Double light tap for Success, Medium-Heavy pattern for Warnings, Single click for selections).

---

## 6. Financial Component System (FCS)

FCS defines the modular layout system. FCS establishes a strict three-tier classification of UI modules to support multi-product reuse and ensure absolute consistency.

### A. Component Hierarchy Layers
1.  **Layer 1: Primitive Components (`primitives.dart`)**:
    *   The atomic building blocks. These widgets wrap basic Flutter gestures and elements without complex business dependencies (e.g. `MLIconButton`, `MLSurface`, `MLBadge`, `MLAvatar`, `MLFAB`, `MLProgressIndicator`, `MLSwitch`, `MLCheckbox`).
2.  **Layer 2: Composite Components (`composites.dart`)**:
    *   Combinations of primitive blocks forming functional modules (e.g. `MLAppBar`, `MLSectionHeader`, `MLToolbar`, `MLDateSelector`, `MLStatistic`, `MLTimeline`, `MLStepper`, `MLCarousel`, `MLConfirmationSheet`).
3.  **Layer 3: Financial Components (`financial.dart`)**:
    *   Domain-specific layout structures defining the core MoneyLens interface identity (e.g. `MLHeroBalance`, `MLBalanceCard`, `MLIncomeCard`, `MLExpenseCard`, `MLCashFlowCard`, `MLBudgetPlanCard`, `MLBudgetRing`, `MLTransactionCard`, `MLQuickActionCard`, `MLInsightCard`).

### B. Naming & Class Rules
*   **Prefix**: All components must be prefixed with `ML` (e.g. `MLButton`, `MLCard`, `MLAppBar`).
*   **Semantic Factories**: Component APIs must read like natural language (e.g. `MLButton.primary()`, `MLCard.glass()`, `MLDialog.confirm()`, `MLText.heading()`).
*   **Zero Hardcoding**: All properties (margins, color fields, typography weights, shadow depths, animation easing) must be inherited from MLDS foundations. Custom hex values or raw padding coordinates are prohibited.

### C. Accessibility & State Integration
*   **TalkBack & VoiceOver Semantics**: Components register proper `Semantics` descriptors, reading full currency amounts (e.g. "Forty-eight thousand five hundred twenty Rupees") instead of isolated characters.
*   **Focus States**: Keyboards and screen readers trigger visible focus rings when selecting interactive modules.
*   **State Automation**: Components automatically resolve states (Idle, Pressed, Focused, Hovered, Disabled, Loading, Offline) using context extensions, avoiding manual handling inside page builders.

### D. Golden & Automated Testing Strategy
To guarantee component integrity and backward compatibility:
*   **Widget & Golden Tests**: Components must run automated layout golden captures in Light, Dark, and High Contrast configurations.
*   **Reduced Motion Tests**: Verify that slide transitions revert to opacity fades when system flags are active.
*   **Touch Target Audit**: Verify that all interactive elements meet the minimum WCAG touch target guideline of `48x48dp`.

### E. Migration Guide
To cleanly integrate FCS into MoneyLens, developers must systematically swap direct Material widget dependencies:
1.  Replace raw `ElevatedButton` and `OutlinedButton` with `MLButton.primary()` and `MLButton.secondary()`.
2.  Replace raw `Card` and custom container boundaries with `MLCard.standard()` or `MLSurface()`.
3.  Replace raw `Text` and `TextStyle` configurations with semantic `MLText` builders.
4.  Replace raw double parse formatting with `MLMoneyDisplay`.
5.  Run static verification (`flutter analyze`) to confirm 100% token usage.

---

## 7. Component Preview Laboratory & Inspector

The `playground/gallery.dart` screen houses the **MLDS Design Gallery** allowing developers to test typography, colors, motion, and components:
*   **Typography Laboratory**: Live preview of Inter and Dot Matrix scales.
*   **Color Laboratory**: Live check of surface overlays, budgets, and seasons.
*   **Motion Laboratory**: Preview scale compression, card lifts, haptic players, and skeletons.
*   **Component Laboratory & Inspector**: Live visual mocks of primitives, composites, and financial elements. Tapping the selector triggers `MLComponentInspector` displaying tokens used, accessibility guidelines, and raw code examples.

---

## 8. Financial Layout System (FLS)

FLS defines the physical structure and spatial layout rules of the Project AURA ecosystem. Developers do not manually organize rows, columns, or layout paddings; instead, they compose layouts using slot-based semantic grids, base structural wrappers, and responsive page templates.

### A. Layout Philosophy
Every layout should act as an information filter. It must reduce cognitive overload by guiding the user's eye from high-priority summaries to secondary granular statements.
*   **Predictability**: Standard components always occupy consistent spatial slots.
*   **Responsive Engine**: Screens dynamically restructure content layout across phone, tablet, foldable, and desktop widths.
*   **Spatial Rhythm**: Grid systems run on a strict 8dp layout scale, matching semantic tokens: `MLSpacing.pagePadding`, `MLSpacing.cardPadding`, `MLSpacing.listSpacing`, and `MLSpacing.formSpacing`.

### B. Core Base Elements
*   `MLScaffold`: Root scaffolding wrapping pages in default backdrops and normal slide-and-fade entrance transitions (which fall back to opacity fades under reduced motion).
*   `MLPage` & `MLScrollablePage`: Viewport bounds enforcing standard page paddings. `MLScrollablePage` includes automated vertical spacing intervals.
*   `MLSection` & `MLSectionGroup`: Structure sections with title headers, trailing helper widgets, and vertical separation rhythms.
*   `MLFloatingContainer` & `MLInsetContainer`: Containers handling elevation depth layering and inner border-radius geometry.
*   `MLStickyHeader` & `MLStickyFooter`: Glue actions and summaries to screen boundaries while accounting for system safe area parameters.

### C. Responsive Grid System
MLDS enforces a dynamic layout matrix mapping the screen width (`MediaQuery` constraints) directly to `MLBreakpoints`:
*   `phone` (< 600dp): 4 columns. Stacked single-pane configurations.
*   `foldable` (>= 600dp) / `tablet` (>= 768dp): 8 columns. Split dual-pane workspace configurations.
*   `desktop` (>= 1024dp): 12 columns. Multi-column workspace pane structures.

### D. Slot-Based Page Templates & Builders
FLS introduces expressive layout builders that accept specific named widgets for defined slots:
1.  **`MLDashboardLayout`**: Home summary structures.
    *   *Slots*: `header`, `balance`, `quickActions`, `budgets`, `insights`, `transactions`, `bottomNavigation`.
    *   *Responsive Behavior*: Multi-column row distributions on tablet and desktop.
2.  **`MLAnalyticsLayout`**: Interactive visualization charts.
    *   *Slots*: `header`, `rangeSelector`, `primaryChart`, `breakdown`, `insights`, `bottomNavigation`.
    *   *Responsive Behavior*: Wide chart area alongside breakdowns and recommendation tiles.
3.  **`MLTransactionLayout`**: Ledger listing layout.
    *   *Slots*: `header`, `searchBar`, `filterBar`, `transactionList`, `bottomNavigation`.
    *   *Responsive Behavior*: Docked filter panels on larger screen viewports.
4.  **`MLBudgetLayout`**: Threshold limits and gauges.
    *   *Slots*: `header`, `totalProgress`, `budgetList`, `budgetAlerts`, `bottomNavigation`.
5.  **`MLSettingsLayout`**: Preference option grouping.
    *   *Slots*: `header`, `profileCard`, `settingsTiles`, `footer`.
6.  **`MLAuthenticationLayout`**: Secure Pin keypad layouts.
    *   *Slots*: `logo`, `pinPad`, `recoveryActions`, `header`.

### E. Additional Structural Templates
*   `MLWizardLayout`: Structures progressive multi-step flows (Onboarding, CSV imports).
*   `MLSearchLayout`: Handles query input, chip tags, list results, and centers custom empty states.
*   `MLEmptyLayout`: Centers illustrative vectors, main messages, and actionable triggers for zero-states.
*   `MLFormLayout`: Manages inputs with sticky primary buttons.
*   `MLReportLayout`: Structures metrics grids, charts, and audit paragraphs.

### F. Best Practices (Do\'s & Don\'ts)
*   **Do**:
    *   Ensure all components are placed inside semantic slots.
    *   Use `MLResponsiveContainer` to define distinct layouts for different form factors.
    *   Bind margins and column gap metrics using the `MLSpacing` tokens.
*   **Don\'t**:
    *   Nesting custom `Padding` or hardcoded sizes to align cards.
    *   Overlay multiple visual Hero summaries per page.
    *   Forget to structure TalkBack accessibility focus paths inside responsive layouts.

### G. Migration Strategy
To adopt FLS in the client applications:
1.  Identify custom scrollable or list views and replace them with `MLScrollablePage`.
2.  Refactor existing page scaffolds to use `MLScaffold`.
3.  Rewrite page screens by passing existing widgets into the slot-based constructors (e.g. `MLDashboardLayout`, `MLSettingsLayout`) rather than custom `Column` layouts.


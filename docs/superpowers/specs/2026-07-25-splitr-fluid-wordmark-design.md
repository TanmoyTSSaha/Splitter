# Splitr Fluid Wordmark Splash — Design Spec

## Requirements

- Soft goo bleed (Sentry-inspired color melt during draw)
- Filled glyphs with left→right reveal per color pass
- Ghost base: `AppPalette.recapMutedFill` (#F5F5F7)
- 3-color sliding chain: C1 purple → C2 teal → C3 pink
- End: all letters C3, then fade to `groupOnSurface` black
- Splash: play once, navigate on animation complete
- Debug preview: full cycle loop with hold between iterations

## Letter order

| Index | Path ID | Letter |
|-------|---------|--------|
| 0 | g0_p2 | S |
| 1 | g0_p1 | p |
| 2 | g0_p0 | l |
| 3 | g1_p2 | i |
| 4 | g1_p1 | t |
| 5 | g1_p0 | r |
| 6 | g2_p0 | . |

## Timeline

- `staggerMs = 95`
- `passMs = 140`
- `holdAllPinkMs = 120`
- `blackFadeMs = 180`
- Fluid chain ends at 900ms; total 1200ms

## Paint pipeline

1. Ghost fills (all letters, grey)
2. Goo layer (`saveLayer` + blur) with per-letter color pass fills
3. Optional sharp mask clip
4. Black fade overlay

## Files

- `lib/Widgets/splitr_fluid_wordmark_timeline.dart`
- `lib/Widgets/splitr_fluid_wordmark_painter.dart`
- `lib/Widgets/splitr_stroke_wordmark.dart` (widget shell)

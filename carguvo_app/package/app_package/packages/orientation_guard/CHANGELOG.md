# CHANGELOG: orientation_guard 🛡️

## 1.1.0 (2026-05-08)
- **Active Transition Protection**: Added `isApplying` property to `OrientationController` and `PlatformOrientationController`.
- **Flicker Suppression**: Updated `OrientationGuard` to automatically suppress mismatch warnings while an orientation change is in progress.
- **Redundancy Protection**: Enhanced `restore` method to skip unnecessary orientation changes if the target policy is already active, preventing "double-rotation" jitter on iPad.
- **Lifecycle Safety**: Implemented safe listener notifications to avoid Flutter's "setState() when locked" errors during widget disposal.
- **Experience Classifier**: Added `OrientationExperience` to categorize devices (mobile, tablet, desktop) for better policy resolution.
- **Improved Configuration**: Introduced `OrientationGuardConfig` for better global control and debug testing.

## 1.0.0 (2026-03-31)
- Initial release of the `orientation_guard` package.
- Unified orientation control across **Native (Mobile)** and **Web**.
- Added `OrientationGuard` widget for mounted-life orientation enforcement.
- Added `GlobalOrientationOrchestrator` for application-wide defaults.
- Added `OrientationMismatchView` with Vietnamese translations.
- Support for `SystemUiMode.immersiveSticky`.
- Clean architecture with `InheritedWidget` provider.

# AGENTS.md: SimpleEditTests

Unit tests for SimpleEdit, written with Swift Testing (`import Testing`, `@Test`, `#expect`). Project-wide guidance is in [../AGENTS.md](../AGENTS.md).

## Contents

- `SimpleEditDocumentTests.swift`: the document model (`SimpleEditDocument`): defaults, `originalText` and `revert()`, UTF-8 decoding, filename and editability, invalid UTF-8 throwing `CocoaError.fileReadCorruptFile`, and readable content types.

## Current state: the target does not link

`SimpleEditTests` has no `TEST_HOST` or `BUNDLE_LOADER`, so `@testable import SimpleEdit` compiles but the link fails. Verified 2026-10-08 with:

```bash
xcodebuild build-for-testing -project SimpleEdit.xcodeproj -scheme SimpleEditTests -destination 'generic/platform=iOS Simulator'
```

The result was `TEST BUILD FAILED` with `Undefined symbols for architecture arm64` for `SimpleEdit.SimpleEditDocument` members (`defaultFileName`, `readableContentTypes`, `init(data:filename:isSafelyEditable:)`).

- The shared `SimpleEditTests` scheme runs this target through `SimpleEditTests.xctestplan` (serial, `parallelizable: false`). It was added on 2026-10-08, shortly after the failure above was seen, and a build on that scheme at 12:34 still failed with the same undefined symbols.
- The `SimpleEdit` scheme's test action uses the UI test plan, so it does not run these tests, and a green build of the `SimpleEdit` scheme says nothing about them.
- Fix the target's host application and bundle loader through Xcode or the Xcode MCP. Do not hand-edit `project.pbxproj`, and do not add per-target overrides for deployment target, Swift version or isolation.
- Until it is fixed, `RunSomeTests` cannot run these tests.
- Check the active scheme with `XcodeListSchemes` first. Tests for the UI target fail with "not found in test plan" while this scheme is active.

## Conventions

- Prefer Swift Testing for new tests; use `@Test(arguments:)` for tables of cases, as `invalidUTF8Throws` does.
- Default actor isolation is `nonisolated` and `SimpleEditDocument` is `nonisolated`, so these tests need no `@MainActor`.

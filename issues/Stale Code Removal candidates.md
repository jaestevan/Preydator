1. High severity: Legacy inspect implementation appears unreferenced and duplicated (**GATED FOR TEST**)
- Evidence:
  - Preydator.lua defines PrintInspectState.
  - Preydator.lua defines SendInspectReportToErrorHandler used by that path.
  - No slash-command branch in Preydator.lua calls PrintInspectState.
  - Active inspect routing is in DebugInspect.lua.
- Why this matters:
  - This is stale diagnostic code with substantial surface area and can drift from the real inspect tool behavior.
- Risk of removing:
  - Medium.
  - Functionally likely safe today, but there is slight fallback risk if debug module loading/registration fails in some environment.
  - Current action: legacy path is temporarily gated/disabled in Preydator.lua for breakage testing rather than deleted.

2. Medium severity: Unused color picker helper in CurrencyTracker (**COMPLETED**)
- Evidence:
  - Definition was at CurrencyTracker.lua.
  - No call sites were found in the file/workspace.
  - Helper has now been removed.
- Why this matters:
  - Dead utility increases maintenance burden and confuses future edits.
- Risk of removing:
  - Low.
  - Straightforward dead-code candidate.

3. Medium severity: Dead compatibility branch to non-existent module path (**COMPLETED**)
- Evidence:
  - HuntScanner.lua previously tried ZoneGateV2 via Preydator:GetModule("ZoneGateV2").
  - No ZoneGateV2 module exists in workspace.
  - Branch has now been removed.
- Why this matters:
  - Extra branch complexity for a module that is not present.
- Risk of removing:
  - Medium.
  - Safe for current repo state, but keep if you plan to reintroduce ZoneGateV2 externally.

4. Low severity: Duplicate helper implementations across modules (not dead, but stale design duplication) (**COMPLETED**)
- Evidence:
  - Clamp/round/normalize duplication between Settings.lua and EditMode.lua has been refactored to shared API helpers.
  - UI factories (CreateCheckbox/CreateSlider) are now consolidated into shared API helpers and adopted by both Settings.lua and EditMode.lua.
- Why this matters:
  - Not unused, but higher drift risk and inconsistent behavior over time.
- Risk of removing:
  - High if removed directly; low if refactored to shared utility first.

No-findings corrections versus earlier scan:
- FindPinByQuestID is active and should not be treated as stale:
  - Defined at HuntScanner.lua
  - Used at HuntScanner.lua, HuntScanner.lua, HuntScanner.lua.

Remaining scope:
1. Monitor one test cycle with legacy inspect path gated; if no regressions, remove dead implementation body in a follow-up cleanup.
2. Start 200-local-cap safety cleanup in `Preydator.lua`:
  - Prioritize moving inspect/report assembly and slash parsing helpers into dedicated module-level files.
  - Prefer shared API helpers over per-chunk local helper duplication.
  - Keep behavior identical while reducing local-variable pressure to avoid recurring cap collisions.

Optimization note:
- Core is stable enough to run a surgical optimization pass focused on compile safety + maintainability, not feature behavior changes.

Completed in this cycle:
1. Removed unused CurrencyTracker OpenColorPicker helper.
2. Removed stale HuntScanner ZoneGateV2 compatibility branch.
3. Refactored Clamp/RoundToStep/NormalizeSliderValue to shared Preydator.API helpers and adopted in Settings/EditMode.
4. Consolidated CreateCheckbox/CreateSlider into shared Preydator.API helpers and adopted in Settings/EditMode.
5. Gated legacy Preydator.lua inspect path for medium-risk safety testing.
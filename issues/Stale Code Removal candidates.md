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

Current status:
1. Bloody Command migration and stale routing cleanup are complete:
  - Chat-only trigger path is active.
  - Aura-path registration/helpers were removed.
  - EventRuntime stale signal references were removed.
2. Bloody Command debug-noise controls are complete:
  - `debugBloodyCommand` setting exists.
  - Advanced UI toggle exists.
  - Verbose gate/skip logs are gated behind the toggle.
3. Widget-update early-filter optimization is complete:
  - Relevance gate for `UPDATE_UI_WIDGET` is active.
  - Tracked prey widget ID is persisted in runtime state for filtering.

Completed in this cycle:
1. Removed unused CurrencyTracker OpenColorPicker helper.
2. Removed stale HuntScanner ZoneGateV2 compatibility branch.
3. Refactored Clamp/RoundToStep/NormalizeSliderValue to shared Preydator.API helpers and adopted in Settings/EditMode.
4. Consolidated CreateCheckbox/CreateSlider into shared Preydator.API helpers and adopted in Settings/EditMode.
5. Gated legacy Preydator.lua inspect path for medium-risk safety testing.
6. Removed Bloody Command UNIT_AURA path and stale aura state/helpers; chat trigger is now the only alert source.
7. Added `debugBloodyCommand` setting, Advanced UI toggle, and verbose-log gating so default debug output stays concise.
8. Completed EventRuntime stale-signal cleanup for chat-only Bloody Command by removing aura references and aligning event-ownership comments.
9. Added widget-update early-filter optimization: irrelevant `UPDATE_UI_WIDGET` payloads now short-circuit before module fanout and prey-state refresh work.

Regression test matrix (minimum):
1. In-zone prey active, stages 1->4 progression updates normally.
2. Delve entry while prey active: no hunt scanner panel churn, no prey alert spam.
3. Delve exit: prey state refresh resumes correctly.
4. Bloody Command line from Astalor at Nightmare stage 2+: alert fires.
5. Same line at stage 1 or non-Nightmare: alert does not fire.
6. Debug on, `debugBloodyCommand` off: concise logging only.
7. Debug on, `debugBloodyCommand` on: verbose gate logs present.

In-game validation run sheet (manual):
- Build target: `2.1.1`
- Test date: `__________`
- Tester/client locale: `__________`

1. Case 1 (in-zone stage progression): `PASS | FAIL | N/A`  Notes: `__Pass________`
2. Case 2 (delve entry/no churn): `PASS | FAIL | N/A`  Notes: `_Pass_________`
3. Case 3 (delve exit recovery): `PASS | FAIL | N/A`  Notes: `_Pass_________`
4. Case 4 (Bloody Command valid gate): `PASS | FAIL | N/A`  Notes: `__________`
5. Case 5 (Bloody Command invalid gate): `PASS | FAIL | N/A`  Notes: `__________`
6. Case 6 (`debugBloodyCommand` off concise logs): `PASS | FAIL | N/A`  Notes: `__________`
7. Case 7 (`debugBloodyCommand` on verbose logs): `PASS | FAIL | N/A`  Notes: `__________`
8. Case 8 (PowerBar widget set ID narrowing — widget detection valid): With prey active and `disableDefaultPreyIcon` off, confirm the bar still shows correct stage progression. No Lua errors expected. If BugSack is clean and bar progresses, set ID narrowing is working. `PASS | FAIL | N/A`  Notes: `__________`
9. Case 9 (Mixin suppression hook — hide Blizzard prey icon): Enable `Disable Default Prey Icon`, activate a prey quest, and verify the Blizzard prey icon widget on the PowerBar is hidden/invisible. Re-enable the setting and confirm it re-appears. `PASS | FAIL | N/A`  Notes: `__________`
10. Case 10 (`Blizzard_UIWidgets` readiness gate): On a fresh login with no previously-cached widget data, verify that prey widget detection and icon suppression both take effect within the first `UPDATE_UI_WIDGET` tick after entering the prey zone. No "attempt to index nil" or "GetAllWidgetsBySetID" errors in BugSack. `PASS | FAIL | N/A`  Notes: `__________`

Quick execution notes:
1. Toggle debug in `Options > Addons > Preydator > Default Settings > Debug`.
2. Keep `Enable Debug` on for cases 6-7.
3. Flip `Verbose Bloody Command Debug` off/on between cases 6 and 7.
4. Capture one BugSack report or chat-log snippet for case 7 to confirm gated verbose lines.
5. For case 8, watch BugSack through one full prey-widget scan cycle (enter zone, open world map).
6. For case 9, toggle `Disable Default Prey Icon` on/off while prey is active. Blizzard icon should hide immediately and re-appear on disable.
7. For case 10, test immediately after `/reload` with prey active to confirm no nil-widget errors before the first widget refresh.

Remaining follow-up:
1. Fill the manual run-sheet results above and summarize pass/fail in `CHANGELOG.md` before packaging.
2. Revisit legacy inspect path cleanup after one stable validation cycle.
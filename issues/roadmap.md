### Preydator Expansion Roadmap (Issue: Roadmap)

## Status (as of v1.7.3)

- Epic 1: Approved Currency Ledger (MVP) - Completed
- Epic 2: Hunt Source Scanner - Planned
- Epic 3: Weekly Hunt Cap Tracker - In progress
- Epic 4: Prey Achievement Gap Highlighter - Planned
- Epic 5: Reward Intelligence and Cost Context - In progress
- Epic 6: Localization for other Languages - Completed (infrastructure + 10 stubs; seeking community translators)

Completed for Epic 1:

- Approved allow-list currency tracking implemented for `3392`, `3316`, `3383`, `3341`, `3343`
- Session delta tracking and known-warband aggregation
- Currency tracker and warband windows with sortable currency table
- Currencies settings controls for tracked IDs, theme, layout, and delta colors

## Scope Correction

This roadmap is for Midnight Prey systems.

Confirmed direction from project owner:

1. Primary tracked currency is Remnant of Anguish (CurrencyID 3392).
2. Prey progression and hunt systems are Midnight-specific.
3. Avoid tracking unknown/secret Blizzard currencies or hidden Midnight systems.
4. Prey achievements live under Achievement categories: Expansion Features > Prey.

Source references:

- https://www.wowhead.com/currency=3392/remnant-of-anguish
- https://www.wowhead.com/guide/midnight/prey-unlocking-hunts-rewards

## Objective

Expand Preydator from a stage-audio tracker into a focused Midnight Prey companion that helps players:

1. Track approved Prey currency and session deltas.
2. See available hunt choices when interacting with hunt sources.
3. Prioritize missing Prey achievements.
4. Compare hunt rewards and weekly lockout progress by difficulty.
5. Maintain warband/character visibility for approved data only.

## Rules and Guardrails

1. Tracked currency list must be strict and explicit via allow-list IDs only.
2. No automatic discovery mode for Midnight secret/hidden currencies.
3. UI should display a scope notice: Tracking known configured currencies only.

Initial approved currency IDs to record:

- 3392: Remnant of Anguish
- 3316: Voidlight Marl (normal expansion currency)
- 3383: Adventurer Dawncrest (Season 1)
- 3341: Veteran Dawncrest (Season 1)
- 3343: Champion Dawncrest (Season 1)

## Known Gameplay Targets

Weekly reward targets to surface in UI:

1. Normal Prey Hunts: up to 2 Adventure-level gear rewards per week.
2. Hard Prey Hunts: up to 2 Veteran-level gear rewards per week.
3. Nightmare Prey Hunts: up to 2 Champion-level gear rewards per week.
4. Each hunt tier also grants a crest tied to that tier's upgrade track.
5. Reward progression per tier is chest-first, then sack rewards after chest caps are reached.

Tier reward sequence to model:

- Normal tier:
  - First 2 weekly rewards: Preyseeker's Adventurer Chest (item 257023)
  - Next 2 weekly rewards: Preyseeker's Adventurer Sack (item 262928)
- Hard tier:
  - First 2 weekly rewards: Preyseeker's Veteran Chest (item 257026)
  - Next 2 weekly rewards: Preyseeker's Veteran Sack (item 262936)
- Nightmare tier:
  - First 2 weekly rewards: Preyseeker's Champion Chest (item 262346)
  - Next 2 weekly rewards: Preyseeker's Champion Sack (item 262938)

## Research Summary (API feasibility)

### Currency and warband support

- C_CurrencyInfo.GetCurrencyInfo(currencyID) returns quantity and account/transfer metadata in modern builds.
- C_CurrencyInfo.GetCurrencyListInfo(index) can enumerate visible currencies and exposes account-wide/transfer-related flags.
- Character-by-character history for offline alts is not globally queryable in one shot; use SavedVariables snapshots per character.

### Hunt interaction and quest discovery

- C_GossipInfo.GetAvailableQuests() and C_GossipInfo.GetActiveQuests() provide quests shown during interaction (GOSSIP_SHOW).
- C_GossipInfo.GetOptions() can expose option-level details and status.
- C_QuestLog.RequestLoadQuestByID(questID) with QUEST_DATA_LOAD_RESULT hydrates uncached quest metadata.

### Quest metadata and reward extraction

- C_QuestLog.GetTitleForQuestID(questID) for quest naming (including non-log contexts after data load).
- C_QuestLog.GetQuestTagInfo(questID) and C_QuestInfoSystem.GetQuestClassification(...) for grouping and difficulty labeling.
- C_QuestLog.GetQuestRewardCurrencies(questID) and C_QuestLog.GetQuestRewardCurrencyInfo(...) for currency reward rows.

### Achievement gap mapping

- GetAchievementInfo(achievementID) for completion status and metadata.
- GetAchievementCriteriaInfo(...) for criteria and completion states.
- Criteria type 27 (quest completion) can support direct quest-to-achievement gap matching where data aligns.

## Proposed Epics

## Epic 1: Approved Currency Ledger (MVP)

Deliverables:

- Current amount for all approved Prey currencies.
- Session gain/loss (from login/reload baseline).
- Per-character currency snapshot and known-warband aggregate from scanned characters.
- Optional allow-list UI for additional explicitly approved currency IDs.

Data model:

- PreydatorDB.currency.allowList = {
  [3392] = true,
  [3316] = true,
  [3383] = true,
  [3341] = true,
  [3343] = true,
}
- PreydatorDB.currency.session[characterKey][currencyID] = { start, current, delta }
- PreydatorDB.currency.snapshots[characterKey][currencyID] = { quantity, lastSeen }

Acceptance criteria:

1. Always shows current + session delta for all allow-listed currency IDs.
2. Does not track non-allow-listed currencies.
3. Warband summary clearly indicates known characters only.

## Epic 2: Hunt Source Scanner

Deliverables:

- At hunt interaction points, list available hunts and active turn-ins.
- Grouping toggle: Difficulty or Zone.
- Tier labels normalized to Normal / Hard / Nightmare.

Acceptance criteria:

1. Scanner fills from gossip interaction data.
2. Grouping can switch live without reload.
3. Missing quest cache data hydrates asynchronously and updates rows.

## Epic 3: Weekly Hunt Cap Tracker

Current progress:

- Initial alt-visible prey progress chart added in settings (`Prey Track (Alts)`), showing per-character zone and rank snapshots as a foundation for weekly cap counters.

Deliverables:

- Tier counters for weekly completions and remaining opportunities:
  - Normal: 0-2 Adventure rewards
  - Hard: 0-2 Veteran rewards
  - Nightmare: 0-2 Champion rewards
- Tier reward stage counters:
  - Chest stage: 0/2 per tier
  - Sack stage: 0/2 per tier (only after chest stage complete)
- Crest acquisition indicator per tier.

Acceptance criteria:

1. UI shows completed and remaining count for each tier.
2. UI shows chest-stage and sack-stage progress separately for each tier.
3. Sack progress does not increment until chest stage is complete for that tier.
4. Counter logic resets on weekly reset.
5. Crest indicator reflects detected completion activity for the tier.

## Epic 4: Prey Achievement Gap Highlighter

Deliverables:

- Prey achievement watchlist sourced from Expansion Features > Prey.
- Highlight hunt options that satisfy missing criteria.
- Badge example: Missing for Prey Achievement.

Acceptance criteria:

1. Completed criteria are not highlighted.
2. Incomplete criteria are linked to qualifying hunts where mapping exists.
3. Mapping is data-driven and easy to update.

## Epic 5: Reward Intelligence and Cost Context

Deliverables:

- Hunt reward summaries including currency and gear tier context.
- Optional cost context panel for Remnant of Anguish spending goals.
- Sort by value, urgency, or missing-achievement relevance.

Acceptance criteria:

1. Reward rows populate from available quest metadata when possible.
2. Missing data fails gracefully without UI breakage.
3. Cost context uses approved data sources and explicit item lists.

## Suggested Build Plan

1. Milestone A: Approved Currency Ledger (3392/3316/3383/3341/3343 allow-list) + scope safeguards.
2. Milestone B: Hunt Source Scanner and grouping UI.
3. Milestone C: Weekly Hunt Cap Tracker (2/2/2 by tier) + crest indicators.
4. Milestone D: Achievement Gap Highlighter for Expansion Features > Prey.
5. Milestone E: Reward Intelligence and optional cost-context panel.

## Post-v1.7.0 Backlog

1. Add Prey Tracking per Zone as a dedicated post-launch enhancement (after v1.7.0).

## Post-v1.7.3 Technical Follow-Up

Goal:
Reduce maintenance risk in `Preydator.lua` and keep future Hunt/Prey work away from Lua's 200-local-variable ceiling.

Planned surgical split:

1. Extract prey state tracking and quest/widget interpretation from `Preydator.lua` into a dedicated module while keeping the existing `Preydator` state object as the source of truth.
2. Extract bar rendering, display refresh, and click interaction behavior into a separate UI-focused module.
3. Move debug/inspect helpers that are not core runtime requirements out of the main chunk so routine feature work does not keep consuming top-level locals.

Implementation notes:

1. Preserve current SavedVariables structure and public module hooks.
2. Keep load order explicit in `Preydator.toc`; avoid dynamic loading.
3. Prefer moving cohesive helper groups with minimal behavior changes instead of broad rewrites.
4. Keep HuntScanner cache-clearing driven by the explicit prey-end hook added in `Preydator.lua`, not by passive callback churn.
5. Treat Hunt Table rendering, preview mode, and debug paths as separate responsibilities with separate entry points.

Immediate candidate extraction order:

1. Prey runtime/state evaluation.
2. Bar/UI rendering.
3. Diagnostics/debug helpers.

### 200-Local-Cap Optimization Track (new)

Goal:
Keep `Preydator.lua` comfortably below Lua's 200 active local/upvalue ceiling so feature work can continue without compiler-pressure regressions.

Planned low-risk phases:

1. Measure and map pressure points:
  - Identify top functions/chunks by local-count pressure.
  - Keep a small margin target (for example 15-25 locals below hard cap) after each phase.
2. Extract cohesive helper groups first (no behavior change):
  - Slash/command parsing helpers.
  - Inspect/report string builders.
  - Prey state read-only formatting helpers.
3. Move non-core diagnostics out of main runtime chunk:
  - Keep runtime paths in `Preydator.lua`.
  - Move inspect/debug assembly utilities into a dedicated module under `Modules/`.
4. Normalize shared utilities through `Preydator.API`:
  - Continue reducing duplicate helper closures in Settings/EditMode/Hunt modules.
  - Prefer shared helpers over new per-file locals where behavior is identical.
5. Add guardrails for future edits:
  - During PR/release checks, run a lightweight compile/lint pass focused on local-cap safety.
  - If a change increases chunk pressure, require a paired extraction in the same cycle.

Definition of done for this track:

1. Main runtime chunk no longer sits at the cap boundary during normal feature iteration.
2. Inspect/debug enhancements can be added without requiring emergency local-trimming.
3. Refactor keeps SavedVariables format and current public module hooks unchanged.

## Architecture Notes

- Keep modular direction under Modules/.
- Add modules for new systems:
  - Modules/CurrencyTracker.lua
  - Modules/HuntScanner.lua
  - Modules/WeeklyCaps.lua
  - Modules/AchievementBridge.lua
  - Modules/PreyData.lua
- Keep settings in existing panel framework and preserve current two-column layout conventions.

## QA and Validation Plan

1. Validate currency tracking only records allow-listed IDs.
2. Validate gossip scanner behavior on rapid open/close of interaction UI.
3. Validate weekly counters around reset boundaries.
4. Validate achievement highlights against known Prey achievements.
5. Add debug inspect output for currency, hunt scan, caps, and achievement mapping subsystems.

## Open Questions

1. Final list of hunt source objects/NPCs to anchor scanner behavior.
2. Preferred strategy for weekly cap detection: quest-completion IDs, loot events, or both.
3. Whether cost context should be maintained manually in data files or generated from imported curated data.
4. Whether default UI should show only always-relevant currencies or full allow-list including season-specific entries.

## Recorded IDs (Owner-Supplied)

Hunt reward containers:

- item=257023/preyseekers-adventurer-chest
- item=257026/preyseekers-veteran-chest
- item=262346/preyseekers-champion-chest
- item=262928/preyseekers-adventurer-sack
- item=262936/preyseekers-veteran-sack
- item=262938/preyseekers-champion-sack

General/seasonal currencies:

- currency=3316/voidlight-marl
- currency=3383/adventurer-dawncrest
- currency=3341/veteran-dawncrest
- currency=3343/champion-dawncrest

Additional reward containers to record (optional usage in UI logic):

- item=262623/preyseekers-satchel-of-adventurer-dawncrests
- item=262629/preyseekers-box-of-veteran-dawncrests
- item=262633/preyseekers-cache-of-champion-dawncrests

## Future Ideas (Post-Roadmap)

- Vendor affordability assistant based on configured spending goals.
- Weekly summary report (earned, spent, remaining opportunities).
- Character recommendation helper (which alt benefits most from next hunt).

# Possible taint audit

Date: 2026-03-29
Scope: propagation-focused pass for secret values that can later surface in Blizzard map tooltip/layout code.

## High-confidence possible vectors

1. Preydator.lua:2712-2717
- Function: TryGetPreyQuestWaypoint
- Risk: Reads C_QuestLog.GetNextWaypoint payload fields directly, then runs raw tonumber on waypoint.uiMapID/mapID and waypoint.position.x/y.
- Why this is still possible: if any waypoint payload field is secret in a restricted/tainted path, field access or conversion can taint current execution and later Blizzard tooltip layout.

2. Preydator.lua:2726-2738
- Function: addMapCandidate inside TryGetPreyQuestWaypoint
- Risk: Raw tonumber plus numeric comparison mapID > 0 on values sourced from map APIs and cached state.
- Why this is still possible: map IDs can come from protected API returns in edge states; numeric compare on secret numbers is a known taint spread trigger.

3. Preydator.lua:2742-2761
- Function: TryGetPreyQuestWaypoint
- Risk: Quest location and quest-on-map coordinates are read from protected APIs, then passed through map waypoint creation flow.
- Why this is still possible: values are pcall-wrapped on function call, but payload values themselves are still consumed as raw numbers without safe coercion wrapper.

## Remediated in code

4. Removed dormant widget-ID tracking path (resolved)
- Previous location: Preydator.lua:2395-2416
- Previous function: TrackKnownPreyWidgetFrames
- Previous risk: numericWidgetID derivation checked type(widgetID) == number and widgetID > 0, then called container.GetWidgetFrame with that ID.
- Remediation applied: removed TrackKnownPreyWidgetFrames, removed lastPreyWidgetID/lastPreyWidgetSetID state, removed detectedWidgetID flow, and switched suppression refresh to live frame capture only (CaptureLivePreyHuntFrames).

## Already hardened (verified in this pass)

- Main event bridge drops UPDATE_UI_WIDGET and UPDATE_ALL_UI_WIDGETS payload args before cross-function dispatch.
- Core event runtime also drops noisy widget payload args before module fanout.
- Prey mixin hook callback no longer binds widget payload argument (self-only signature).
- HuntScanner noisy event recording path does not read noisy widget varargs.

## Suggested next hardening steps

1. Convert TryGetPreyQuestWaypoint map/waypoint numeric reads to fail-closed safe coercion wrappers (pcall around field access and conversion).
2. Keep all map coordinate and waypoint creation inputs behind safe conversion helpers before arithmetic/comparison.

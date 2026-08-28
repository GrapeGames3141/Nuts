class_name LevelData
extends RefCounted

const LIGHTNING_FLASH_DURATION := 0.36

const VARIANTS := ["Oak", "Redcap", "Striped", "Gold"]
const RECIPES := [
    [0, 1, 0], [1, 2, 0], [2, 0, 1], [0, 1, 2, 0],
    [2, 3, 1, 0], [1, 0, 3, 2], [3, 2, 1, 0],
    [0, 2, 3, 1, 0], [3, 1, 0, 2, 1], [1, 3, 2, 0, 3],
    [0,1,3,2,0], [2,0,1,3,2], [3,1,2,0,1], [1,2,3,0,2], [0,3,1,2,3],
    [2,1,0,3,1], [3,0,2,1,0], [1,3,0,2,1], [0,2,1,3,0], [2,3,1,0,2], [3,1,0,2,3]
]
const NAMES := ["First Acorns", "Spring Acorns", "Summer Acorns", "Leafy Acorns", "Pinecone Shuffle", "Breezy Pinecones", "Acorn Boughs", "Acorn Timber!", "Snowy Pinecones", "Night Pinecones", "Acorn Crossing", "Cedar Pinecones", "Bough Acorns", "Needle Pinecones", "Storm Acorns", "Moonlit Pinecones", "Frosty Pinecones", "Snowcap Pinecones", "Icy Pinecones", "Pinecone Crown"]
const CANOPY_RECIPES := [
    [0,2,1,3,0], [1,3,0,2,1], [2,0,3,1,2], [3,1,2,0,3], [0,3,1,2,0],
    [1,0,3,2,1], [2,1,0,3,2], [3,2,1,0,3], [0,1,3,2,0], [1,3,2,0,1],
    [2,0,1,3,2], [3,1,0,2,3], [0,2,3,1,0], [1,0,2,3,1], [2,3,0,1,2],
    [3,0,1,2,3], [0,1,2,3,0], [1,2,3,0,1], [2,3,1,0,2], [3,1,2,0,3],
    [0,3,2,1,0], [1,0,3,2,1], [2,1,3,0,2], [3,2,0,1,3], [0,2,1,3,0],
    [3,0,2,1,3], [0,1,3,2,0], [1,2,0,3,1], [2,3,1,0,2], [3,1,0,2,3]
]
const CANOPY_NAMES := ["Canopy Cadence", "High Boughs", "Quickstep Acorns", "Pinecone Drift", "Crown Tempo", "Gusty Acorns", "Windward Pinecones", "Canopy Crosswind", "Bough Breeze", "Gale Gate", "Hawk Watch", "Owl Watch", "Raptor Run", "Wingbeat Way", "Canopy Guard", "Limb Landing", "Swaying Bough", "Branch Rhythm", "High Perch", "Crown Balance", "Firefly Acorns", "Moonlit Canopy Pinecones", "Lantern Leaves", "Night Bough", "Glow Trail", "Storm Signal", "Thunder Bough", "Lightning Run", "Tempest Crown", "Canopy Finale"]
const MAX_LEVEL := 50
const SPAWN_TO_CATCH_DISTANCE := 1865.0
const EARLY_ACORN_ARRIVAL_SAFETY_SECONDS := 1.15
const LATE_ACORN_ARRIVAL_SAFETY_SECONDS := 0.65
const CONTINUATION_SEED_STRIDE := 104729
const CONTINUATION_SEED_RETRY_STRIDE := 1009
const THEMES := [
    {"id":"spring", "background":"spring_oak", "family":"acorn", "minor":"", "major":"", "ambient":false},
    {"id":"spring", "background":"spring_oak", "family":"acorn", "minor":"", "major":"", "ambient":false},
    {"id":"summer", "background":"summer_oak", "family":"acorn", "minor":"", "major":"", "ambient":false},
    {"id":"autumn", "background":"autumn_oak", "family":"acorn", "minor":"leaf", "major":"", "ambient":false},
    {"id":"pine", "background":"pine_grove", "family":"pinecone", "minor":"needle", "major":"", "ambient":false},
    {"id":"pine", "background":"pine_grove", "family":"pinecone", "minor":"needle", "major":"", "ambient":false},
    {"id":"autumn", "background":"autumn_oak", "family":"acorn", "minor":"leaf", "major":"", "ambient":false},
    {"id":"storm", "background":"autumn_oak", "family":"acorn", "minor":"leaf", "major":"branch", "ambient":false},
    {"id":"winter", "background":"winter_pine", "family":"pinecone", "minor":"snowflake", "major":"icicle", "ambient":true},
    {"id":"winter_night", "background":"winter_pine", "family":"pinecone", "minor":"snowflake", "major":"icicle", "ambient":true},
    {"id":"autumn", "background":"autumn_oak", "family":"acorn", "minor":"leaf", "major":"branch", "ambient":false},
    {"id":"pine", "background":"pine_grove", "family":"pinecone", "minor":"needle", "major":"branch", "ambient":false},
    {"id":"autumn", "background":"autumn_oak", "family":"acorn", "minor":"leaf", "major":"branch", "ambient":false},
    {"id":"pine", "background":"pine_grove", "family":"pinecone", "minor":"needle", "major":"branch", "ambient":false},
    {"id":"storm", "background":"autumn_oak", "family":"acorn", "minor":"leaf", "major":"branch", "ambient":false},
    {"id":"winter_night", "background":"winter_pine", "family":"pinecone", "minor":"snowflake", "major":"icicle", "ambient":true},
    {"id":"winter", "background":"winter_pine", "family":"pinecone", "minor":"snowflake", "major":"icicle", "ambient":true},
    {"id":"winter", "background":"winter_pine", "family":"pinecone", "minor":"snowflake", "major":"icicle", "ambient":true},
    {"id":"winter_night", "background":"winter_pine", "family":"pinecone", "minor":"snowflake", "major":"icicle", "ambient":true},
    {"id":"winter_night", "background":"winter_pine", "family":"pinecone", "minor":"snowflake", "major":"icicle", "ambient":true}
]

static func level_name(level_number: int) -> String:
    return NAMES[level_number - 1] if level_number <= NAMES.size() else CANOPY_NAMES[level_number - 21]
static func level_count() -> int:
    return MAX_LEVEL


static func recipe_for(level_number: int) -> Array:
    return RECIPES[level_number - 1] if level_number <= RECIPES.size() else CANOPY_RECIPES[level_number - 21]

static func theme_for(level_number: int) -> Dictionary:
    if level_number <= THEMES.size(): return THEMES[level_number - 1].duplicate()
    var family := "acorn" if level_number % 2 == 1 else "pinecone"
    var theme := {"id":"canopy_day", "background":"high_canopy_day", "family":family, "minor":"leaf" if family == "acorn" else "needle", "major":"", "ambient":false, "fall_speed_mode":"mixed", "branch_mode":"stationary"}
    if level_number >= 26 and level_number <= 30: theme.gusts = true
    if level_number >= 31 and level_number <= 35: theme.predators = true
    if level_number >= 36 and level_number <= 40:
        theme.id = "canopy_limb"; theme.play_limb = true; theme.branch_mode = "sway"
    if level_number >= 41 and level_number <= 45:
        theme.id = "canopy_night"; theme.background = "high_canopy_night"; theme.night = true; theme.fireflies = true; theme.play_limb = true; theme.branch_mode = "sway"
    if level_number >= 46:
        theme.id = "canopy_storm"; theme.background = "high_canopy_storm"; theme.lightning = true; theme.play_limb = true; theme.branch_mode = "sway"; theme.finale_stage = level_number - 45
        if level_number >= 47: theme.gusts = true
        if level_number >= 48: theme.predators = true
        if level_number >= 49: theme.night = true; theme.fireflies = true
    return theme

static func make(level_number: int, seed: int = 1) -> Dictionary:
    var clamped_number := clampi(level_number, 1, MAX_LEVEL)
    var i := clamped_number - 1
    var rng := RandomNumberGenerator.new()
    rng.seed = seed + clamped_number * 9817
    var speed := 205.0 + i * 19.0
    var theme := theme_for(clamped_number)
    var recipe := recipe_for(clamped_number)
    var result := {
        "number": clamped_number, "name": level_name(clamped_number), "recipe": recipe.duplicate(),
        "base_speed": speed, "speed_range": 24.0 + i * 8.0,
        "theme": theme, "leaves": theme.minor != "", "limbs": theme.major != "",
        "tutorial": clamped_number == 1, "events": []
    }
    var scheduled_acorns: Array = []
    var target_arrivals: Array = []
    var arrival_window := acorn_arrival_safety_window(clamped_number)
    var t := 1.2
    for recipe_index in recipe.size():
        var target: int = recipe[recipe_index]
        var target_speed := speed + rng.randf_range(-result.speed_range * (0.58 if clamped_number >= 21 else 0.30), result.speed_range * (0.58 if clamped_number >= 21 else 0.30))
        var target_lane := choose_acorn_lane(rng, scheduled_acorns, t, target_speed, -1, 0, arrival_window)
        result.events.append({"time": t, "kind": "acorn", "family": result.theme.family, "variant": target, "target": true,
            "lane": target_lane, "speed": target_speed})
        scheduled_acorns.append({"lane": target_lane, "arrival": acorn_arrival_time(t, target_speed)})
        target_arrivals.append({"lane": target_lane, "arrival": acorn_arrival_time(t, target_speed)})
        # Decoys vary by seed but never share a prohibited catch-zone arrival with an acorn.
        if clamped_number >= 2:
            var decoy_time := t + 0.72
            var decoy_speed := speed + rng.randf_range(-result.speed_range * 0.65, result.speed_range * 0.65)
            var decoy_lane := choose_acorn_lane(rng, scheduled_acorns, decoy_time, decoy_speed,
                target_lane, 1 if clamped_number <= 5 else 0, arrival_window)
            result.events.append({"time": t + 0.72, "kind": "acorn", "family": result.theme.family, "variant": (target + rng.randi_range(1, 3)) % 4,
                "target": false, "lane": decoy_lane, "speed": decoy_speed})
            scheduled_acorns.append({"lane": decoy_lane, "arrival": acorn_arrival_time(decoy_time, decoy_speed)})
        # Beyond Tree 1, density rises through a second safely-separated decoy
        # rather than longer recipes.  Its lane is still arrival-time checked.
        if clamped_number >= 12 and int(t * 10.0) % 2 == 0:
            var extra_time := t + 1.28
            var extra_speed := speed + rng.randf_range(-result.speed_range * 0.78, result.speed_range * 0.78)
            var extra_lane := choose_acorn_lane(rng, scheduled_acorns, extra_time, extra_speed, target_lane, 0, arrival_window)
            result.events.append({"time": extra_time, "kind": "acorn", "family": result.theme.family, "variant": (target + rng.randi_range(1, 3)) % 4,
                "target": false, "lane": extra_lane, "speed": extra_speed})
            scheduled_acorns.append({"lane": extra_lane, "arrival": acorn_arrival_time(extra_time, extra_speed)})
        if result.theme.minor != "" and int(t * 10.0) % 2 == 0:
            result.events.append({"time": t + 1.05, "kind": "leaf", "skin": result.theme.minor, "variant": rng.randi_range(0, 3), "target": false,
                "lane": rng.randi_range(0, 4), "speed": speed * 0.72})
        if clamped_number >= 14 and result.theme.minor != "" and int(t * 10.0) % 3 == 0:
            result.events.append({"time": t + 1.45, "kind": "leaf", "skin": result.theme.minor, "variant": rng.randi_range(0, 3), "target": false,
                "lane": rng.randi_range(0, 4), "speed": speed * 0.76})
        if result.theme.major != "" and int(t * 10.0) % 3 == 0:
            var limb_width := 1 if clamped_number < 10 else rng.randi_range(1, 2)
            var limb_time := t - 0.65
            var limb_speed := speed * 0.80
            var impact := limb_arrival_time(limb_time, 1.35, limb_speed)
            var limb_lane := choose_safe_limb_lane(rng, target_arrivals, impact, limb_width)
            result.events.append({"time": limb_time, "kind": "limb", "skin": result.theme.major, "variant": -1, "target": false,
                "lane": limb_lane, "width": limb_width, "warning": 1.35, "speed": limb_speed})
        var storm_stage := int(result.theme.get("finale_stage", 0))
        var schedule_gust := bool(result.theme.get("gusts", false)) and (
            (storm_stage == 0 and recipe_index % 2 == 0) or
            (storm_stage >= 2 and (recipe_index == 1 or recipe_index == 4)))
        if schedule_gust:
            result.events.append({"time": t + 0.30, "kind": "gust", "target": false, "direction": -1 if rng.randi() % 2 == 0 else 1, "warning": 1.05, "duration": 0.38})
        var schedule_predator := bool(result.theme.get("predators", false)) and (
            (storm_stage == 0 and recipe_index % 3 == 0) or
            (storm_stage >= 3 and recipe_index == 2))
        if schedule_predator:
            var predator_time := t - 0.75
            var predator_impact := predator_time + 1.45 + SPAWN_TO_CATCH_DISTANCE / (speed * 1.05)
            var predator_lane := choose_safe_predator_lane(rng, target_arrivals, predator_impact)
            if predator_lane >= 0:
                result.events.append({"time": predator_time, "kind": "predator", "target": false, "lane": predator_lane, "skin": "hawk" if rng.randi() % 2 == 0 else "owl", "warning": 1.45, "speed": speed * 1.05})
        var schedule_lightning := bool(result.theme.get("lightning", false)) and (
            (storm_stage == 1 and recipe_index % 2 == 0) or
            (storm_stage >= 2 and (recipe_index == 0 or recipe_index == 3)))
        if schedule_lightning:
            result.events.append({"time": t + 0.25, "kind": "lightning", "target": false, "warning": 0.85, "duration": LIGHTNING_FLASH_DURATION})
        t += maxf(2.35, 3.6 - i * 0.08)
    result.events.sort_custom(func(a, b): return a.time < b.time)
    return result

static func rating(mistakes: int) -> int:
    return 3 if mistakes == 0 else 2 if mistakes == 1 else 1

static func cycle_duration(definition: Dictionary) -> float:
    # The offset lets the next cycle's first target follow the prior cycle's
    # last target at the same authored step, without a quiet boundary or burst.
    var level_index := int(definition.number) - 1
    var step := maxf(2.35, 3.6 - level_index * 0.08)
    var recipe: Array = definition.recipe
    return step * float(recipe.size())

static func make_continuation(definition: Dictionary, seed: int, cycle_index: int, previous_cycle: Array = []) -> Array:
    # A continuation is a fresh authored pass, not a target-only replacement.
    # Candidate seeds vary lanes, speeds and skins while preserving the same
    # target cadence and complete level-specific mix of decoys and hazards.
    var offset := cycle_duration(definition) * float(cycle_index)
    for retry in range(96):
        var cycle_seed := seed + cycle_index * CONTINUATION_SEED_STRIDE + retry * CONTINUATION_SEED_RETRY_STRIDE
        var source := make(int(definition.number), cycle_seed)
        var shifted: Array = []
        for source_event in source.events:
            var event: Dictionary = source_event.duplicate(true)
            event.time = float(event.time) + offset
            shifted.append(event)
        if _events_are_safe(int(definition.number), previous_cycle + shifted):
            return shifted
    # Every candidate is independently safe. This fallback keeps the stream
    # moving should exceptionally dense future content exhaust the retries.
    var fallback_source := make(int(definition.number), seed + cycle_index * CONTINUATION_SEED_STRIDE)
    var fallback: Array = []
    for source_event in fallback_source.events:
        var event: Dictionary = source_event.duplicate(true)
        event.time = float(event.time) + offset
        fallback.append(event)
    return fallback

static func acorn_arrival_safety_window(level_number: int) -> float:
    return EARLY_ACORN_ARRIVAL_SAFETY_SECONDS if level_number <= 5 else LATE_ACORN_ARRIVAL_SAFETY_SECONDS

static func acorn_arrival_time(spawn_time: float, speed: float) -> float:
    return spawn_time + SPAWN_TO_CATCH_DISTANCE / speed

static func limb_arrival_time(spawn_time: float, warning: float, speed: float) -> float:
    return spawn_time + warning + SPAWN_TO_CATCH_DISTANCE / (speed * 1.15)

static func limb_conflicts_target(limb_lane: int, width: int, impact: float, target: Dictionary) -> bool:
    return absf(impact - float(target.arrival)) < 0.82 and abs(limb_lane - int(target.lane)) < width

static func choose_safe_limb_lane(rng: RandomNumberGenerator, targets: Array, impact: float, width: int) -> int:
    var start := rng.randi_range(0, 4)
    for offset in range(5):
        var lane := (start + offset) % 5
        var safe := true
        for target in targets:
            if limb_conflicts_target(lane, width, impact, target):
                safe = false
                break
        if safe:
            return lane
    return start

static func choose_safe_predator_lane(rng: RandomNumberGenerator, targets: Array, impact: float) -> int:
    var start := rng.randi_range(0, 4)
    for offset in range(5):
        var lane := (start + offset) % 5
        var safe := true
        for target in targets:
            if limb_conflicts_target(lane, 1, impact, target): safe = false; break
        if safe: return lane
    return -1

static func choose_acorn_lane(rng: RandomNumberGenerator, scheduled_acorns: Array, spawn_time: float, speed: float,
        avoid_lane: int, min_lane_distance: int, arrival_window: float) -> int:
    var arrival := acorn_arrival_time(spawn_time, speed)
    var start := rng.randi_range(0, 4)
    for offset in range(5):
        var lane := (start + offset) % 5
        if avoid_lane >= 0 and abs(lane - avoid_lane) < min_lane_distance:
            continue
        if not has_acorn_arrival_conflict(scheduled_acorns, lane, arrival, arrival_window):
            return lane
    # Dense late layouts may relax lane preference, but never the same-lane arrival rule.
    for lane in range(5):
        if not has_acorn_arrival_conflict(scheduled_acorns, lane, arrival, arrival_window):
            return lane
    return start

static func has_acorn_arrival_conflict(scheduled_acorns: Array, lane: int, arrival: float, arrival_window: float) -> bool:
    for scheduled in scheduled_acorns:
        if scheduled.lane == lane and absf(scheduled.arrival - arrival) < arrival_window:
            return true
    return false

static func validate(definition: Dictionary) -> bool:
    var recipe: Array = definition.recipe
    if recipe.size() < 3 or recipe.size() > 5: return false
    if int(definition.number) >= 21 and recipe.size() != 5: return false
    return _events_are_safe(int(definition.number), definition.events)

static func _events_are_safe(level_number: int, events_to_validate: Array) -> bool:
    var acorns: Array = []
    var targets: Array = []
    var limbs: Array = []
    var predators: Array = []
    var global_telegraphs: Array = []
    var arrival_window := acorn_arrival_safety_window(level_number)
    for event in events_to_validate:
        var skin := str(event.get("skin", ""))
        # Branches are exclusively full-reset limbs. Minor debris must never
        # silently inherit the branch art or warning-free limb behavior.
        if skin == "stick": return false
        if event.kind != "limb" and skin == "branch": return false
        if event.kind == "limb" and skin != "branch" and skin != "icicle": return false
        if event.kind == "limb" and event.warning < 1.1: return false
        if event.kind == "limb": limbs.append(event)
        if event.kind == "gust":
            if float(event.get("warning", 0.0)) < 1.0 or abs(int(event.get("direction", 0))) != 1: return false
            global_telegraphs.append({"start":float(event.time), "end":float(event.time) + float(event.warning)})
        if event.kind == "lightning":
            if float(event.get("warning", 0.0)) < 0.7: return false
            global_telegraphs.append({"start":float(event.time), "end":float(event.time) + float(event.warning)})
        if event.kind == "predator":
            if float(event.get("warning", 0.0)) < 1.2: return false
            if str(event.get("skin", "")) != "hawk" and str(event.get("skin", "")) != "owl": return false
            predators.append(event)
            global_telegraphs.append({"start":float(event.time), "end":float(event.time) + float(event.warning)})
        if event.kind == "acorn":
            if event.speed <= 0.0: return false
            var arrival := acorn_arrival_time(event.time, event.speed)
            if has_acorn_arrival_conflict(acorns, event.lane, arrival, arrival_window): return false
            acorns.append({"lane": event.lane, "arrival": arrival})
            if event.target: targets.append({"lane": event.lane, "arrival": arrival})
    for limb in limbs:
        var impact := limb_arrival_time(limb.time, limb.warning, limb.speed)
        for target in targets:
            if limb_conflicts_target(limb.lane, limb.width, impact, target): return false
    for predator in predators:
        var swoop_impact := float(predator.time) + float(predator.warning) + SPAWN_TO_CATCH_DISTANCE / maxf(1.0, float(predator.speed))
        for target in targets:
            if limb_conflicts_target(int(predator.lane), 1, swoop_impact, target): return false
    global_telegraphs.sort_custom(func(a, b): return a.start < b.start)
    for telegraph_index in range(1, global_telegraphs.size()):
        if float(global_telegraphs[telegraph_index].start) < float(global_telegraphs[telegraph_index - 1].end) + 0.18:
            return false
    return true

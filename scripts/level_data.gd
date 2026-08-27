class_name LevelData
extends RefCounted

const VARIANTS := ["Oak", "Redcap", "Striped", "Gold"]
const RECIPES := [
    [0, 1, 0], [1, 2, 0], [2, 0, 1], [0, 1, 2, 0],
    [2, 3, 1, 0], [1, 0, 3, 2], [3, 2, 1, 0],
    [0, 2, 3, 1, 0], [3, 1, 0, 2, 1], [1, 3, 2, 0, 3],
    [0,1,3,2,0], [2,0,1,3,2], [3,1,2,0,1], [1,2,3,0,2], [0,3,1,2,3],
    [2,1,0,3,1], [3,0,2,1,0], [1,3,0,2,1], [0,2,1,3,0], [2,3,1,0,2], [3,1,0,2,3]
]
const NAMES := ["First Acorns", "Spring Acorns", "Summer Acorns", "Leafy Acorns", "Pinecone Shuffle", "Breezy Pinecones", "Acorn Boughs", "Acorn Timber!", "Snowy Pinecones", "Night Pinecones", "Acorn Crossing", "Cedar Pinecones", "Bough Acorns", "Needle Pinecones", "Storm Acorns", "Moonlit Pinecones", "Frosty Pinecones", "Snowcap Pinecones", "Icy Pinecones", "Pinecone Crown"]
const SPAWN_TO_CATCH_DISTANCE := 1865.0
const EARLY_ACORN_ARRIVAL_SAFETY_SECONDS := 1.15
const LATE_ACORN_ARRIVAL_SAFETY_SECONDS := 0.65
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

static func make(level_number: int, seed: int = 1) -> Dictionary:
    var clamped_number := clampi(level_number, 1, 20)
    var i := clamped_number - 1
    var rng := RandomNumberGenerator.new()
    rng.seed = seed + clamped_number * 9817
    var speed := 205.0 + i * 19.0
    var result := {
        "number": clamped_number, "name": NAMES[i], "recipe": RECIPES[i].duplicate(),
        "base_speed": speed, "speed_range": 24.0 + i * 8.0,
        "theme": THEMES[i].duplicate(), "leaves": THEMES[i].minor != "", "limbs": THEMES[i].major != "",
        "tutorial": clamped_number == 1, "events": []
    }
    var scheduled_acorns: Array = []
    var target_arrivals: Array = []
    var arrival_window := acorn_arrival_safety_window(clamped_number)
    var t := 1.2
    for target in RECIPES[i]:
        var target_speed := speed + rng.randf_range(-result.speed_range * 0.30, result.speed_range * 0.30)
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
        t += maxf(2.35, 3.6 - i * 0.08)
    result.events.sort_custom(func(a, b): return a.time < b.time)
    return result

static func rating(mistakes: int) -> int:
    return 3 if mistakes == 0 else 2 if mistakes == 1 else 1

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
    var acorns: Array = []
    var targets: Array = []
    var limbs: Array = []
    var arrival_window := acorn_arrival_safety_window(int(definition.number))
    for event in definition.events:
        var skin := str(event.get("skin", ""))
        # Branches are exclusively full-reset limbs. Minor debris must never
        # silently inherit the branch art or warning-free limb behavior.
        if skin == "stick": return false
        if event.kind != "limb" and skin == "branch": return false
        if event.kind == "limb" and skin != "branch" and skin != "icicle": return false
        if event.kind == "limb" and event.warning < 1.1: return false
        if event.kind == "limb": limbs.append(event)
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
    return true

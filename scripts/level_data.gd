class_name LevelData
extends RefCounted

const VARIANTS := ["Oak", "Redcap", "Striped", "Gold"]
const RECIPES := [
    [0, 1, 0], [1, 2, 0], [2, 0, 1], [0, 1, 2, 0],
    [2, 3, 1, 0], [1, 0, 3, 2], [3, 2, 1, 0],
    [0, 2, 3, 1, 0], [3, 1, 0, 2, 1], [1, 3, 2, 0, 3]
]
const NAMES := ["First Nuts", "Three's Company", "Quick Branches", "Leaf Lesson", "Cap Shuffle", "Breezy Bunch", "Busy Bough", "Timber!", "Canopy Dash", "Nuts! Master"]
const SPAWN_TO_CATCH_DISTANCE := 1630.0
const EARLY_ACORN_ARRIVAL_SAFETY_SECONDS := 1.15
const LATE_ACORN_ARRIVAL_SAFETY_SECONDS := 0.65

static func make(level_number: int, seed: int = 1) -> Dictionary:
    var i := clampi(level_number - 1, 0, 9)
    var rng := RandomNumberGenerator.new()
    rng.seed = seed + level_number * 9817
    var speed := 205.0 + i * 19.0
    var result := {
        "number": level_number, "name": NAMES[i], "recipe": RECIPES[i].duplicate(),
        "base_speed": speed, "speed_range": 24.0 + i * 8.0,
        "leaves": level_number >= 4, "limbs": level_number >= 8,
        "tutorial": level_number == 1, "events": []
    }
    var scheduled_acorns: Array = []
    var arrival_window := acorn_arrival_safety_window(level_number)
    var t := 1.2
    for target in RECIPES[i]:
        var target_speed := speed + rng.randf_range(-18.0, 18.0)
        var target_lane := choose_acorn_lane(rng, scheduled_acorns, t, target_speed, -1, 0, arrival_window)
        result.events.append({"time": t, "kind": "acorn", "variant": target, "target": true,
            "lane": target_lane, "speed": target_speed})
        scheduled_acorns.append({"lane": target_lane, "arrival": acorn_arrival_time(t, target_speed)})
        # Decoys vary by seed but never share a prohibited catch-zone arrival with an acorn.
        if level_number >= 2:
            var decoy_time := t + 0.72
            var decoy_speed := speed + rng.randf_range(-35.0, 35.0)
            var decoy_lane := choose_acorn_lane(rng, scheduled_acorns, decoy_time, decoy_speed,
                target_lane, 1 if level_number <= 5 else 0, arrival_window)
            result.events.append({"time": t + 0.72, "kind": "acorn", "variant": (target + rng.randi_range(1, 3)) % 4,
                "target": false, "lane": decoy_lane, "speed": decoy_speed})
            scheduled_acorns.append({"lane": decoy_lane, "arrival": acorn_arrival_time(decoy_time, decoy_speed)})
        if level_number >= 4 and int(t * 10.0) % 2 == 0:
            result.events.append({"time": t + 1.05, "kind": "leaf", "variant": -1, "target": false,
                "lane": rng.randi_range(0, 4), "speed": speed * 0.72})
        if level_number >= 8 and int(t * 10.0) % 3 == 0:
            result.events.append({"time": t - 0.65, "kind": "limb", "variant": -1, "target": false,
                "lane": rng.randi_range(0, 4), "width": 1 if level_number < 10 else rng.randi_range(1, 2),
                "warning": 1.35, "speed": speed * 0.80})
        t += maxf(2.35, 3.6 - i * 0.08)
    result.events.sort_custom(func(a, b): return a.time < b.time)
    return result

static func rating(mistakes: int) -> int:
    return 3 if mistakes == 0 else 2 if mistakes == 1 else 1

static func acorn_arrival_safety_window(level_number: int) -> float:
    return EARLY_ACORN_ARRIVAL_SAFETY_SECONDS if level_number <= 5 else LATE_ACORN_ARRIVAL_SAFETY_SECONDS

static func acorn_arrival_time(spawn_time: float, speed: float) -> float:
    return spawn_time + SPAWN_TO_CATCH_DISTANCE / speed

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
    var arrival_window := acorn_arrival_safety_window(int(definition.number))
    for event in definition.events:
        if event.kind == "limb" and event.warning < 1.1: return false
        if event.kind == "acorn":
            if event.speed <= 0.0: return false
            var arrival := acorn_arrival_time(event.time, event.speed)
            if has_acorn_arrival_conflict(acorns, event.lane, arrival, arrival_window): return false
            acorns.append({"lane": event.lane, "arrival": arrival})
    return true

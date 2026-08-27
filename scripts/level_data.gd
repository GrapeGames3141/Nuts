class_name LevelData
extends RefCounted

const VARIANTS := ["Oak", "Redcap", "Striped", "Gold"]
const RECIPES := [
    [0, 1, 0], [1, 2, 0], [2, 0, 1], [0, 1, 2, 0],
    [2, 3, 1, 0], [1, 0, 3, 2], [3, 2, 1, 0],
    [0, 2, 3, 1, 0], [3, 1, 0, 2, 1], [1, 3, 2, 0, 3]
]
const NAMES := ["First Nuts", "Three's Company", "Quick Branches", "Leaf Lesson", "Cap Shuffle", "Breezy Bunch", "Busy Bough", "Timber!", "Canopy Dash", "Nuts! Master"]

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
    var t := 1.2
    for target in RECIPES[i]:
        result.events.append({"time": t, "kind": "acorn", "variant": target, "target": true,
            "lane": rng.randi_range(0, 4), "speed": speed + rng.randf_range(-18.0, 18.0)})
        # Decoys arrive well before or after targets; never cover the target's catch window.
        if level_number >= 2:
            result.events.append({"time": t + 0.72, "kind": "acorn", "variant": (target + rng.randi_range(1, 3)) % 4,
                "target": false, "lane": rng.randi_range(0, 4), "speed": speed + rng.randf_range(-35.0, 35.0)})
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

static func validate(definition: Dictionary) -> bool:
    var recipe: Array = definition.recipe
    if recipe.size() < 3 or recipe.size() > 5: return false
    for event in definition.events:
        if event.kind == "limb" and event.warning < 1.1: return false
        if event.kind == "acorn" and event.speed <= 0.0: return false
    return true

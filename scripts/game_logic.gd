class_name GameLogic
extends RefCounted
const LevelData = preload("res://scripts/level_data.gd")

var recipe: Array = []
var progress := 0
var mistakes := 0
var restarted := false
var attempt_seed := 1

func begin(new_recipe: Array, seed: int) -> void:
    recipe = new_recipe.duplicate()
    progress = 0
    mistakes = 0
    restarted = false
    attempt_seed = seed

func current_variant() -> int:
    return recipe[progress] if progress < recipe.size() else -1

func catch_object(kind: String, variant: int) -> String:
    if restarted: return "ignored"
    if kind == "limb":
        restarted = true
        progress = 0
        return "limb"
    if kind == "acorn" and variant == current_variant():
        progress += 1
        return "complete" if progress == recipe.size() else "correct"
    if kind == "leaf" or kind == "acorn":
        mistakes += 1
        progress = max(0, progress - 1)
        return "wrong"
    return "ignored"

func recipe_states() -> Array:
    var states := []
    for i in recipe.size():
        states.append("held" if i < progress else "current" if i == progress else "waiting")
    return states

func stars() -> int:
    return LevelData.rating(mistakes)

func reset_after_limb() -> void:
    progress = 0
    mistakes = 0
    restarted = false

static func simulate_level(number: int, seed: int) -> bool:
    var def := LevelData.make(number, seed)
    if not LevelData.validate(def): return false
    # Every target remains reachable with a 5-lane 0.22 s movement allowance.
    var last_target_time := -10.0
    for event in def.events:
        if event.kind == "acorn" and event.target:
            if event.time - last_target_time < 2.0: return false
            last_target_time = event.time
    return true

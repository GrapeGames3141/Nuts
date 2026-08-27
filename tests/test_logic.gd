extends SceneTree
const GameLogic = preload("res://scripts/game_logic.gd")
const LevelData = preload("res://scripts/level_data.gd")
var failures := 0
func expect(condition: bool, label: String) -> void:
    if condition: print("PASS ", label)
    else: failures += 1; push_error("FAIL " + label)
func _init() -> void:
    var level_names := {}
    expect(LevelData.NAMES.size() == 20, "twenty level names")
    for index in range(LevelData.NAMES.size()):
        var level_name: String = LevelData.NAMES[index]
        expect(not level_name.is_empty() and not level_names.has(level_name), "level name %d is unique" % (index + 1))
        level_names[level_name] = true
        var family: String = LevelData.THEMES[index].family
        expect(("Acorn" in level_name) if family == "acorn" else ("Pinecone" in level_name), "level name %d matches collectible family" % (index + 1))
    var game := GameLogic.new()
    game.begin([0, 1, 0], 17)
    expect(game.recipe_states() == ["current", "waiting", "waiting"], "initial goal states")
    expect(game.catch_object("acorn", 0) == "correct", "correct catch advances")
    expect(game.catch_object("acorn", 3) == "wrong", "wrong acorn rolls back")
    expect(game.progress == 0 and game.mistakes == 1, "rollback never underflows")
    expect(game.catch_object("leaf", -1) == "wrong", "leaf is wrong")
    expect(game.catch_object("acorn", 0) == "correct", "first target")
    expect(game.catch_object("acorn", 1) == "correct", "second target")
    expect(game.catch_object("acorn", 0) == "complete", "completion")
    game.begin([0], 1)
    expect(game.stars() == 3, "perfect run earns three acorns")
    game.catch_object("leaf", -1)
    expect(game.stars() == 2, "one mistake earns two acorns")
    game.catch_object("leaf", -1)
    expect(game.stars() == 1, "two mistakes earn one acorn")
    game.begin([0,1,2], 9)
    expect(game.catch_object("limb", -1) == "limb", "limb restart")
    expect(game.progress == 0 and game.restarted, "limb state")
    game.reset_after_limb()
    expect(not game.restarted and game.mistakes == 0, "recovery reset")
    for level in range(1,21):
        var expected := 3 if level <= 3 else 4 if level <= 7 else 5
        var d := LevelData.make(level, 1234)
        expect(d.recipe.size() == expected, "level %d recipe" % level)
        expect(LevelData.validate(d), "level %d definition" % level)
        expect(d.theme.family == LevelData.THEMES[level - 1].family, "level theme item family")
        if level <= 2: expect(d.theme.id == "spring" and d.theme.minor == "", "spring levels have no seasonal hazard")
        if level == 3: expect(d.theme.id == "summer" and d.theme.family == "acorn", "summer oak theme")
        if level == 4 or level == 7: expect(d.theme.minor == "leaf", "autumn leaf theme")
        if level >= 5 and level <= 6: expect(d.theme.family == "pinecone" and d.theme.minor == "stick", "pine stick theme")
        if level == 8: expect(d.theme.major == "branch", "storm branch reset theme")
        if level >= 9 and level <= 10: expect(d.theme.family == "pinecone" and d.theme.minor == "snowflake" and d.theme.major == "icicle", "winter snow and icicle theme")
        if level >= 11: expect(d.recipe.size() == 5 and d.name != "", "extended route stays at five items")
        if level >= 12:
            var decoy_count := 0
            for density_event in d.events:
                if density_event.kind == "acorn" and not density_event.target: decoy_count += 1
            expect(decoy_count >= 6 and d.speed_range > 100.0, "late route adds safe density and speed variety")
        var scheduled_arrivals: Array = []
        var no_same_lane_conflicts := true
        for event in d.events:
            if event.kind == "acorn":
                expect(event.speed > 0.0, "positive acorn speed")
                var arrival := LevelData.acorn_arrival_time(event.time, event.speed)
                no_same_lane_conflicts = no_same_lane_conflicts and not LevelData.has_acorn_arrival_conflict(
                    scheduled_arrivals, event.lane, arrival, LevelData.acorn_arrival_safety_window(level))
                scheduled_arrivals.append({"lane": event.lane, "arrival": arrival})
            if event.kind == "limb":
                expect(event.warning >= 1.1, "fair limb warning")
                for target_event in d.events:
                    if target_event.kind == "acorn" and target_event.target:
                        expect(not LevelData.limb_conflicts_target(event.lane, event.width,
                            LevelData.limb_arrival_time(event.time, event.warning, event.speed),
                            {"lane": target_event.lane, "arrival": LevelData.acorn_arrival_time(target_event.time, target_event.speed)}),
                            "limb does not cover a required catch arrival")
        expect(no_same_lane_conflicts, "speed-aware same-lane arrivals are separated")
        var seeds_ok := true
        var leaf_variants := {}
        for seed in range(1,101):
            var seeded := LevelData.make(level, seed)
            seeds_ok = seeds_ok and GameLogic.simulate_level(level, seed)
            for event in seeded.events:
                if event.get("skin", "") == "leaf": leaf_variants[event.variant] = true
        expect(seeds_ok, "100 deterministic seeds are solvable")
        if level == 4 or level == 7 or level == 8: expect(leaf_variants.size() == 4, "all four generated leaf variants appear across seeds")
    expect(LevelData.make(-5, 4).number == 1 and LevelData.make(99, 4).number == 20, "level requests clamp to the 20-level route")
    print("TEST_FAILURES=", failures)
    quit(1 if failures > 0 else 0)

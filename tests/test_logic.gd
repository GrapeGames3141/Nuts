extends SceneTree
const GameLogic = preload("res://scripts/game_logic.gd")
const LevelData = preload("res://scripts/level_data.gd")
var failures := 0
func expect(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        push_error("FAIL " + label)
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
        if level == 5 or level == 6 or level == 12 or level == 14: expect(d.theme.family == "pinecone" and d.theme.minor == "needle", "pine needle theme")
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
            expect(str(event.get("skin", "")) != "stick", "no stick skins")
            if event.kind != "limb": expect(str(event.get("skin", "")) != "branch", "branch is limb only")
            if event.kind == "acorn":
                expect(event.speed > 0.0, "positive acorn speed")
                var arrival := LevelData.acorn_arrival_time(event.time, event.speed)
                no_same_lane_conflicts = no_same_lane_conflicts and not LevelData.has_acorn_arrival_conflict(
                    scheduled_arrivals, event.lane, arrival, LevelData.acorn_arrival_safety_window(level))
                scheduled_arrivals.append({"lane": event.lane, "arrival": arrival})
            if event.kind == "limb":
                expect(event.skin == "branch" or event.skin == "icicle", "limb uses major skin")
                expect(event.warning >= 1.1, "fair limb warning")
                for target_event in d.events:
                    if target_event.kind == "acorn" and target_event.target:
                        expect(not LevelData.limb_conflicts_target(event.lane, event.width,
                            LevelData.limb_arrival_time(event.time, event.warning, event.speed),
                            {"lane": target_event.lane, "arrival": LevelData.acorn_arrival_time(target_event.time, target_event.speed)}),
                            "limb does not cover a required catch arrival")
        expect(no_same_lane_conflicts, "speed-aware same-lane arrivals are separated")
        var seeds_ok := true
        var seeded_skins_ok := true
        var leaf_variants := {}
        for seed in range(1,33):
            var seeded := LevelData.make(level, seed)
            seeds_ok = seeds_ok and GameLogic.simulate_level(level, seed)
            for event in seeded.events:
                seeded_skins_ok = seeded_skins_ok and str(event.get("skin", "")) != "stick"
                if event.kind != "limb":
                    seeded_skins_ok = seeded_skins_ok and str(event.get("skin", "")) != "branch"
                if event.get("skin", "") == "leaf": leaf_variants[event.variant] = true
        expect(seeds_ok, "32 deterministic seeds are solvable")
        expect(seeded_skins_ok, "32 seeded schedules keep branches limb-only")
        if level == 4 or level == 7 or level == 8: expect(leaf_variants.size() == 4, "all four generated leaf variants appear across seeds")
    expect(LevelData.level_count() == 50 and LevelData.CANOPY_NAMES.size() == 30 and LevelData.CANOPY_RECIPES.size() == 30, "fifty authored level definitions")
    var all_names := {}
    for level in range(1, 51):
        var authored_name := LevelData.level_name(level)
        expect(not authored_name.is_empty() and not all_names.has(authored_name), "level %d has a unique name" % level)
        all_names[authored_name] = true
        var canopy := LevelData.make(level, 1234)
        var canopy_repeat := LevelData.make(level, 1234)
        expect(canopy == canopy_repeat, "level %d repeats deterministically" % level)
        expect(LevelData.validate(canopy) and GameLogic.simulate_level(level, 1234), "level %d deterministic schedule is safe" % level)
        if level <= 20:
            expect(not bool(canopy.theme.get("play_limb", false)), "legacy level %d keeps its painted ground" % level)
        if level >= 21:
            expect(canopy.recipe.size() == 5 and canopy.theme.fall_speed_mode == "mixed", "canopy level %d has five mixed-speed items" % level)
            if level <= 35:
                expect(canopy.theme.play_limb and canopy.theme.play_limb_skin == "day" and canopy.theme.branch_mode == "stationary", "level %d uses the stationary day limb" % level)
            var acorn_speeds: Array[float] = []
            for speed_event in canopy.events:
                if speed_event.kind == "acorn": acorn_speeds.append(float(speed_event.speed))
            expect(acorn_speeds.max() - acorn_speeds.min() > canopy.speed_range * 0.35, "level %d visibly mixes fall speeds" % level)
        if level >= 26 and level <= 30:
            var gusts: Array = canopy.events.filter(func(event): return event.kind == "gust")
            var intermittent := gusts.size() >= 2
            for gust_index in range(1, gusts.size()):
                intermittent = intermittent and float(gusts[gust_index].time - gusts[gust_index - 1].time) > float(gusts[gust_index - 1].warning + gusts[gust_index - 1].duration)
            expect(intermittent and gusts.all(func(event): return event.warning >= 1.0 and abs(int(event.direction)) == 1), "level %d gusts are intermittent and telegraphed" % level)
        if level >= 31 and level <= 35:
            expect(canopy.events.any(func(event): return event.kind == "predator" and event.warning >= 1.2 and event.lane >= 0 and event.lane < 5), "level %d predator has a fixed warned lane" % level)
        if level >= 36 and level <= 40:
            expect(canopy.theme.play_limb and canopy.theme.play_limb_skin == "sway" and canopy.theme.branch_mode == "sway", "level %d uses the swaying play limb" % level)
        if level >= 41 and level <= 45:
            expect(canopy.theme.night and canopy.theme.fireflies and canopy.theme.background == "high_canopy_night", "level %d uses night fireflies" % level)
        if level >= 46:
            expect(canopy.theme.lightning and canopy.theme.finale_stage == level - 45 and canopy.theme.branch_mode == "sway", "level %d storm stage metadata" % level)
            var lightning_events: Array = canopy.events.filter(func(event): return event.kind == "lightning")
            expect(lightning_events.size() == canopy.recipe.size() and lightning_events.size() == 5, "level %d schedules lightning on every recipe beat" % level)
            expect(lightning_events.all(func(event): return is_equal_approx(float(event.warning), LevelData.LIGHTNING_WARNING_DURATION) and is_equal_approx(float(event.duration), LevelData.LIGHTNING_FLASH_DURATION)), "level %d uses balanced warning and flash timing" % level)
            var lightning_variants := {}
            for lightning_event in lightning_events: lightning_variants[int(lightning_event.variant)] = true
            expect(lightning_variants.size() == 3, "level %d cycles all lightning layouts" % level)
            expect(absf(LevelData.LIGHTNING_FLASH_DURATION / 2.35 - 0.5) < 0.02, "lightning cadence is approximately half bright")
            expect(bool(canopy.theme.get("gusts", false)) == (level >= 47), "storm gust escalation")
            expect(bool(canopy.theme.get("predators", false)) == (level >= 48), "storm predator escalation")
            expect(bool(canopy.theme.get("night", false)) == (level >= 49), "storm night escalation")
    var all_seeded_levels_safe := true
    for deterministic_seed in range(1, 33):
        for deterministic_level in range(1, 51):
            var seeded_a := LevelData.make(deterministic_level, deterministic_seed)
            var seeded_b := LevelData.make(deterministic_level, deterministic_seed)
            all_seeded_levels_safe = all_seeded_levels_safe and seeded_a == seeded_b and GameLogic.simulate_level(deterministic_level, deterministic_seed)
    expect(all_seeded_levels_safe, "32 deterministic seeds are reproducible and safe across all 50 levels")
    expect(LevelData.make(-5, 4).number == 1 and LevelData.make(99, 4).number == 50, "level requests clamp to the 50-level route")
    # Dodge through three complete authored schedules. The stream must retain
    # its cadence, complete mix, deterministic variation and target recurrence.
    for level in range(1, 51):
        var stream_definition := LevelData.make(level, 2468)
        var base_cycle: Array = stream_definition.events.duplicate(true)
        var continuation_one := LevelData.make_continuation(stream_definition, 2468, 1, base_cycle)
        var continuation_one_repeat := LevelData.make_continuation(stream_definition, 2468, 1, base_cycle)
        var continuation_two := LevelData.make_continuation(stream_definition, 2468, 2, continuation_one)
        var continuation_three := LevelData.make_continuation(stream_definition, 2468, 3, continuation_two)
        expect(continuation_one == continuation_one_repeat, "level %d continuation is deterministic" % level)
        expect(continuation_one.size() == base_cycle.size() and continuation_two.size() == base_cycle.size(), "level %d continuation retains event rate" % level)
        expect(is_equal_approx(float(continuation_one[0].time - base_cycle[0].time), LevelData.cycle_duration(stream_definition)), "level %d continuation has no boundary pause" % level)
        var full_stream: Array = base_cycle + continuation_one + continuation_two + continuation_three
        var stream_definition_with_continuations := {"number": level, "recipe": stream_definition.recipe, "events": full_stream}
        expect(LevelData.validate(stream_definition_with_continuations), "level %d cross-cycle arrival and limb safety" % level)
        var base_mix := {"acorn": 0, "leaf": 0, "limb": 0}
        var continuation_mix := {"acorn": 0, "leaf": 0, "limb": 0}
        var recurring_targets := {}
        var last_base_target_time := -1.0
        var first_continuation_target_time := -1.0
        for event in base_cycle:
            base_mix[event.kind] = int(base_mix.get(event.kind, 0)) + 1
            if event.kind == "acorn" and event.target:
                last_base_target_time = float(event.time)
        for event in continuation_one:
            continuation_mix[event.kind] = int(continuation_mix.get(event.kind, 0)) + 1
            if event.kind == "acorn" and event.target:
                recurring_targets[event.variant] = true
                if first_continuation_target_time < 0.0:
                    first_continuation_target_time = float(event.time)
        expect(base_mix == continuation_mix, "level %d continuation keeps authored composition" % level)
        expect(is_equal_approx(first_continuation_target_time - last_base_target_time, LevelData.cycle_duration(stream_definition) / stream_definition.recipe.size()), "level %d target cadence stays continuous across boundary" % level)
        var all_recipe_variants_recur := true
        for recipe_variant in stream_definition.recipe:
            all_recipe_variants_recur = all_recipe_variants_recur and recurring_targets.has(recipe_variant)
        expect(all_recipe_variants_recur, "level %d every needed variant recurs within one cycle" % level)
        if bool(stream_definition.leaves):
            expect(int(continuation_mix.leaf) > 0, "level %d minor hazards continue" % level)
        if bool(stream_definition.limbs):
            expect(int(continuation_mix.limb) > 0, "level %d major hazards continue" % level)

    var continuation_seed_safety := true
    for continuation_seed in range(1, 13):
        for continuation_level in range(1, 51):
            var continuation_definition := LevelData.make(continuation_level, continuation_seed)
            var first_cycle: Array = continuation_definition.events.duplicate(true)
            var second_cycle: Array = LevelData.make_continuation(continuation_definition, continuation_seed, 1, first_cycle)
            var third_cycle: Array = LevelData.make_continuation(continuation_definition, continuation_seed, 2, second_cycle)
            continuation_seed_safety = continuation_seed_safety and LevelData.validate({
                "number": continuation_level, "recipe": continuation_definition.recipe,
                "events": first_cycle + second_cycle + third_cycle
            })
    expect(continuation_seed_safety, "12 deterministic seeds keep all 50 cross-cycle schedules fair")

    print("TEST_FAILURES=", failures)
    quit(1 if failures > 0 else 0)

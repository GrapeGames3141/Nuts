"""Regression checks for packed squirrel connectivity, padding, and head recovery."""
from pathlib import Path
from PIL import Image

root = Path(__file__).parents[1]
source = Image.open(root / "assets/art/squirrel_sheet_clean.png").convert("RGBA")
atlas = Image.open(root / "assets/art/squirrel_sheet_packed.png").convert("RGBA")
source_cell_w, source_cell_h = source.width // 4, source.height // 3
repairs = {
    8: root / "assets/art/squirrel_idle_head_repair_v1.png",
    11: root / "assets/art/squirrel_pop_head_repair_v1.png",
}


def dominant_component(image: Image.Image, require_single: bool = True) -> tuple[set[tuple[int, int]], tuple[int, int, int, int]]:
    alpha = image.getchannel("A")
    points = {(x, y) for y in range(image.height) for x in range(image.width) if alpha.getpixel((x, y)) > 8}
    assert points, "frame is empty"
    components: list[set[tuple[int, int]]] = []
    while points:
        start = points.pop()
        connected, queue = {start}, [start]
        while queue:
            x, y = queue.pop()
            for yy in range(y - 1, y + 2):
                for xx in range(x - 1, x + 2):
                    if (xx, yy) in points:
                        points.remove((xx, yy))
                        connected.add((xx, yy))
                        queue.append((xx, yy))
        components.append(connected)
    if require_single:
        assert len(components) == 1, f"frame has detached alpha debris ({sum(len(component) for component in components[1:])} pixels)"
    connected = max(components, key=len)
    xs, ys = zip(*connected)
    return connected, (min(xs), min(ys), max(xs) + 1, max(ys) + 1)


packed_bounds: dict[int, tuple[int, int, int, int]] = {}
for frame in range(12):
    cell = atlas.crop(((frame % 4) * 512, (frame // 4) * 512, (frame % 4 + 1) * 512, (frame // 4 + 1) * 512))
    _, bounds = dominant_component(cell)
    packed_bounds[frame] = bounds
    min_padding = 24 if frame in repairs else 48
    assert bounds[0] >= 48 and bounds[2] <= 464 and bounds[1] >= min_padding and bounds[3] <= 464, f"frame {frame} lacks safe padding"

# Frame 8's actual source silhouette touches the cell top. Its previous packed
# height was 247 (56..303); preserve its feet while retaining that head edge.
source_frame = 8
x, y = (source_frame % 4) * source_cell_w, (source_frame // 4) * source_cell_h
source_pose = source.crop((x + 10, y, x + source_cell_w - 10, y + source_cell_h - 10))
_, source_bounds = dominant_component(source_pose, require_single=False)
frame8 = packed_bounds[source_frame]
assert source_bounds[1] == 0, "frame 8 source no longer proves top-edge head recovery"
assert frame8[1] >= 24 and frame8[1] == 29, f"frame 8 top padding regressed: {frame8}"
assert frame8[3] == 303, f"frame 8 foot anchor moved: {frame8}"
assert frame8[3] - frame8[1] == 274 and frame8[3] - frame8[1] > 247, f"frame 8 did not recover head height: {frame8}"

for frame, repair_path in repairs.items():
    repair = Image.open(repair_path).convert("RGBA")
    _, repair_bounds = dominant_component(repair)
    x, y = (frame % 4) * source_cell_w, (frame // 4) * source_cell_h
    source_cell = source.crop((x, y, x + source_cell_w, y + source_cell_h))
    _, original_bounds = dominant_component(source_cell, require_single=False)
    assert repair_bounds[1] > 0, f"frame {frame} repair touches its canvas top"
    assert repair_bounds[3] - repair_bounds[1] > original_bounds[3] - original_bounds[1], f"frame {frame} repair lacks reconstructed head extent"
    top_alpha = [x for x in range(repair.width) if repair.getpixel((x, repair_bounds[1]))[3] > 8]
    assert len(top_alpha) < 32, f"frame {frame} repair retains a flat cropped top edge"
    packed = packed_bounds[frame]
    assert packed[2] - packed[0] == repair_bounds[2] - repair_bounds[0], f"frame {frame} repair width was resized: {packed} != {repair_bounds}"
    assert packed[3] - packed[1] == repair_bounds[3] - repair_bounds[1], f"frame {frame} repair height was resized: {packed} != {repair_bounds}"

assert packed_bounds[11][1] >= 24 and packed_bounds[11][1] == 31 and packed_bounds[11][3] == 272, f"frame 11 head/feet regressed: {packed_bounds[11]}"
print("SPRITE_ATLAS_HEAD_RECOVERY_PASS", packed_bounds[8], packed_bounds[11])

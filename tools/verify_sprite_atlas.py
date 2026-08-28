"""Regression checks for complete, padded squirrel atlas cells."""
from pathlib import Path
from PIL import Image, ImageChops

root = Path(__file__).parents[1]
atlas = Image.open(root / "assets/art/squirrel_sheet_packed.png").convert("RGBA")
repairs = {
    8: root / "assets/art/squirrel_idle_full_v2.png",
    10: root / "assets/art/squirrel_flatten_hold_full_v1.png",
    11: root / "assets/art/squirrel_pop_full_v2.png",
}

def dominant_component(image: Image.Image) -> tuple[set[tuple[int, int]], tuple[int, int, int, int]]:
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
    assert len(components) == 1, f"frame has detached alpha debris ({len(components)} components)"
    connected = components[0]
    xs, ys = zip(*connected)
    return connected, (min(xs), min(ys), max(xs) + 1, max(ys) + 1)

assert atlas.size == (2048, 1536), atlas.size
packed_bounds: dict[int, tuple[int, int, int, int]] = {}
for frame in range(12):
    cell = atlas.crop(((frame % 4) * 512, (frame // 4) * 512, (frame % 4 + 1) * 512, (frame // 4 + 1) * 512))
    _, bounds = dominant_component(cell)
    packed_bounds[frame] = bounds
    assert bounds[0] >= 48 and bounds[2] <= 464, f"frame {frame} lacks horizontal padding: {bounds}"
    assert bounds[1] >= 48 and bounds[3] == 464, f"frame {frame} lacks ground padding/anchor: {bounds}"

for frame, repair_path in repairs.items():
    repair = Image.open(repair_path).convert("RGBA")
    alpha = repair.getchannel("A")
    assert alpha.getextrema()[0] == 0, f"frame {frame} repair has no transparent alpha"
    bounds = alpha.getbbox()
    assert bounds and alpha.histogram()[0] > repair.width * repair.height // 4, f"frame {frame} repair is not materially transparent: {bounds}"

# Right-side atlas cells must always be deterministic mirrors of intact left cells.
for right, left in ((4, 0), (5, 1), (6, 2), (7, 3)):
    left_cell = atlas.crop((left * 512, 0, (left + 1) * 512, 512))
    right_cell = atlas.crop(((right - 4) * 512, 512, (right - 3) * 512, 1024))
    expected = left_cell.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    assert ImageChops.difference(expected, right_cell).getbbox() is None, f"right run frame {right} is not a clean mirror of {left}"

print("SPRITE_ATLAS_COMPLETE_PASS", packed_bounds)

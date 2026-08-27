"""Regression check: each packed atlas cell has one connected sprite component."""
from pathlib import Path
from PIL import Image

atlas = Image.open(Path(__file__).parents[1] / "assets/art/squirrel_sheet_packed.png").convert("RGBA")
for frame in range(12):
    cell = atlas.crop(((frame % 4) * 512, (frame // 4) * 512, (frame % 4 + 1) * 512, (frame // 4 + 1) * 512))
    points = {(x, y) for y in range(512) for x in range(512) if cell.getpixel((x, y))[3] > 8}
    assert points, f"frame {frame} is empty"
    start = points.pop()
    connected, queue = {start}, [start]
    while queue:
        x, y = queue.pop()
        for yy in range(y - 1, y + 2):
            for xx in range(x - 1, x + 2):
                if (xx, yy) in points:
                    points.remove((xx, yy)); connected.add((xx, yy)); queue.append((xx, yy))
    assert not points, f"frame {frame} has detached alpha debris ({len(points)} pixels)"
    xs, ys = zip(*connected)
    assert min(xs) >= 48 and max(xs) <= 463 and min(ys) >= 48 and max(ys) <= 463, f"frame {frame} lacks safe padding"
print("SPRITE_ATLAS_COMPONENTS_PASS")

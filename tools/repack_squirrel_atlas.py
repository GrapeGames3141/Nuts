"""Deterministically pack complete, padded squirrel animation poses."""
from pathlib import Path
from PIL import Image

root = Path(__file__).parents[1]
src = root / "assets/art/squirrel_sheet_clean.png"
dst = root / "assets/art/squirrel_sheet_packed.png"
out = 512
safe_padding = 48
max_pose = out - safe_padding * 2
repairs = {
    8: root / "assets/art/squirrel_idle_full_v2.png",
    10: root / "assets/art/squirrel_flatten_hold_full_v1.png",
    # Pop ends on the full standing pose rather than retaining clipped airborne source art.
    11: root / "assets/art/squirrel_pop_full_v2.png",
}
# Source right-run cells 4,6,7 are tail-clipped; rebuild all right cells from intact left cells.
mirrored_sources = {4: 0, 5: 1, 6: 2, 7: 3}

def clean_components(pose: Image.Image) -> Image.Image:
    alpha = pose.getchannel("A")
    width, height = pose.size
    opaque = {(x, y) for y in range(height) for x in range(width) if alpha.getpixel((x, y)) > 8}
    if not opaque:
        return pose
    components: list[set[tuple[int, int]]] = []
    while opaque:
        start = opaque.pop()
        component, frontier = {start}, [start]
        while frontier:
            px, py = frontier.pop()
            for ny in range(py - 1, py + 2):
                for nx in range(px - 1, px + 2):
                    point = (nx, ny)
                    if point in opaque:
                        opaque.remove(point)
                        component.add(point)
                        frontier.append(point)
        components.append(component)
    main = max(components, key=len)
    result = Image.new("RGBA", pose.size, (0, 0, 0, 0))
    pixels, cleaned = pose.load(), result.load()
    for x, y in main:
        cleaned[x, y] = pixels[x, y]
    return result

source = Image.open(src).convert("RGBA")
cell_w, cell_h = source.width // 4, source.height // 3
packed = Image.new("RGBA", (out * 4, out * 3), (0, 0, 0, 0))
for index in range(12):
    if index in repairs:
        pose = Image.open(repairs[index]).convert("RGBA")
    else:
        source_index = mirrored_sources.get(index, index)
        sx, sy = (source_index % 4) * cell_w, (source_index // 4) * cell_h
        pose = source.crop((sx + 10, sy + 10, sx + cell_w - 10, sy + cell_h - 10))
        if index in mirrored_sources:
            pose = pose.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    pose = clean_components(pose)
    bbox = pose.getchannel("A").getbbox()
    if not bbox:
        raise RuntimeError(f"squirrel frame {index} is empty")
    pose = pose.crop(bbox)
    pose.thumbnail((max_pose, max_pose), Image.Resampling.LANCZOS)
    # Resampling can introduce a one-pixel transparent-edge fleck. Remove it
    # after scaling so every runtime cell remains one clean silhouette.
    pose = clean_components(pose)
    # Every pose lands on a shared, safely padded ground anchor.
    px = (index % 4) * out + (out - pose.width) // 2
    py = (index // 4) * out + out - safe_padding - pose.height
    packed.alpha_composite(pose, (px, py))
# Copy final pixels from the intact left-run cells so every stored right-run
# cell is an exact deterministic mirror, independent of resize interpolation.
for right, left in ((4, 0), (5, 1), (6, 2), (7, 3)):
    left_cell = packed.crop((left * out, 0, (left + 1) * out, out))
    packed.paste(left_cell.transpose(Image.Transpose.FLIP_LEFT_RIGHT), ((right - 4) * out, out))
packed.save(dst)
print(dst)

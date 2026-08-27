"""Deterministically repack generated poses, removing disconnected atlas bleed."""
from PIL import Image
from pathlib import Path

src = Path(__file__).parents[1] / "assets/art/squirrel_sheet_clean.png"
dst = Path(__file__).parents[1] / "assets/art/squirrel_sheet_packed.png"
im = Image.open(src).convert("RGBA")
cell_w, cell_h, out = im.width // 4, im.height // 3, 512
packed = Image.new("RGBA", (out * 4, out * 3), (0, 0, 0, 0))

def clean_components(pose: Image.Image) -> Image.Image:
    """Keep exactly the dominant 8-connected pose component.

    The generated sheet has occasional pieces of the neighboring pose over a cell
    edge.  They are disconnected and tiny compared with the actual squirrel.
    """
    alpha = pose.getchannel("A")
    width, height = pose.size
    opaque = {(x, y) for y in range(height) for x in range(width) if alpha.getpixel((x, y)) > 8}
    components = []
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
    if not components:
        return pose
    main = max(components, key=len)
    # The approved sheet's true pose is one solid silhouette in every frame.
    # Keep exactly its dominant component: anything disconnected is neighbor-cell
    # bleed, not a playable part of this compact sprite.
    keep = set(main)
    result = Image.new("RGBA", pose.size, (0, 0, 0, 0))
    pixels, cleaned = pose.load(), result.load()
    for x, y in keep:
        cleaned[x, y] = pixels[x, y]
    return result

for index in range(12):
    x, y = (index % 4) * cell_w, (index // 4) * cell_h
    # Omit edge bleed from adjacent generated cells, retain the pose at native size.
    pose = im.crop((x + 10, y + 10, x + cell_w - 10, y + cell_h - 10))
    pose = clean_components(pose)
    alpha = pose.getchannel("A")
    bbox = alpha.getbbox()
    if bbox:
        pose = pose.crop(bbox)
        if pose.width > out - 96 or pose.height > out - 96:
            pose.thumbnail((out - 96, out - 96), Image.Resampling.LANCZOS)
        px = (index % 4) * out + (out - pose.width) // 2
        py = (index // 4) * out + 56
        packed.alpha_composite(pose, (px, py))
packed.save(dst)
print(dst)

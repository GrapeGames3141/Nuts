"""Verify the cleaned branch is one component without cyan snowflake spill."""
from pathlib import Path
from PIL import Image

branch = Image.open(Path(__file__).parents[1] / "assets/art/items/branch_clean_v1.png").convert("RGBA")
alpha = branch.getchannel("A")
points = {(x, y) for y in range(branch.height) for x in range(branch.width) if alpha.getpixel((x, y)) > 8}
assert points, "clean branch is empty"
components: list[set[tuple[int, int]]] = []
while points:
    start = points.pop()
    component, queue = {start}, [start]
    while queue:
        x, y = queue.pop()
        for yy in range(y - 1, y + 2):
            for xx in range(x - 1, x + 2):
                if (xx, yy) in points:
                    points.remove((xx, yy))
                    component.add((xx, yy))
                    queue.append((xx, yy))
    components.append(component)
assert len(components) == 1, f"branch has detached alpha components: {len(components)}"
cyan_spill = 0
for x, y in components[0]:
    r, g, b, _ = branch.getpixel((x, y))
    if b > 140 and b > r * 1.18 and b > g * 1.05:
        cyan_spill += 1
assert cyan_spill == 0, f"branch has cyan snowflake spill: {cyan_spill} pixels"
print("BRANCH_HAZARD_CLEAN_PASS", branch.size, len(components[0]))

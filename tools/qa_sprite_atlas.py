"""Render every runtime squirrel atlas frame to a durable visual QA sheet."""
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).parents[1]
atlas = Image.open(root / "assets/art/squirrel_sheet_packed.png").convert("RGBA")
cell = 512
labels = [
    "run L 0", "run L 1", "run L 2", "run L 3",
    "mirrored R 0", "mirrored R 1", "mirrored R 2", "mirrored R 3",
    "idle", "flatten impact", "flatten hold", "pop stand",
]
sheet = Image.new("RGBA", (4 * 320, 3 * 352), (39, 45, 42, 255))
draw = ImageDraw.Draw(sheet)
for frame, label in enumerate(labels):
    pose = atlas.crop(((frame % 4) * cell, (frame // 4) * cell, (frame % 4 + 1) * cell, (frame // 4 + 1) * cell))
    pose.thumbnail((288, 288), Image.Resampling.LANCZOS)
    x = (frame % 4) * 320 + (320 - pose.width) // 2
    y = (frame // 4) * 352 + 40 + (288 - pose.height) // 2
    sheet.alpha_composite(pose, (x, y))
    draw.text(((frame % 4) * 320 + 16, (frame // 4) * 352 + 14), label, fill=(255, 244, 202, 255))
out = root / "build/qa_squirrel_animation_complete.jpg"
out.parent.mkdir(exist_ok=True)
sheet.convert("RGB").save(out, quality=92)
print(out)

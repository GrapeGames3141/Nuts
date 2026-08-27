"""Deterministically removes generated neutral checkerboard from each 4x3 cell."""
from PIL import Image
from collections import deque
import sys
src, dst = sys.argv[1:3]
im = Image.open(src).convert("RGBA")
pixels = im.load()
w, h = im.size
for cy in range(3):
    for cx in range(4):
        x0, y0 = cx*w//4, cy*h//3
        x1, y1 = (cx+1)*w//4, (cy+1)*h//3
        todo, seen = deque(), set()
        for x in range(x0, x1): todo.extend(((x,y0),(x,y1-1)))
        for y in range(y0, y1): todo.extend(((x0,y),(x1-1,y)))
        while todo:
            x,y = todo.popleft()
            if (x,y) in seen or not (x0 <= x < x1 and y0 <= y < y1): continue
            seen.add((x,y)); r,g,b,a = pixels[x,y]
            if max(r,g,b)-min(r,g,b) >= 13 or min(r,g,b) <= 185: continue
            pixels[x,y] = (r,g,b,0)
            todo.extend(((x-1,y),(x+1,y),(x,y-1),(x,y+1)))
im.save(dst)

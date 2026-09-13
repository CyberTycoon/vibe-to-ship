#!/usr/bin/env python3
"""Render terminal-styled frames into an animated GIF (OpenLotus theme).

Fallback renderer for platforms where VHS/ttyd cannot run. Frames are plain
text with simple inline markup:
  {g:text}  green   {y:text}  yellow   {r:text}  red
  {b:text}  blue    {d:text}  dim      {w:text}  bright white (bold look)
Usage: python render_gif.py frames.py
where frames.py is a module defining FRAMES = [(text, duration_ms), ...]
"""
import re
import sys
import importlib.util

from PIL import Image, ImageDraw, ImageFont

BG = (13, 13, 12)
FG = (246, 245, 242)
DIM = (124, 122, 117)
GREEN = (70, 167, 88)
YELLOW = (245, 166, 35)
RED = (229, 72, 77)
BLUE = (82, 169, 255)
BAR = (35, 35, 33)

FONT_CANDIDATES = [
    "C:/Windows/Fonts/JetBrainsMono-Regular.ttf",
    "C:/Windows/Fonts/cas-menlo-bold.ttf",
    "C:/Windows/Fonts/consola.ttf",
    "C:/Windows/Fonts/lucon.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
]

def load_font(size: int) -> ImageFont.FreeTypeFont:
    for p in FONT_CANDIDATES:
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            continue
    return ImageFont.load_default()

COLORS = {"g": GREEN, "y": YELLOW, "r": RED, "b": BLUE, "d": DIM, "w": FG}
TOKEN = re.compile(r"\{([gyrbdw])(.*?)(?<!\\)\}", re.S)

def draw_frame(lines, w, h, font, pad=28):
    img = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(img)
    # title bar
    d.rectangle([0, 0, w, 44], fill=BAR)
    for i, c in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
        d.ellipse([20 + i * 26, 16, 34 + i * 26, 30], fill=c)
    title = "agent — vibe-to-ship"
    tw = d.textlength(title, font=font)
    d.text(((w - tw) // 2, 13), title, font=font, fill=DIM)
    y = pad + 30
    for line in lines:
        x = pad
        pos = 0
        for m in TOKEN.finditer(line):
            if m.start() > pos:
                d.text((x, y), line[pos:m.start()], font=font, fill=FG)
                x += d.textlength(line[pos:m.start()], font=font)
            color = COLORS.get(m.group(1), FG)
            text = m.group(2).replace("\\{", "{")
            d.text((x, y), text, font=font, fill=color)
            x += d.textlength(text, font=font)
            pos = m.end()
        if pos < len(line):
            d.text((x, y), line[pos:], font=font, fill=FG)
        y += 30
    # cursor
    d.rectangle([pad, y, pad + 14, y + 22], fill=FG)
    return img

def main(frames_module: str, out: str = "../assets/demo.gif"):
    spec = importlib.util.spec_from_file_location("frames", frames_module)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    frames = mod.FRAMES
    font = load_font(19)
    w, h = 1180, 640
    imgs = [draw_frame(f, w, h, font) for f, _ in frames]
    durations = [d for _, d in frames]
    imgs[0].save(out, save_all=True, append_images=imgs[1:],
                 duration=durations, loop=0, optimize=True)
    print(f"wrote {out}: {len(imgs)} frames, {sum(durations)}ms total")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "../assets/demo.gif")

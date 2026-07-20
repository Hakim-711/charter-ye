#!/usr/bin/env python3

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "web" / "social-preview.png"
FONT_DIR = ROOT / "assets" / "fonts"


def font(name, size):
    return ImageFont.truetype(str(FONT_DIR / name), size=size)


def build():
    image = Image.new("RGB", (1200, 630), "#121417")
    draw = ImageDraw.Draw(image)
    draw.ellipse((900, -240, 1380, 240), fill="#28241d")
    draw.ellipse((-220, 420, 220, 860), fill="#1d2125")
    draw.rounded_rectangle((72, 65, 198, 191), radius=24, fill="#ffffff")
    draw.rounded_rectangle((88, 81, 132, 175), radius=14, fill="#121417")
    draw.rounded_rectangle((146, 81, 182, 117), radius=11, fill="#bb8732")
    draw.rounded_rectangle((146, 131, 182, 175), radius=11, fill="#121417")
    draw.rectangle((72, 250, 230, 258), fill="#bb8732")
    draw.text(
        (72, 292),
        "CHARTER",
        font=font("PlusJakartaSans-ExtraBold.ttf", 72),
        fill="#ffffff",
    )
    draw.text(
        (72, 385),
        "GENERAL CONTRACTING, SERVICES & SUPPLIES",
        font=font("PlusJakartaSans-Bold.ttf", 32),
        fill="#ffffff",
    )
    draw.text(
        (72, 446),
        "Engineering. Logistics. Integrated Supply.",
        font=font("PlusJakartaSans-Regular.ttf", 27),
        fill="#bfc3c7",
    )
    draw.text(
        (72, 538),
        "MARIB  |  ADEN  |  YEMEN",
        font=font("PlusJakartaSans-Bold.ttf", 20),
        fill="#bb8732",
    )
    image.save(OUTPUT, format="PNG", optimize=True)
    print(OUTPUT)


if __name__ == "__main__":
    build()

"""Generate Splitr. brand PNG assets from Albra Semi."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT_PATH = ROOT / "assets/fonts/Albra Serif Font/AlbraTRIAL-Semi.otf"
OUT = ROOT / "assets/brand"
TEXT = "Splitr."
DARK = (13, 13, 13, 255)
WHITE = (255, 255, 255, 255)
DARK_BG = (13, 13, 13, 255)


def _load_font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_PATH), size=size)


def _text_bbox(font: ImageFont.FreeTypeFont, text: str) -> tuple[int, int, int, int]:
    probe = Image.new("RGBA", (4, 4), (0, 0, 0, 0))
    draw = ImageDraw.Draw(probe)
    return draw.textbbox((0, 0), text, font=font)


def _fit_font_size(
    text: str,
    target_w: int,
    target_h: int,
    padding_ratio: float = 0.12,
) -> ImageFont.FreeTypeFont:
    inner_w = int(target_w * (1 - padding_ratio * 2))
    inner_h = int(target_h * (1 - padding_ratio * 2))

    lo, hi = 8, max(inner_w, inner_h)
    best = _load_font(lo)
    while lo <= hi:
        mid = (lo + hi) // 2
        font = _load_font(mid)
        bbox = _text_bbox(font, text)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        if tw <= inner_w and th <= inner_h:
            best = font
            lo = mid + 1
        else:
            hi = mid - 1
    return best


def render_text_image(
    canvas_w: int,
    canvas_h: int,
    *,
    text_color: tuple[int, int, int, int],
    bg_color: tuple[int, int, int, int] | None,
    padding_ratio: float = 0.12,
) -> Image.Image:
    font = _fit_font_size(TEXT, canvas_w, canvas_h, padding_ratio)
    bbox = _text_bbox(font, TEXT)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]

    if bg_color is None:
        img = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    else:
        img = Image.new("RGBA", (canvas_w, canvas_h), bg_color)

    draw = ImageDraw.Draw(img)
    x = (canvas_w - tw) // 2 - bbox[0]
    y = (canvas_h - th) // 2 - bbox[1]
    draw.text((x, y), TEXT, font=font, fill=text_color)
    return img


def render_master(target_width: int) -> Image.Image:
  font_size = 512
  font = _load_font(font_size)
  bbox = _text_bbox(font, TEXT)
  tw = bbox[2] - bbox[0]
  th = bbox[3] - bbox[1]
  pad_x = int(tw * 0.08)
  pad_y = int(th * 0.20)
  raw_w = tw + pad_x * 2
  raw_h = th + pad_y * 2
  scale = target_width / raw_w
  canvas_w = target_width
  canvas_h = max(1, int(raw_h * scale))

  img = Image.new("RGBA", (canvas_w, canvas_h), WHITE)
  scaled_font = _load_font(max(8, int(font_size * scale)))
  bbox = _text_bbox(scaled_font, TEXT)
  tw = bbox[2] - bbox[0]
  th = bbox[3] - bbox[1]
  draw = ImageDraw.Draw(img)
  x = (canvas_w - tw) // 2 - bbox[0]
  y = (canvas_h - th) // 2 - bbox[1]
  draw.text((x, y), TEXT, font=scaled_font, fill=DARK)
  return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "master").mkdir(exist_ok=True)
    (OUT / "play-store").mkdir(exist_ok=True)
    (OUT / "adaptive").mkdir(exist_ok=True)
    (OUT / "favicon").mkdir(exist_ok=True)

    master = render_master(2048)
    master.save(OUT / "master" / "splitr-wordmark-dark-2048w.png", optimize=True)

    play_icon = render_text_image(512, 512, text_color=DARK, bg_color=WHITE)
    play_icon.save(OUT / "play-store" / "app-icon-512.png", optimize=True)

    adaptive_fg = render_text_image(
        432, 432, text_color=WHITE, bg_color=None, padding_ratio=0.14
    )
    adaptive_fg.save(OUT / "adaptive" / "ic_launcher_foreground.png", optimize=True)

    adaptive_bg = Image.new("RGBA", (432, 432), DARK_BG)
    adaptive_bg.save(OUT / "adaptive" / "ic_launcher_background.png", optimize=True)

    feature = render_text_image(
        1024, 500, text_color=DARK, bg_color=WHITE, padding_ratio=0.10
    )
    feature.save(OUT / "play-store" / "feature-graphic-1024x500.png", optimize=True)

    for size in (16, 32, 48, 64, 128, 256):
        fav = render_text_image(size, size, text_color=DARK, bg_color=WHITE, padding_ratio=0.08)
        fav.save(OUT / "favicon" / f"favicon-{size}.png", optimize=True)

    print("Generated brand assets in", OUT)


if __name__ == "__main__":
    main()

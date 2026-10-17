import json, os
APP = r"C:/Users/DILITECH/Documents/GitHub/lyra/app"
import pathlib
os.chdir(pathlib.Path(__file__).parent)
j = json.load(open("wm.json")); s = j["scale"]; C = j["curves"]
OX, OY = 18.0, 40.0                     # origine : coin haut-gauche des lettres
W, H = 600.0, 267.0                     # boîte du logo (LYRA + MUSIC)
P = lambda v: round(v / s, 2)

def pts(c):
    out = [("M", P(c["start"][0]) - OX, P(c["start"][1]) - OY)]
    for g in c["segs"]:
        if g[0] == "L":
            out += [("L", P(g[1]) - OX, P(g[2]) - OY), ("L", P(g[3]) - OX, P(g[4]) - OY)]
        else:
            out += [("C", P(g[1]) - OX, P(g[2]) - OY, P(g[3]) - OX, P(g[4]) - OY, P(g[5]) - OX, P(g[6]) - OY)]
    return out

def svgd(ids, tx=0, ty=0, k=1.0):
    d = ""
    for i in ids:
        for p in pts(C[i]):
            v = [round((x + (tx if n % 2 == 0 else ty)) * k, 2) for n, x in enumerate(p[1:])]
            d += p[0] + " ".join(f"{x:g}" for x in v)
        d += "Z"
    return d

def dart(ids):
    lines = []
    for i in ids:
        for p in pts(C[i]):
            a = ", ".join(f"{x:g}" for x in p[1:])
            lines.append({"M": f"    ..moveTo({a})", "L": f"    ..lineTo({a})", "C": f"    ..cubicTo({a})"}[p[0]])
        lines.append("    ..close()")
    return "\n".join(lines)

GROUPS = {
    "letterL": [9], "letterY": [8], "letterR": [6], "letterA": [7, 13],
    "vinyl": [10, 11, 12, 14, 15, 16, 17, 18, 19, 20],
    "music": [4, 2, 1, 5, 3],
    "musicM": [4], "musicU": [2], "musicS": [1], "musicI": [5], "musicC": [3],
}
# Centre du vinyle = centre du trou central (courbe 15)
b = C[15]["bbox"]; cx = round((b[0] + b[2]) / 2 / s - OX, 2); cy = round((b[1] + b[3]) / 2 / s - OY, 2)
rb = C[6]["bbox"]; rx0, ry0, rx1, ry1 = [P(v) for v in rb]; rx0 -= OX; rx1 -= OX; ry0 -= OY; ry1 -= OY

code = ["// GÉNÉRÉ depuis assets/logo/logo_concept_1.png (vectorisation potrace) — ne pas modifier à la main.",
        "// Voir app/assets/brand/source/README.md.", "import 'dart:ui';", "",
        f"const logoSize = Size({W:g}, {H:g});", f"const vinylCenter = Offset({cx:g}, {cy:g});",
        f"const letterRBounds = Rect.fromLTRB({rx0:g}, {ry0:g}, {rx1:g}, {ry1:g});", ""]
for name, ids in GROUPS.items():
    code.append(f"Path {name}() => Path()\n    ..fillType = PathFillType.evenOdd\n{dart(ids)};\n")
os.makedirs(f"{APP}/lib/ui/brand", exist_ok=True)
open(f"{APP}/lib/ui/brand/logo_paths.dart", "w", encoding="utf-8").write("\n".join(code))

INK, PAPER = "#111111", "#F3EBD8"
letters = GROUPS["letterL"] + GROUPS["letterY"] + GROUPS["letterA"] + GROUPS["music"]
rglyph = GROUPS["letterR"] + GROUPS["vinyl"]                      # R + vinyle en trous (evenodd)
logo_d = svgd(letters) + svgd(rglyph)
out = f"{APP}/assets/brand/logo"; os.makedirs(out, exist_ok=True)
for name, ink, paper in [("lyra-logo-clair", INK, PAPER), ("lyra-logo-sombre", PAPER, INK)]:
    open(f"{out}/{name}.svg", "w", encoding="utf-8").write(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="-40 -40 {W+80:g} {H+80:g}"><rect x="-40" y="-40" width="{W+80:g}" height="{H+80:g}" rx="36" fill="{paper}"/>'
        f'<path fill="{ink}" fill-rule="evenodd" d="{logo_d}"/></svg>')
open(f"{out}/lyra-logo-transparent.svg", "w", encoding="utf-8").write(
    f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W:g} {H:g}"><path fill="{INK}" fill-rule="evenodd" d="{logo_d}"/></svg>')

# Symbole R dans une tuile carrée 512 : R haut de 58 %
rh = ry1 - ry0; rw = rx1 - rx0; k = 512 * 0.58 / rh
tx = (512 / k - rw) / 2 - rx0; ty = (512 / k - rh) / 2 - ry0
sym_d = svgd(rglyph, tx, ty, k)
for name, ink, paper in [("lyra-symbole-sombre", PAPER, INK), ("lyra-symbole-clair", INK, PAPER)]:
    open(f"{out}/{name}.svg", "w", encoding="utf-8").write(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><rect width="512" height="512" rx="116" fill="{paper}"/>'
        f'<path fill="{ink}" fill-rule="evenodd" d="{sym_d}"/></svg>')

# Android : vecteurs (pathData = syntaxe SVG)
res = f"{APP}/android/app/src/main/res/drawable"
def vector(name, size, d, color, extra=""):
    open(f"{res}/{name}.xml", "w", encoding="utf-8").write(
        f'<?xml version="1.0" encoding="utf-8"?>\n<!-- GÉNÉRÉ depuis le logo concept 1 (R-vinyle) -->\n'
        f'<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="{size}dp" android:height="{size}dp"'
        f' android:viewportWidth="{size}" android:viewportHeight="{size}">{extra}\n'
        f'    <path android:fillColor="{color}" android:fillType="evenOdd" android:pathData="{d}"/>\n</vector>\n')
def fit(box, frac):
    k = box * frac / rh; return svgd(rglyph, (box / k - rw) / 2 - rx0, (box / k - rh) / 2 - ry0, k)
vector("ic_launcher_foreground", 108, fit(108, 0.46), "#FFF3EBD8")
vector("ic_launcher_monochrome", 108, fit(108, 0.46), "#FFFFFFFF")
vector("ic_stat_lyra", 24, fit(24, 0.86), "#FFFFFFFF")
vector("splash_logo", 96, fit(96, 0.58), "#FFF3EBD8",
       '\n    <path android:fillColor="#FF111111" android:pathData="M26,0h44a26,26 0,0 1,26 26v44a26,26 0,0 1,-26 26h-44a26,26 0,0 1,-26 -26v-44a26,26 0,0 1,26 -26z"/>')
print("ok", cx, cy, (rx0, ry0, rx1, ry1))

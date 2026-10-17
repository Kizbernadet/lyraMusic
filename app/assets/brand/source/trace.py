import sys, json
import numpy as np
from PIL import Image, ImageFilter
import potrace

def bitmap(path, box, scale=4, thr=110):
    im = Image.open(path).convert("L").crop(box)
    im = im.resize((im.width*scale, im.height*scale), Image.LANCZOS).filter(ImageFilter.GaussianBlur(1.2))
    a = np.array(im) < thr
    return a, scale

def trace(a):
    bm = potrace.Bitmap(a)
    plist = bm.trace(turdsize=40, alphamax=1.0, opticurve=True, opttolerance=0.3)
    out = []
    for curve in plist:
        segs = []
        for s in curve.segments:
            if s.is_corner:
                segs.append(("L", s.c.x, s.c.y, s.end_point.x, s.end_point.y))
            else:
                segs.append(("C", s.c1.x, s.c1.y, s.c2.x, s.c2.y, s.end_point.x, s.end_point.y))
        sp = curve.start_point
        xs=[sp.x]+[v for sg in segs for v in sg[1::2]]; ys=[sp.y]+[v for sg in segs for v in sg[2::2]]
        out.append({"start":(sp.x,sp.y),"segs":segs,"bbox":(min(xs),min(ys),max(xs),max(ys))})
    return out

if __name__ == "__main__":
    a, s = bitmap(r"C:/Users/DILITECH/Documents/GitHub/lyra/assets/logo/logo_concept_1.png", (60,190,700,520))
    curves = trace(a)
    for i,c in enumerate(curves):
        b=c["bbox"]; print(i, [round(v/s,1) for v in b], len(c["segs"]))
    json.dump({"scale":s,"curves":curves}, open("wm.json","w"))

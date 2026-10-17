import json, sys
def d_of(c, s):
    f=lambda v: f"{v/s:.2f}"
    d=f"M{f(c['start'][0])} {f(c['start'][1])}"
    for g in c['segs']:
        if g[0]=='L': d+=f"L{f(g[1])} {f(g[2])}L{f(g[3])} {f(g[4])}"
        else: d+=f"C{f(g[1])} {f(g[2])} {f(g[3])} {f(g[4])} {f(g[5])} {f(g[6])}"
    return d+"Z"
if __name__=="__main__":
    j=json.load(open(sys.argv[1])); s=j['scale']
    keep=[int(x) for x in sys.argv[2].split(',')]
    d="".join(d_of(j['curves'][i],s) for i in keep)
    w,h=sys.argv[3].split('x')
    open(sys.argv[4],"w").write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{int(w)*2}" height="{int(h)*2}"><rect width="100%" height="100%" fill="#F3EBD8"/><path fill="#111111" fill-rule="evenodd" d="{d}"/></svg>')

from PIL import Image, ImageDraw, ImageFont, ImageFilter
from pathlib import Path
import math

S=4
INK='#10182a'; EDGE='#809cbd'

def cursor(kind, size=64, phase=0):
    im=Image.new('RGBA',(64*S,64*S))
    d=ImageDraw.Draw(im)
    def line(points,fill=INK,width=3):
        pts=[(round(x*S),round(y*S)) for x,y in points]
        for color,w in [(EDGE,width+4),('white',width+2),(fill,width)]:
            d.line(pts,fill=color,width=round(w*S),joint='curve')
            rr=w*S/2
            for x,y in [pts[0],pts[-1]]:d.ellipse((x-rr,y-rr,x+rr,y+rr),fill=color)
    def poly(points):
        smooth=[]
        for i,p in enumerate(points):
            prev=points[i-1]; nxt=points[(i+1)%len(points)]
            a=math.dist(p,prev); b=math.dist(p,nxt)
            radius=min(2.8,a*.28,b*.28)
            start=(p[0]+(prev[0]-p[0])*radius/a,p[1]+(prev[1]-p[1])*radius/a)
            end=(p[0]+(nxt[0]-p[0])*radius/b,p[1]+(nxt[1]-p[1])*radius/b)
            for j in range(9):
                t=j/8
                smooth.append(((1-t)**2*start[0]+2*(1-t)*t*p[0]+t*t*end[0],(1-t)**2*start[1]+2*(1-t)*t*p[1]+t*t*end[1]))
        pts=[(round(x*S),round(y*S)) for x,y in smooth]
        for color,w in [(EDGE,5),('white',3)]:
            d.line(pts+[pts[0]],fill=color,width=w*S,joint='curve')
            for x,y in pts:
                rr=w*S/2
                d.ellipse((x-rr,y-rr,x+rr,y+rr),fill=color)
        d.polygon(pts,fill=INK)
    def arrow():
        # Compact concave browser pointer, with no rectangular stem.
        poly([(12,10),(46,24),(31,30),(25,45)])
    def ring(cx=32,cy=32,r=13):
        box=((cx-r)*S,(cy-r)*S,(cx+r)*S,(cy+r)*S)
        d.ellipse(box,outline=EDGE,width=7*S)
        box=((cx-r+1)*S,(cy-r+1)*S,(cx+r-1)*S,(cy+r-1)*S)
        d.ellipse(box,outline='white',width=5*S)
        box=((cx-r+2)*S,(cy-r+2)*S,(cx+r-2)*S,(cy+r-2)*S)
        d.ellipse(box,outline='#afc1d7',width=3*S)
        d.arc(box,30+phase,270+phase,fill=INK,width=3*S)
    if kind in ['Normal','Help','Working']:
        arrow()
        if kind=='Help':
            f=help_font(25*S)
            d.text((42*S,30*S),'?',font=f,fill=INK,stroke_width=2*S,stroke_fill='white')
        if kind=='Working':ring(45,45,10)
    elif kind=='Busy':ring()
    elif kind=='Precision':
        line([(32,12),(32,52)],width=2);line([(12,32),(52,32)],width=2)
    elif kind=='Text':
        line([(32,13),(32,51)],width=2)
        line([(24,13),(40,13)],width=2);line([(24,51),(40,51)],width=2)
    elif kind=='Handwriting':poly([(17,44),(21,32),(42,11),(51,20),(29,41)])
    elif kind=='Unavailable':
        ring();line([(23,23),(41,41)],width=3)
    elif kind in ['Vertical','Horizontal','Diagonal 1','Diagonal 2']:
        a={'Vertical':math.pi/2,'Horizontal':0,'Diagonal 1':math.pi/4,'Diagonal 2':-math.pi/4}[kind]
        pts=[(-24,0),(-14,-9),(-14,-3),(14,-3),(14,-9),(24,0),(14,9),(14,3),(-14,3),(-14,9)]
        poly([(32+x*math.cos(a)-y*math.sin(a),32+x*math.sin(a)+y*math.cos(a)) for x,y in pts])
    elif kind=='Move':
        poly([(32,8),(40,18),(35,18),(35,29),(46,29),(46,24),(56,32),(46,40),(46,35),(35,35),(35,46),(40,46),(32,56),(24,46),(29,46),(29,35),(18,35),(18,40),(8,32),(18,24),(18,29),(29,29),(29,18),(24,18)])
    elif kind=='Alternate':poly([(32,10),(47,29),(36,29),(36,51),(28,51),(28,29),(17,29)])
    elif kind=='Link':
        poly([(22,35),(22,13),(24,10),(28,10),(30,13),(30,29),(33,27),(37,28),(39,30),(43,30),(46,33),(50,34),(51,38),(49,48),(43,54),(29,54),(24,49),(13,35),(13,31),(17,30)])
    # Use a radial light field, independent of the square cursor canvas.
    alpha=im.getchannel('A')
    left,top,right,bottom=alpha.getbbox()
    cx=(left+right-1)/2; cy=(top+bottom-1)/2
    radius=min(cx,cy,im.width-1-cx,im.height-1-cy)-S
    broad=Image.new('L',im.size,0)
    near=alpha.filter(ImageFilter.GaussianBlur(3.5*S)).point(lambda a: round(a*.43))
    outer=broad.load(); inner=near.load()
    for y in range(im.height):
        for x in range(im.width):
            r=math.hypot(x-cx,y-cy)/radius
            outer[x,y]=round(110*max(0.,1-r*r)**2)
            t=max(0.,min(1.,(1-r)/.30))
            inner[x,y]=round(inner[x,y]*t*t*(3-2*t))
    glow=Image.new('RGBA',im.size,(116,65,224,0));glow.putalpha(broad)
    rim=Image.new('RGBA',im.size,(213,201,255,0));rim.putalpha(near)
    im=Image.alpha_composite(Image.alpha_composite(glow,rim),im)
    return im.resize((size,size),Image.Resampling.LANCZOS)


def help_font(size):
    for name in ['C:/Windows/Fonts/segoeuib.ttf', '/System/Library/Fonts/Supplemental/Arial Bold.ttf', 'DejaVuSans-Bold.ttf']:
        try: return ImageFont.truetype(name, size)
        except OSError: pass
    return ImageFont.load_default(size=size)

"""Generate the macOS cape directly from approved rounded vector geometry.
Format references: Mousecape's MCDefs.m and apply.m; no upstream code bundled.
"""
from pathlib import Path
import io, plistlib
from PIL import Image
from artwork import cursor

ROOT=Path(__file__).resolve().parents[1]
MAC=ROOT/'macOS'
IDENTIFIER='com.mnikoie.browser-pointer-rounded'
# Keep macOS-specific Copy, Alias, grab-hand and zoom cursors at their defaults.
IDS={
 'Normal':['com.apple.coregraphics.Arrow','com.apple.coregraphics.ArrowS'],
 'Help':['com.apple.cursor.40'],
 'Working':['com.apple.cursor.14','com.apple.cursor.15','com.apple.cursor.16'],
 'Busy':['com.apple.coregraphics.Wait','com.apple.cursor.4'],
 'Precision':['com.apple.cursor.7','com.apple.cursor.8','com.apple.cursor.41','com.apple.cursor.20'],
 'Text':['com.apple.coregraphics.IBeam','com.apple.coregraphics.IBeamS','com.apple.coregraphics.IBeamXOR'],
 'Unavailable':['com.apple.cursor.3'],
 'Vertical':['com.apple.cursor.23','com.apple.cursor.32','com.apple.cursor.21','com.apple.cursor.22','com.apple.cursor.31','com.apple.cursor.36'],
 'Horizontal':['com.apple.cursor.19','com.apple.cursor.28','com.apple.cursor.17','com.apple.cursor.18','com.apple.cursor.38','com.apple.cursor.27'],
 'Diagonal 1':['com.apple.cursor.34','com.apple.cursor.33','com.apple.cursor.35'],
 'Diagonal 2':['com.apple.cursor.30','com.apple.cursor.29','com.apple.cursor.37'],
 'Move':['com.apple.coregraphics.Move'],
 'Alternate':['com.apple.coregraphics.ArrowCtx','com.apple.cursor.24'],
 'Link':['com.apple.cursor.2','com.apple.cursor.13'],
}
HOT={k:(32,32) for k in IDS}
HOT.update(Normal=(12,10),Help=(12,10),Working=(12,10),Alternate=(32,10),Link=(26,11))

def make_entry(kind):
    count=12 if kind in ['Busy','Working'] else 1
    reps=[]
    for scale in (1,2,3):
        size=32*scale
        strip=Image.new('RGBA',(size,size*count))
        for frame in range(count):
            strip.paste(cursor(kind,size,frame*30),(0,frame*size))
        b=io.BytesIO();strip.save(b,format='PNG');reps.append(b.getvalue())
    hx,hy=HOT[kind]
    return dict(FrameCount=count,FrameDuration=5/60 if count>1 else 1.,
                HotSpotX=hx/2,HotSpotY=hy/2,PointsWide=32.,PointsHigh=32.,Representations=reps)

def build():
    cursors={}
    for kind,identifiers in IDS.items():
        entry=make_entry(kind)
        cursors.update({i:entry for i in identifiers})
    data=dict(Author='mnikoie',CapeName='Browser Pointer Rounded',CapeVersion=1.,
              Identifier=IDENTIFIER,MinimumVersion=2.,Version=2.,HiDPI=True,Animate=True,Cursors=cursors)
    MAC.mkdir(exist_ok=True)
    path=MAC/'Browser-Pointer-Rounded.cape'
    path.write_bytes(plistlib.dumps(data,fmt=plistlib.FMT_XML))
    print(f'Built {path.name}: {len(cursors)} cursor identifiers, 14 corresponding roles, 1x/2x/3x PNGs.')

if __name__=='__main__':build()

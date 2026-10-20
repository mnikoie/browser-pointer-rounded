"""Check actual embedded PNGs, animation frames, hotspots and identifiers."""
from pathlib import Path
import plistlib,io
from PIL import Image

p=Path(__file__).resolve().parents[1]/'macOS/Browser-Pointer-Rounded.cape'
data=plistlib.loads(p.read_bytes())
assert data['Identifier']=='com.mnikoie.browser-pointer-rounded'
assert data['HiDPI'] is True
assert 'com.apple.coregraphics.ArrowS' in data['Cursors']
assert 'com.apple.coregraphics.IBeamS' in data['Cursors']
assert len(data['Cursors'])==39
for key,c in data['Cursors'].items():
    n=c['FrameCount']
    assert n in (1,12),key
    assert 0<=c['HotSpotX']<c['PointsWide'] and 0<=c['HotSpotY']<c['PointsHigh'],key
    for scale,raw in enumerate(c['Representations'],1):
        im=Image.open(io.BytesIO(raw));im.load()
        assert im.format=='PNG' and im.mode=='RGBA',key
        assert im.size==(32*scale,32*scale*n),key
        assert im.getchannel('A').getextrema()==(0,255),key
        if n>1:
            frames=[im.crop((0,i*32*scale,32*scale,(i+1)*32*scale)).tobytes() for i in range(n)]
            assert len(set(frames))==12,key
for name in ['Install.command','Restore.command']:
    raw=(p.parent/name).read_bytes()
    assert raw.startswith(b'#!/bin/bash\n') and b'\r' not in raw,name
print('PASS: all 39 macOS cursor identifiers, PNG scales, 12-frame animations, hotspots and shell line endings.')

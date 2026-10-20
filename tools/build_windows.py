from artwork import cursor
from pathlib import Path
import struct
names=['Normal','Help','Working','Busy','Precision','Text','Handwriting','Unavailable','Vertical','Horizontal','Diagonal 1','Diagonal 2','Move','Alternate','Link']
curdir=Path(__file__).resolve().parents[1]/'Windows/Cursors'
curdir.mkdir(exist_ok=True)
hotspots={n:(32,32) for n in names}
hotspots.update({'Normal':(12,10),'Help':(12,10),'Working':(12,10),'Handwriting':(17,44),'Alternate':(32,10),'Link':(26,11)})
def cur_bytes(kind,sizes=(32,48,64,96),phase=0):
    images=[]; entries=[]; offset=6+16*len(sizes)
    for sz in sizes:
        im=cursor(kind,sz,phase)
        # Uncompressed BGRA DIB and 1-bit AND mask: native Windows CUR format.
        rgba=im.load(); pixels=bytearray();mask=bytearray()
        stride=((sz+31)//32)*4
        for y in range(sz-1,-1,-1):
            row=bytearray(stride)
            for x in range(sz):
                r,g,b,a=rgba[x,y];pixels.extend((b,g,r,a))
                if a==0:row[x//8]|=1<<(7-x%8)
            mask.extend(row)
        data=struct.pack('<IiiHHIIiiII',40,sz,sz*2,1,32,0,len(pixels)+len(mask),0,0,0,0)+pixels+mask
        hx,hy=hotspots[kind]
        entries.append(struct.pack('<BBBBHHII',sz,sz,0,0,round(hx*sz/64),round(hy*sz/64),len(data),offset))
        images.append(data);offset+=len(data)
    return struct.pack('<HHH',0,2,len(sizes))+b''.join(entries)+b''.join(images)

def chunk(tag,data):return tag+struct.pack('<I',len(data))+data+(b'\0' if len(data)%2 else b'')
for n in names:(curdir/(n.replace(' ','-')+'.cur')).write_bytes(cur_bytes(n))
for n in ['Working','Busy']:
    frames=b''.join(chunk(b'icon',cur_bytes(n,(48,),i*30)) for i in range(12))
    header=struct.pack('<9I',36,12,12,0,0,32,1,5,1)
    data=b'ACON'+chunk(b'anih',header)+chunk(b'LIST',b'fram'+frames)
    (curdir/(n+'.ani')).write_bytes(chunk(b'RIFF',data))


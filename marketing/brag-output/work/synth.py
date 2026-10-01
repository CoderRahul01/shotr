import numpy as np, wave
SR=48000; T=21.0; N=int(SR*T); BPM=120; B=60/BPM
t=np.arange(N)/SR
mix=np.zeros((N,2))
def note(f): return 440*2**((f-69)/12)
def env(n,a,d,s,r,hold):
    e=np.concatenate([np.linspace(0,1,int(a*SR)),np.linspace(1,s,int(d*SR)),np.full(max(0,int(hold*SR)),s),np.linspace(s,0,int(r*SR))])
    return e[:n] if len(e)>=n else np.pad(e,(0,n-len(e)))
def add(sig,start,gain=1.0,pan=0.0):
    i=int(start*SR); j=min(N,i+len(sig))
    if j<=i: return
    l=np.cos((pan+1)*np.pi/4); r=np.sin((pan+1)*np.pi/4)
    mix[i:j,0]+=sig[:j-i]*gain*l; mix[i:j,1]+=sig[:j-i]*gain*r
def lp(x,fc):
    a=np.exp(-2*np.pi*fc/SR); y=np.zeros_like(x); z=0.0
    for k in range(len(x)): z=(1-a)*x[k]+a*z; y[k]=z
    return y
def lpf(x,fc):
    a=np.broadcast_to(np.exp(-2*np.pi*np.asarray(fc,dtype=float)/SR),x.shape)
    y=np.empty_like(x); z=0.0
    xs=x.tolist(); al=a.tolist()
    for k in range(len(xs)): z=(1-al[k])*xs[k]+al[k]*z; y[k]=z
    return y
# chords (MIDI): Am F C G, 1 bar (2s) each
prog=[[57,60,64],[53,57,60],[48,55,60],[55,59,62]]
roots=[45,41,48,43]
# PAD: detuned saws, soft, whole track
for bar in range(11):
    ch=prog[bar%4]; st=bar*2.0
    if bar>=9: ch=prog[0]  # resolve to Am in the outro
    dur=2.0 if bar<10 else 1.0
    n=int((dur+0.6)*SR); tt=np.arange(n)/SR
    s=np.zeros(n)
    for m in ch:
        for det in (-0.08,0.08):
            f=note(m+12)*(1+det/100)
            s+=2*((tt*f)%1)-1
    s=lpf(s,1400 if st>=4 else 900)*env(n,0.4,0.3,0.8,0.6,dur-0.7)
    add(s,st,0.05,0)
# KICK from 4.0 (after the flash) to 18.0, on every beat
def kick():
    n=int(0.35*SR); tt=np.arange(n)/SR
    f=50+90*np.exp(-tt*28); ph=2*np.pi*np.cumsum(f)/SR
    return np.sin(ph)*np.exp(-tt*9)
k=kick()
b=4.0
while b<18.0: add(k,b,0.55); b+=B
add(k,18.0,0.6)
# HATS: soft offbeats from 0.5, 16ths feel from 10-18
rng=np.random.default_rng(3)
def hat(dec=40):
    n=int(0.08*SR); x=rng.standard_normal(n); x=x-lpf(x,7000); return x*np.exp(-np.arange(n)/SR*dec)
h=hat()
b=0.5*B
while b<18.0:
    add(h,b,0.05 if b<4 else 0.08, 0.3); b+=B
b=10.0+0.25*B
while b<18.0: add(hat(70),b,0.035,-0.3); b+=B
# BASS: root notes on 8ths from 4.0 to 18.0
for bar in range(2,9):
    r=roots[bar%4]
    for e in range(8):
        st=bar*2+e*B/2; n=int(0.24*SR); tt=np.arange(n)/SR
        s=np.sin(2*np.pi*note(r)*tt)+0.3*np.sin(2*np.pi*note(r+12)*tt)
        add(s*env(n,0.005,0.08,0.6,0.1,0.05),st,0.18)
add(np.sin(2*np.pi*note(45)*np.arange(int(2.5*SR))/SR)*env(int(2.5*SR),0.01,0.4,0.5,1.5,0.6),18.0,0.2)
# PLUCK arp: 10-18s
def pluck(m,d=0.3):
    n=int(d*SR); tt=np.arange(n)/SR; f=note(m)
    s=(np.sin(2*np.pi*f*tt)+0.4*np.sin(4*np.pi*f*tt))*np.exp(-tt*10); return s
for bar in range(5,9):
    ch=prog[bar%4]; pat=[ch[0]+12,ch[1]+12,ch[2]+12,ch[1]+12]
    for e in range(8):
        add(pluck(pat[e%4]),bar*2+e*B/2,0.07,0.25 if e%2 else -0.25)
# RISER into the flash: 3.0-4.1
n=int(1.1*SR); x=rng.standard_normal(n); tt=np.arange(n)/SR
x=lpf(x,600+3000*(tt/1.1)**2)*(tt/1.1)**2
add(x,3.0,0.18)
# SHUTTER at 4.1: click + body
n=int(0.12*SR); x=rng.standard_normal(n); x=(x-lpf(x,2500))*np.exp(-np.arange(n)/SR*60)
add(x,4.08,0.35); add(x*0.6,4.16,0.3)
# UI ticks in key (A): Save 8.7, tap 11.2, swap whoosh 11.6, cards 14.5..
def tick(m=81):
    n=int(0.12*SR); tt=np.arange(n)/SR; return np.sin(2*np.pi*note(m)*tt)*np.exp(-tt*45)
for st,m in ((8.65,81),(11.2,76),(14.5,76),(14.95,79),(15.4,81),(15.85,84)): add(tick(m),st,0.12)
n=int(0.5*SR); x=rng.standard_normal(n); tt=np.arange(n)/SR; x=lpf(x,1800)*np.sin(np.pi*tt/0.5)**2; add(x,11.45,0.08)
# master: gentle fade in/out, soft clip, normalize
fade=np.ones(N); fi=int(0.15*SR); fade[:fi]=np.linspace(0,1,fi); fo=int(1.2*SR); fade[-fo:]=np.linspace(1,0,fo)
mix*=fade[:,None]
mix=np.tanh(mix*1.6)/np.tanh(1.6)
mix/=np.max(np.abs(mix))/0.89
w=wave.open('brag.wav','wb'); w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
w.writeframes((mix*32767).astype('<i2').tobytes()); w.close(); print('wav ok')

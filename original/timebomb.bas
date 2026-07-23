!--------------------------------------------------
!- 12 June 2024 18:50:38
!- Import of : 
!- z:\projects\games\vic20\time bomb\timebomb (1983-07)(compute!)[type-in].prg
!- Unexpanded VIC20 / C16 / Plus4
!--------------------------------------------------
2 poke56,24:poke55,103:gosub29
3 d=37154:p1=d-3:p2=d-2:df=30720:v=36878:s=v-4:m1=30:x=50:goto19
4 fort=240to208step-4:pokes,t:fortt=0to30:pokev,tt/2:next:nextt:pokes,0:me=7932
5 pokeom,32:pokeom+df,10:pokeme,m1:pokeme+df,7:iffthen40
6 k=k+1:on-(k/2<>int(k/2))goto8:ifk>600then37
7 fort=1to2:pokev,t*4:pokes+1,128+k/5:next:pokes+1,0
8 poked,127:p=peek(p2)and128:j0=-(p=0)
9 poked,255:p=peek(p1):j1=-((pand8)=0):j2=-((pand16)=0):j3=-((pand4)=0)
10 ifj0thenc=1:m1=62:goto14
11 ifj1thenc=22:m1=22:goto14
12 ifj2thenc=-1:m1=60:goto14
13 ifj3thenc=-22:m1=30
14 om=me:me=me+c:c=0
15 ifpeek(me)<>32andpeek(me)<>42thenme=om
16 ifpeek(me)=42thenf=1:goto5
17 on-(me>7921)goto18:sys887:me=me+22:goto5
18 on-(me<7944)goto5:sys905:me=me-22:goto5
19 dima(3):a(0)=2:a(1)=-44:a(2)=-2:a(3)=44:wl=209:hl=32:sc=6228:a9=6943
20 sys861:print"{clear} {down}making maze"
21 fort=sc+21to7679step22:poket,32:next:fort=sctosc+21:poket,32:next
22 j=int(rnd(1)*4):x3=j
23 b=a9+a(j)
24 ifpeek(b)=wlthenpokeb,j:pokea9+a(j)/2,hl:a9=b:goto22
25 j=(j+1)*-(j<3):ifj<>x3then23
26 j=peek(a9):pokea9,hl:ifj<4thena9=a9-a(j):goto22
27 tb=sc+int(rnd(0)*20)+220:on-(peek(tb)<>32)goto27:poketb,42
28 sys830:poke828,204:poke829,28:sys923:goto4
29 fori=830to974:reada:pokei,a:next:return
30 data169,238,141,15,144,169,0,133,251,169,150,133,252,160,0,169,10,145,251,200,208
31 data251,230,252,165,252,201,152,208,241,96,169,84,133,251,169,24,133,252,160,0,169
32 data209,145,251,200,208,251,230,252,165,252,201,30,208
33 data241,96,173,60,3,56,233,22,176,3,206,61,3,141,60,3,56,176,19,234,173,60,3,24,105
34 data22,144,3,238,61,3,141,60,3,24,144,1,234,169,0,133,0,169,30,133,1,173,60,3,133
35 data254,173,61,3,133,255,169,0,133,253,160,0,177,254,164,253,145,0,132,253,230,253
36 data234,208,2,230,1,230,254,208,2,230,255,169,32,197,1,208,227,96
37 pokev,15:fort=255to127step-2:pokes,t:pokev-9,255:forg=1to10:next
38 pokev-9,242:forg=1to10:next:pokev-9,240:next:pokev-1,220:forg=15to0step-.05
39 pokev,g:pokev+1,g*10:next:pokev-1,0:pokev+1,238:gosub42:run
40 poketb,32:pokev-1,253:forg=30to0step-.15:pokev,g/2:next:x=x+50:ifx>449thenx=450
41 pokev-1,0:f=0:k=x:r=r+1:gosub42:goto27
42 print"{home}round"r"{right} ":print"{down}press f7 ":a$="":geta$:on-(a$<>"{f7}")goto42:return

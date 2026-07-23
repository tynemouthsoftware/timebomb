2 poke 56, 24 : poke 55, 103 : gosub29
3 d = 37154 : p1 = d-3 : p2 = d-2 : df = 30720 : v = 36878 : s = v-4 : m1 = 30 : x = 50 : goto 19
4 for t = 240 to 208 step -4 : poke s, t : for tt = 0 to 30 : poke v, tt/2 : next : next t : poke s, 0 : me = 7932
5 poke om, 32 : poke om+df, 10 : poke me, m1 : poke me+df, 7 : if f then 40
6 k = k+1 : on -(k/2 <> int(k/2)) goto 8 : if k>600 then 37
7 for t = 1 to 2 : poke v, t*4 : poke s+1, 128+k/5 : next : poke s+1, 0
8 poke d, 127 : p = peek(p2) and 128 : j0 = -(p = 0)
9 poke d, 255 : p = peek(p1) : j1 = -((p and 8) = 0) : j2 = -((p and 16) = 0) : j3 = -((p and 4) = 0)
10 if j0 then c = 1 : m1 = 62 : goto 14
11 if j1 then c = 22 : m1 = 22 : goto 14
12 if j2 then c = -1 : m1 = 60 : goto 14
13 if j3 then c = -22 : m1 = 30
14 om = me : me = me+c : c = 0
15 if peek(me) <> 32 and peek(me) <> 42 then me = om
16 if peek(me) = 42 then f = 1 : goto 5
17 on-(me>7921) goto 18 : sys 887 : me = me+22 : goto 5
18 on-(me<7944) goto 5 : sys 905 : me = me-22 : goto 5
19 dim a(3) : a(0) = 2 : a(1) = -44 : a(2) = -2 : a(3) = 44 : wl = 209 : hl = 32 : sc = 6228 : a9 = 6943
20 sys 861 : print "{clear}{down}making maze"
21 for t = sc+21 to 7679 step 22 : poke t, 32 : next : for t = sc to sc+21 : poke t, 32 : next
22 j = int(rnd(1)*4) : x3 = j
23 b = a9+a(j)
24 if peek(b) = wl then poke b, j : poke a9+a(j)/2, hl : a9 = b : goto 22
25 j = (j+1)*-(j<3) : if j <> x3 then 23
26 j = peek(a9) : poke a9, hl : if j<4 then a9 = a9-a(j) : goto 22
27 tb = sc + int(rnd(0)*20) + 220 : on -(peek(tb) <> 32) goto 27 : poke tb, 42
28 sys 830 : poke 828, 204 : poke 829, 28 : sys 923 : goto 4
29 for i = 830 to 974 : read a : poke i, a : next : return
30 data 169, 238, 141, 15, 144, 169, 0, 133, 251, 169, 150, 133, 252, 160, 0, 169, 10, 145, 251, 200, 208
31 data 251, 230, 252, 165, 252, 201, 152, 208, 241, 96, 169, 84, 133, 251, 169, 24, 133, 252, 160, 0, 169
32 data 209, 145, 251, 200, 208, 251, 230, 252, 165, 252, 201, 30, 208
33 data 241, 96, 173, 60, 3, 56, 233, 22, 176, 3, 206, 61, 3, 141, 60, 3, 56, 176, 19, 234, 173, 60, 3, 24, 105
34 data 22, 144, 3, 238, 61, 3, 141, 60, 3, 24, 144, 1, 234, 169, 0, 133, 0, 169, 30, 133, 1, 173, 60, 3, 133
35 data 254, 173, 61, 3, 133, 255, 169, 0, 133, 253, 160, 0, 177, 254, 164, 253, 145, 0, 132, 253, 230, 253
36 data 234, 208, 2, 230, 1, 230, 254, 208, 2, 230, 255, 169, 32, 197, 1, 208, 227, 96
37 poke v, 15 : for t = 255 to 127 step -2 : poke s, t : poke v-9, 255 : for g = 1 to 10 : next
38 poke v-9, 242 : for g = 1 to 10 : next : poke v-9, 240 : next : poke v-1, 220 : for g = 15 to 0 step -.05
39 poke v, g : poke v+1, g*10 : next : poke v-1, 0 : poke v+1, 238 : gosub 42 : run
40 poke tb, 32 : poke v-1, 253 : for g = 30 to 0 step -.15 : poke v, g/2 : next : x = x+50 : if x>449 then x = 450
41 poke v-1, 0 : f = 0 : k = x : r = r+1 : gosub 42 : goto 27
42 print "{home}round" r "{right} " : print "{down}press f7 " : a$ = "" : get a$ : on -(a$ <> "{f7}") goto 42 : return





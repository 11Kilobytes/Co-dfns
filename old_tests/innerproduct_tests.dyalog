﻿:Namespace innerproduct_tests

X←⍉⍪¯35.5 ¯41.5 ¯29.5 7.5 34.5 ¯11.5 31.5 ¯0.5 32.5 12.5

innerproduct∆01_TEST←'innerproduct∆R1'#.util.MK∆T2 (1)          (1)
innerproduct∆02_TEST←'innerproduct∆R1'#.util.MK∆T2 (1)          (⍬)
innerproduct∆03_TEST←'innerproduct∆R1'#.util.MK∆T2 (⍬)          (⍬)
innerproduct∆04_TEST←'innerproduct∆R1'#.util.MK∆T2 (5)          (1+⍳3)
innerproduct∆05_TEST←'innerproduct∆R1'#.util.MK∆T2 (1+⍳3)       (5)
innerproduct∆06_TEST←'innerproduct∆R1'#.util.MK∆T2 (1+⍳3)       (1+⍳3)
innerproduct∆07_TEST←'innerproduct∆R1'#.util.MK∆T2 (1+⍳7)       (7 2⍴3)
innerproduct∆08_TEST←'innerproduct∆R1'#.util.MK∆T2 (2 7⍴3)      (1+⍳7)
innerproduct∆09_TEST←'innerproduct∆R1'#.util.MK∆T2 (3 2⍴1+⍳4)   (2 5⍴1+⍳4)
innerproduct∆10_TEST←'innerproduct∆R1'#.util.MK∆T2 (3 2⍴1+⍳4)   (2 5⍴÷1+⍳4)
innerproduct∆11_TEST←'innerproduct∆R2'#.util.MK∆T2 (1)          (1)
innerproduct∆12_TEST←'innerproduct∆R2'#.util.MK∆T2 (5)          (1+⍳3)
innerproduct∆13_TEST←'innerproduct∆R2'#.util.MK∆T2 (1+⍳3)       (5)
innerproduct∆14_TEST←'innerproduct∆R2'#.util.MK∆T2 (1+⍳3)       (1+⍳3)
innerproduct∆15_TEST←'innerproduct∆R2'#.util.MK∆T2 (1+⍳7)       (7 2⍴3)
innerproduct∆16_TEST←'innerproduct∆R2'#.util.MK∆T2 (2 7⍴3)      (1+⍳7)
innerproduct∆17_TEST←'innerproduct∆R2'#.util.MK∆T2 (3 2⍴1+⍳4)   (2 5⍴1+⍳4)
innerproduct∆18_TEST←'innerproduct∆R2'#.util.MK∆T2 (3 2⍴1+⍳4)   (2 5⍴÷1+⍳4)
innerproduct∆19_TEST←'innerproduct∆R3'#.util.MK∆T2 (1)          (÷2+⍳5)
innerproduct∆20_TEST←'innerproduct∆R1'#.util.MK∆T2 (0 5⍴5)      (5 5⍴3)
innerproduct∆21_TEST←'innerproduct∆R4'#.util.MK∆T2 (1 3 2⍴1+⍳4) (1 2 5⍴1+⍳4)
innerproduct∆22_TEST←'innerproduct∆R1'#.util.MK∆T2 (⍉2 10⍴⍳10)  (2 10⍴⍳10)
innerproduct∆23_TEST←'innerproduct∆R5'#.util.MK∆T2 (⍉2 10⍴⍳10)  (2 10⍴⍳10)
innerproduct∆24_TEST←'innerproduct∆R6'#.util.MK∆T2 X            X

:EndNamespace

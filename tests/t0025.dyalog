:Namespace t0025

 X←⍳10
 Y←3 5⍴⍳10

 f1←{X[3 1]←¯1 ⋄ X}
 f2←{X[]←0 ⋄ X}
 f3←{X[]←1 2 ⋄ X}
 f4←{X←⍳7 ⋄ X[3 1]←¯1}
 f5←{X←⍳7 ⋄ X[3 1]←¯1 ⋄ X}
 f6←{X←⍳7 ⋄ X[]←0 ⋄ X}
 f7←{X←⍳7 ⋄ X[;3]←5 ⋄ X}
 f8←{Y[;]←3 5⍴⍳15 ⋄ Y}
 f9←{Y[;⍳5]←-3 5⍴⍳15 ⋄ Y}
 f10←{Y[1;]←0 ⋄ Y}
 f11←{Y[;3]←¯20 ⋄ Y}
 f12←{Y[1 2;]←2 5⍴⍳10 ⋄ Y}
 f13←{Y[;1 2]←3 2⍴⍳6 ⋄ Y}
 f14←{Y←3 5⍴⍳10 ⋄ Y[;]←3 5⍴⍳15 ⋄ Y}
 f15←{Y←3 5⍴⍳10 ⋄ Y[;⍳5]←-3 5⍴⍳15 ⋄ Y}
 f16←{Y←3 5⍴⍳10 ⋄ Y[1;]←0 ⋄ Y}
 f17←{Y←3 5⍴⍳10 ⋄ Y[;3]←¯20 ⋄ Y}
 f18←{Y←3 5⍴⍳10 ⋄ Y[1 2;]←2 5⍴⍳10 ⋄ Y}
 f19←{Y←3 5⍴⍳10 ⋄ Y[;1 2]←3 2⍴⍳6 ⋄ Y}
 f20←{Y←3 5⍴⍳10 ⋄ Y[;1 2]-←20 ⋄ Y}

:EndNamespace
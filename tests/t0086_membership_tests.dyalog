:Require file://t0086.dyalog
:Namespace t0086_tests

 tn←'t0086' ⋄ cn←'c0086'
 cd←⎕NS⍬ ⋄ dy←#.⍎tn

 ∆00_TEST←{#.UT.expect←0
  _←#.⎕EX cn ⋄ 0⊣cd∘←#.c0086←tn #.codfns.Fix ⎕SRC dy}

 MK∆T1←{##.UT.expect←(⍎'dy.',⍺⍺)⍵⍵ ⋄ (⍎'cd.',⍺⍺)⍵⍵}
 MK∆T2←{##.UT.expect←⊃(⍎'dy.',⍺⍺)/⍵⍵ ⋄ ⊃(⍎'cd.',⍺⍺)/⍵⍵}
 MK∆T3←{fn tl←⍺⍺ ⋄ nv←⊃(⍎'dy.',fn)/⍵⍵ ⋄ cv←⊃(⍎'cd.',fn)/⍵⍵
  ##.UT.expect←(≢,nv)⍴tl ⋄ ,tl⌈|nv-cv}
 MK∆T4←{fn tl←⍺⍺ ⋄ nv←(⍎'dy.',fn)⍵⍵ ⋄ cv←(⍎'cd.',fn)⍵⍵
  ##.UT.expect←(≢,nv)⍴tl ⋄ ,tl⌈|nv-cv}

F←{⊃((⎕DR ⍵)645)⎕DR ⍵}
B←{⊃((⎕DR ⍵)11)⎕DR ⍵}
I←{⍬≡⍴⍵:⍵ ⋄ ⊃((⎕DR ⍵)323)⎕DR ⍵}
I32←{⍬≡⍴⍵:⍵ ⋄ ⊃((⎕DR ⍵)323)⎕DR ⍵}
I16←{⍬≡⍴⍵:⍵ ⋄ ⊃((⎕DR ⍵)163)⎕DR ⍵}
I8←{⍬≡⍴⍵:⍵ ⋄ ⊃((⎕DR ⍵)83)⎕DR ⍵}

MK∆T←{nv←⊃(⍎'dy.',⍺⍺)/⍵⍵ ⋄ cv←⊃(⍎'cd.',⍺⍺)/⍵⍵
 res←|1-(0.5⌈(⌈/1⊃⍵⍵)÷2)÷(+⌿÷≢)cv ⋄ _←{0.05≤⍵:⎕←⍵ ⋄ ⍬}res
 ##.UT.expect←(⍴nv)(1) ⋄ (⍴cv)(0.05>res)}

∆membership∆001_TEST←'membership' MK∆T2 (⍬)(⍬)
∆membership∆002_TEST←'membership' MK∆T2 (⍬)(1)
∆membership∆003_TEST←'membership' MK∆T2 (⍬)(⍳5)
∆membership∆004_TEST←'membership' MK∆T2 (⍬)(5 5⍴⍳5)
∆membership∆005_TEST←'membership' MK∆T2 (⍬)(5 5 5⍴⍳5)
∆membership∆006_TEST←'membership' MK∆T2 (0)(⍬)
∆membership∆007_TEST←'membership' MK∆T2 (0)(1)
∆membership∆008_TEST←'membership' MK∆T2 (0)(⍳5)
∆membership∆009_TEST←'membership' MK∆T2 (0)(5 5⍴⍳5)
∆membership∆010_TEST←'membership' MK∆T2 (0)(5 5 5⍴⍳5)
∆membership∆011_TEST←'membership' MK∆T2 (3)(⍬)
∆membership∆012_TEST←'membership' MK∆T2 (3)(1)
∆membership∆013_TEST←'membership' MK∆T2 (3)(⍳5)
∆membership∆014_TEST←'membership' MK∆T2 (3)(5 5⍴⍳5)
∆membership∆015_TEST←'membership' MK∆T2 (3)(5 5 5⍴⍳5)
∆membership∆016_TEST←'membership' MK∆T2 (10)(⍬)
∆membership∆017_TEST←'membership' MK∆T2 (10)(1)
∆membership∆018_TEST←'membership' MK∆T2 (10)(⍳5)
∆membership∆019_TEST←'membership' MK∆T2 (10)(5 5⍴⍳5)
∆membership∆020_TEST←'membership' MK∆T2 (10)(5 5 5⍴⍳5)
∆membership∆021_TEST←'membership' MK∆T2 (2 1)(⍬)
∆membership∆022_TEST←'membership' MK∆T2 (2 1)(1)
∆membership∆023_TEST←'membership' MK∆T2 (2 1)(⍳5)
∆membership∆024_TEST←'membership' MK∆T2 (2 1)(5 5⍴⍳5)
∆membership∆025_TEST←'membership' MK∆T2 (2 1)(5 5 5⍴⍳5)
∆membership∆026_TEST←'membership' MK∆T2 (2 2⍴2 1)(⍬)
∆membership∆027_TEST←'membership' MK∆T2 (2 2⍴2 1)(1)
∆membership∆028_TEST←'membership' MK∆T2 (2 2⍴2 1)(⍳5)
∆membership∆029_TEST←'membership' MK∆T2 (2 2⍴2 1)(5 5⍴⍳5)
∆membership∆030_TEST←'membership' MK∆T2 (2 2⍴2 1)(5 5 5⍴⍳5)
∆membership∆031_TEST←'membership' MK∆T2 (2 2⍴2 10)(⍬)
∆membership∆032_TEST←'membership' MK∆T2 (2 2⍴2 10)(1)
∆membership∆033_TEST←'membership' MK∆T2 (2 2⍴2 10)(⍳5)
∆membership∆034_TEST←'membership' MK∆T2 (2 2⍴2 10)(5 5⍴⍳5)
∆membership∆035_TEST←'membership' MK∆T2 (2 2⍴2 10)(5 5 5⍴⍳5)
∆membership∆036_TEST←'membership' MK∆T2 (F ⍬)(⍬)
∆membership∆037_TEST←'membership' MK∆T2 (F ⍬)(1)
∆membership∆038_TEST←'membership' MK∆T2 (F ⍬)(⍳5)
∆membership∆039_TEST←'membership' MK∆T2 (F ⍬)(5 5⍴⍳5)
∆membership∆040_TEST←'membership' MK∆T2 (F ⍬)(5 5 5⍴⍳5)
∆membership∆041_TEST←'membership' MK∆T2 (F 0)(⍬)
∆membership∆042_TEST←'membership' MK∆T2 (F 0)(1)
∆membership∆043_TEST←'membership' MK∆T2 (F 0)(⍳5)
∆membership∆044_TEST←'membership' MK∆T2 (F 0)(5 5⍴⍳5)
∆membership∆045_TEST←'membership' MK∆T2 (F 0)(5 5 5⍴⍳5)
∆membership∆046_TEST←'membership' MK∆T2 (F 3)(⍬)
∆membership∆047_TEST←'membership' MK∆T2 (F 3)(1)
∆membership∆048_TEST←'membership' MK∆T2 (F 3)(⍳5)
∆membership∆049_TEST←'membership' MK∆T2 (F 3)(5 5⍴⍳5)
∆membership∆050_TEST←'membership' MK∆T2 (F 3)(5 5 5⍴⍳5)
∆membership∆051_TEST←'membership' MK∆T2 (F 10)(⍬)
∆membership∆052_TEST←'membership' MK∆T2 (F 10)(1)
∆membership∆053_TEST←'membership' MK∆T2 (F 10)(⍳5)
∆membership∆054_TEST←'membership' MK∆T2 (F 10)(5 5⍴⍳5)
∆membership∆055_TEST←'membership' MK∆T2 (F 10)(5 5 5⍴⍳5)
∆membership∆056_TEST←'membership' MK∆T2 (F 2 1)(⍬)
∆membership∆057_TEST←'membership' MK∆T2 (F 2 1)(1)
∆membership∆058_TEST←'membership' MK∆T2 (F 2 1)(⍳5)
∆membership∆059_TEST←'membership' MK∆T2 (F 2 1)(5 5⍴⍳5)
∆membership∆060_TEST←'membership' MK∆T2 (F 2 1)(5 5 5⍴⍳5)
∆membership∆061_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(⍬)
∆membership∆062_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(1)
∆membership∆063_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(⍳5)
∆membership∆064_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(5 5⍴⍳5)
∆membership∆065_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(5 5 5⍴⍳5)
∆membership∆066_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(⍬)
∆membership∆067_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(1)
∆membership∆068_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(⍳5)
∆membership∆069_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(5 5⍴⍳5)
∆membership∆070_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(5 5 5⍴⍳5)
∆membership∆071_TEST←'membership' MK∆T2 (⍬)(F ⍬)
∆membership∆072_TEST←'membership' MK∆T2 (⍬)(F 1)
∆membership∆073_TEST←'membership' MK∆T2 (⍬)(F ⍳5)
∆membership∆074_TEST←'membership' MK∆T2 (⍬)(F 5 5⍴⍳5)
∆membership∆075_TEST←'membership' MK∆T2 (⍬)(F 5 5 5⍴⍳5)
∆membership∆076_TEST←'membership' MK∆T2 (0)(F ⍬)
∆membership∆077_TEST←'membership' MK∆T2 (0)(F 1)
∆membership∆078_TEST←'membership' MK∆T2 (0)(F ⍳5)
∆membership∆079_TEST←'membership' MK∆T2 (0)(F 5 5⍴⍳5)
∆membership∆080_TEST←'membership' MK∆T2 (0)(F 5 5 5⍴⍳5)
∆membership∆081_TEST←'membership' MK∆T2 (3)(F ⍬)
∆membership∆082_TEST←'membership' MK∆T2 (3)(F 1)
∆membership∆083_TEST←'membership' MK∆T2 (3)(F ⍳5)
∆membership∆084_TEST←'membership' MK∆T2 (3)(F 5 5⍴⍳5)
∆membership∆085_TEST←'membership' MK∆T2 (3)(F 5 5 5⍴⍳5)
∆membership∆086_TEST←'membership' MK∆T2 (10)(F ⍬)
∆membership∆087_TEST←'membership' MK∆T2 (10)(F 1)
∆membership∆088_TEST←'membership' MK∆T2 (10)(F ⍳5)
∆membership∆089_TEST←'membership' MK∆T2 (10)(F 5 5⍴⍳5)
∆membership∆090_TEST←'membership' MK∆T2 (10)(F 5 5 5⍴⍳5)
∆membership∆091_TEST←'membership' MK∆T2 (2 1)(F ⍬)
∆membership∆092_TEST←'membership' MK∆T2 (2 1)(F 1)
∆membership∆093_TEST←'membership' MK∆T2 (2 1)(F ⍳5)
∆membership∆094_TEST←'membership' MK∆T2 (2 1)(F 5 5⍴⍳5)
∆membership∆095_TEST←'membership' MK∆T2 (2 1)(F 5 5 5⍴⍳5)
∆membership∆096_TEST←'membership' MK∆T2 (2 2⍴2 1)(F ⍬)
∆membership∆097_TEST←'membership' MK∆T2 (2 2⍴2 1)(F 1)
∆membership∆098_TEST←'membership' MK∆T2 (2 2⍴2 1)(F ⍳5)
∆membership∆099_TEST←'membership' MK∆T2 (2 2⍴2 1)(F 5 5⍴⍳5)
∆membership∆100_TEST←'membership' MK∆T2 (2 2⍴2 1)(F 5 5 5⍴⍳5)
∆membership∆101_TEST←'membership' MK∆T2 (2 2⍴2 10)(F ⍬)
∆membership∆102_TEST←'membership' MK∆T2 (2 2⍴2 10)(F 1)
∆membership∆103_TEST←'membership' MK∆T2 (2 2⍴2 10)(F ⍳5)
∆membership∆104_TEST←'membership' MK∆T2 (2 2⍴2 10)(F 5 5⍴⍳5)
∆membership∆105_TEST←'membership' MK∆T2 (2 2⍴2 10)(F 5 5 5⍴⍳5)
∆membership∆106_TEST←'membership' MK∆T2 (F ⍬)(F ⍬)
∆membership∆107_TEST←'membership' MK∆T2 (F ⍬)(F 1)
∆membership∆108_TEST←'membership' MK∆T2 (F ⍬)(F ⍳5)
∆membership∆109_TEST←'membership' MK∆T2 (F ⍬)(F 5 5⍴⍳5)
∆membership∆110_TEST←'membership' MK∆T2 (F ⍬)(F 5 5 5⍴⍳5)
∆membership∆111_TEST←'membership' MK∆T2 (F 0)(F ⍬)
∆membership∆112_TEST←'membership' MK∆T2 (F 0)(F 1)
∆membership∆113_TEST←'membership' MK∆T2 (F 0)(F ⍳5)
∆membership∆114_TEST←'membership' MK∆T2 (F 0)(F 5 5⍴⍳5)
∆membership∆115_TEST←'membership' MK∆T2 (F 0)(F 5 5 5⍴⍳5)
∆membership∆116_TEST←'membership' MK∆T2 (F 3)(F ⍬)
∆membership∆117_TEST←'membership' MK∆T2 (F 3)(F 1)
∆membership∆118_TEST←'membership' MK∆T2 (F 3)(F ⍳5)
∆membership∆119_TEST←'membership' MK∆T2 (F 3)(F 5 5⍴⍳5)
∆membership∆120_TEST←'membership' MK∆T2 (F 3)(F 5 5 5⍴⍳5)
∆membership∆121_TEST←'membership' MK∆T2 (F 10)(F ⍬)
∆membership∆122_TEST←'membership' MK∆T2 (F 10)(F 1)
∆membership∆123_TEST←'membership' MK∆T2 (F 10)(F ⍳5)
∆membership∆124_TEST←'membership' MK∆T2 (F 10)(F 5 5⍴⍳5)
∆membership∆125_TEST←'membership' MK∆T2 (F 10)(F 5 5 5⍴⍳5)
∆membership∆126_TEST←'membership' MK∆T2 (F 2 1)(F ⍬)
∆membership∆127_TEST←'membership' MK∆T2 (F 2 1)(F 1)
∆membership∆128_TEST←'membership' MK∆T2 (F 2 1)(F ⍳5)
∆membership∆129_TEST←'membership' MK∆T2 (F 2 1)(F 5 5⍴⍳5)
∆membership∆130_TEST←'membership' MK∆T2 (F 2 1)(F 5 5 5⍴⍳5)
∆membership∆131_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(F ⍬)
∆membership∆132_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(F 1)
∆membership∆133_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(F ⍳5)
∆membership∆134_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(F 5 5⍴⍳5)
∆membership∆135_TEST←'membership' MK∆T2 (F 2 2⍴2 1)(F 5 5 5⍴⍳5)
∆membership∆136_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(F ⍬)
∆membership∆137_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(F 1)
∆membership∆138_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(F ⍳5)
∆membership∆139_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(F 5 5⍴⍳5)
∆membership∆140_TEST←'membership' MK∆T2 (F 2 2⍴2 10)(F 5 5 5⍴⍳5)

∆∆∆_TEST←{#.UT.expect←,¨0 0 ⋄ _←#.⎕EX¨cn tn ⋄ #.⎕NC¨cn tn}

:EndNamespace

﻿:Namespace t0017

circumference∆Run←{○⍵×2}
reduce∆R01←{+/⍵} ⋄ reduce∆R02←{×/⍵} ⋄ reduce∆R03←{{⍺+⍵}/⍵}
reduce∆R04←{≠/⍵} ⋄ reduce∆R05←{{⍺≠⍵}/⍵} ⋄ reduce∆R06←{∧/⍵}
reduce∆R07←{-/⍵} ⋄ reduce∆R08←{÷/⍵} ⋄ reduce∆R09←{|/⍵}
reduce∆R10←{⌊/⍵} ⋄ reduce∆R11←{⌈/⍵} ⋄ reduce∆R12←{*/⍵}
reduce∆R13←{!/⍵} ⋄ reduce∆R14←{∧/⍵} ⋄ reduce∆R15←{∨/⍵}
reduce∆R16←{</⍵} ⋄ reduce∆R17←{≤/⍵} ⋄ reduce∆R18←{=/⍵}
reduce∆R19←{≥/⍵} ⋄ reduce∆R20←{>/⍵} ⋄ reduce∆R21←{≠/⍵}
reduce∆R22←{⊤/⍵} ⋄ reduce∆R23←{∪/⍵} ⋄ reduce∆R24←{//⍵}
reduce∆R25←{⌿/⍵} ⋄ reduce∆R26←{\/⍵} ⋄ reduce∆R27←{⍀/⍵}
reduce∆R28←{⌽/⍵} ⋄ reduce∆R29←{⊖/⍵} ⋄ reduce∆R30←{X←0⌷⍵ ⋄ {⍺≠⍵}/X}
scan∆R1←{+\⍵} ⋄ scan∆R2←{×\⍵} ⋄ scan∆R3←{{⍺+⍵}\⍵} ⋄ scan∆R4←{<\⍵}
scanfirst∆R1←{+⍀⍵} ⋄ scanfirst∆R2←{×⍀⍵}
scanfirst∆R3←{{⍺+⍵}⍀⍵} ⋄ scanfirst∆R4←{<⍀⍵}
scanoverrun∆Run←{(⍺=⍺)/⍵}
uniqop∆Run←{(∪⍵)∘.=⍵}

:EndNamespace

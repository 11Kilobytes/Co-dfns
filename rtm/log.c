﻿NM(log,"log",1,1,MT ,MFD,DFD,MT ,DAD)
DEFN(log)
MF(log_f){z.s=r.s;z.v=log(r.v.as(f64));}
SF(log,z.v=log(rv.as(f64))/log(lv.as(f64)))


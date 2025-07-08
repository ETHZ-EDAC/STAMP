      SUBROUTINE UTRS(SHIFT,TEMP,DTEMP,TIME,DTIME,PREDEF,DPRED,STATEV,
     1 CMNAME,COORDS)
C
C     CUSTOM SUBROUTINE FOR WLF AND ARRHENIUS SHIFT IMPLEMENTATION
C
      INCLUDE 'ABA_PARAM.INC'
C
      DIMENSION TIME(2)
      DIMENSION PREDEF(1),DPRED(1),STATEV(1),COORDS(1),SHIFT(2)
      CHARACTER*80 CMNAME
      DATA T0,TREL0,TREL1/1.D0,1.D0,1.D0/
C
C      WRITE( *, * ) 'Subroutine Selected'
      SELECT CASE (CMNAME)
      CASE ("VEROWHITEULTRA")
            C1=17.44
            C2=51.60
            C3=18617.00
            Tg=80.00
      CASE ("AGILUS")
            C1=17.44
            C2=51.60
            C3=25011.00
            Tg=20.00
      CASE ("EXP_AGILUS_VEROWHITEULTRA_666660PPM")
            C1=17.44
            C2=51.60
            C3=22128.00
            Tg=45.00
      CASE ("EXP_AGILUS_VEROWHITEULTRA_333330PPM")
            C1=17.44
            C2=51.60
            C3=20075.00
            Tg=70.00
      CASE ("EXP_AGILUS_VEROWHITEULTRA_500000PPM")
            C1=17.44
            C2=51.60
            C3=20976.00
            Tg=60.00
      CASE ("EXP_AGILUS_VEROWHITEULTRA_835000PPM")
            C1=17.44
            C2=51.60
            C3=24223.00
            Tg=20.00
      CASE ("EXP_AGILUS_VEROWHITEULTRA_165000PPM")
            C1=17.44
            C2=51.60
            C3=19294.00
            Tg=75.00
      CASE ("MIX_AGILUS_VEROWHITEULTRA_0PPM")
            C1=17.44
            C2=51.60
            C3=18617.00
            Tg=80.00
      CASE ("MIX_AGILUS_VEROWHITEULTRA_30900PPM")
            C1=17.44
            C2=51.60
            C3=18749.03
            Tg=78.84
      CASE ("MIX_AGILUS_VEROWHITEULTRA_61900PPM")
            C1=17.44
            C2=51.60
            C3=18883.78
            Tg=77.66
      CASE ("MIX_AGILUS_VEROWHITEULTRA_92800PPM")
            C1=17.44
            C2=51.60
            C3=19020.50
            Tg=76.45
      CASE ("MIX_AGILUS_VEROWHITEULTRA_123700PPM")
            C1=17.44
            C2=51.60
            C3=19159.77
            Tg=75.22
      CASE ("MIX_AGILUS_VEROWHITEULTRA_154600PPM")
            C1=17.44
            C2=51.60
            C3=19301.76
            Tg=73.97
      CASE ("MIX_AGILUS_VEROWHITEULTRA_185600PPM")
            C1=17.44
            C2=51.60
            C3=19447.11
            Tg=72.68
      CASE ("MIX_AGILUS_VEROWHITEULTRA_216500PPM")
            C1=17.44
            C2=51.60
            C3=19595.10
            Tg=71.37
      CASE ("MIX_AGILUS_VEROWHITEULTRA_247400PPM")
            C1=17.44
            C2=51.60
            C3=19746.40
            Tg=70.03
      CASE ("MIX_AGILUS_VEROWHITEULTRA_278300PPM")
            C1=17.44
            C2=51.60
            C3=19901.28
            Tg=68.65
      CASE ("MIX_AGILUS_VEROWHITEULTRA_309300PPM")
            C1=17.44
            C2=51.60
            C3=20060.55
            Tg=67.23
      CASE ("MIX_AGILUS_VEROWHITEULTRA_340200PPM")
            C1=17.44
            C2=51.60
            C3=20223.50
            Tg=65.78
      CASE ("MIX_AGILUS_VEROWHITEULTRA_371100PPM")
            C1=17.44
            C2=51.60
            C3=20391.03
            Tg=64.28
      CASE ("MIX_AGILUS_VEROWHITEULTRA_402000PPM")
            C1=17.44
            C2=51.60
            C3=20563.59
            Tg=62.73
      CASE ("MIX_AGILUS_VEROWHITEULTRA_433000PPM")
            C1=17.44
            C2=51.60
            C3=20742.29
            Tg=61.12
      CASE ("MIX_AGILUS_VEROWHITEULTRA_463900PPM")
            C1=17.44
            C2=51.60
            C3=20926.60
            Tg=59.46
      CASE ("MIX_AGILUS_VEROWHITEULTRA_494800PPM")
            C1=17.44
            C2=51.60
            C3=21117.84
            Tg=57.73
      CASE ("MIX_AGILUS_VEROWHITEULTRA_525700PPM")
            C1=17.44
            C2=51.60
            C3=21316.95
            Tg=55.92
      CASE ("MIX_AGILUS_VEROWHITEULTRA_556700PPM")
            C1=17.44
            C2=51.60
            C3=21525.75
            Tg=54.02
      CASE ("MIX_AGILUS_VEROWHITEULTRA_587600PPM")
            C1=17.44
            C2=51.60
            C3=21744.41
            Tg=52.02
      CASE ("MIX_AGILUS_VEROWHITEULTRA_618500PPM")
            C1=17.44
            C2=51.60
            C3=21975.50
            Tg=49.90
      CASE ("MIX_AGILUS_VEROWHITEULTRA_649400PPM")
            C1=17.44
            C2=51.60
            C3=22221.68
            Tg=47.62
      CASE ("MIX_AGILUS_VEROWHITEULTRA_680400PPM")
            C1=17.44
            C2=51.60
            C3=22487.59
            Tg=45.15
      CASE ("MIX_AGILUS_VEROWHITEULTRA_711300PPM")
            C1=17.44
            C2=51.60
            C3=22777.23
            Tg=42.44
      CASE ("MIX_AGILUS_VEROWHITEULTRA_742200PPM")
            C1=17.44
            C2=51.60
            C3=23100.83
            Tg=39.39
      CASE ("MIX_AGILUS_VEROWHITEULTRA_773100PPM")
            C1=17.44
            C2=51.60
            C3=23476.21
            Tg=35.80
      CASE ("MIX_AGILUS_VEROWHITEULTRA_804100PPM")
            C1=17.44
            C2=51.60
            C3=23949.00
            Tg=31.20
      CASE ("MIX_AGILUS_VEROWHITEULTRA_835000PPM")
            C1=17.44
            C2=51.60
            C3=24786.34
            Tg=22.62
      END SELECT
C
      TREL0=TEMP-DTEMP+273.15
      TREL1=TEMP+273.15
C
C     WLF:        aT  =  10**(-C1*(TREL-T0)/(C2+(TREL-T0)))
C     ARRHENIUS:  aT  =  10**(C3*(1/TREL-1/T0))
C
      T0=TG+273.15
      IF (T .GE. T0) THEN
C           WLF 
            SHIFT(1)=10**(-C1*(TREL0-T0)/(C2+(TREL0-T0)))
            SHIFT(2)=10**(-C1*(TREL1-T0)/(C2+(TREL1-T0)))
      ELSE
C           ARRHENIUS
            SHIFT(1)=10**(C3*(1/TREL0-1/T0))
            SHIFT(2)=10**(C3*(1/TREL1-1/T0))
      ENDIF
C      WRITE( *, * ) SHIFT(1),SHIFT(2)
      RETURN
      END
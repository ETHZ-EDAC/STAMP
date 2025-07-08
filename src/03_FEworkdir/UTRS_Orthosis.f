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
      CASE ("MIX_AGILUS_VEROWHITEULTRA_3100PPM")
            C1=17.44
            C2=51.60
            C3=18630.15
            Tg=79.88
      CASE ("MIX_AGILUS_VEROWHITEULTRA_31800PPM")
            C1=17.44
            C2=51.60
            C3=18752.91
            Tg=78.81
      CASE ("MIX_AGILUS_VEROWHITEULTRA_60400PPM")
            C1=17.44
            C2=51.60
            C3=18877.20
            Tg=77.71
      CASE ("MIX_AGILUS_VEROWHITEULTRA_89100PPM")
            C1=17.44
            C2=51.60
            C3=19004.00
            Tg=76.60
      CASE ("MIX_AGILUS_VEROWHITEULTRA_117800PPM")
            C1=17.44
            C2=51.60
            C3=19132.98
            Tg=75.46
      CASE ("MIX_AGILUS_VEROWHITEULTRA_146400PPM")
            C1=17.44
            C2=51.60
            C3=19263.81
            Tg=74.31
      CASE ("MIX_AGILUS_VEROWHITEULTRA_175100PPM")
            C1=17.44
            C2=51.60
            C3=19397.54
            Tg=73.12
      CASE ("MIX_AGILUS_VEROWHITEULTRA_203800PPM")
            C1=17.44
            C2=51.60
            C3=19533.89
            Tg=71.91
      CASE ("MIX_AGILUS_VEROWHITEULTRA_232400PPM")
            C1=17.44
            C2=51.60
            C3=19672.53
            Tg=70.69
      CASE ("MIX_AGILUS_VEROWHITEULTRA_261100PPM")
            C1=17.44
            C2=51.60
            C3=19814.61
            Tg=69.42
      CASE ("MIX_AGILUS_VEROWHITEULTRA_326000PPM")
            C1=17.44
            C2=51.60
            C3=20148.07
            Tg=66.45
      CASE ("MIX_AGILUS_VEROWHITEULTRA_390900PPM")
            C1=17.44
            C2=51.60
            C3=20501.00
            Tg=63.29
      CASE ("MIX_AGILUS_VEROWHITEULTRA_455900PPM")
            C1=17.44
            C2=51.60
            C3=20878.25
            Tg=59.89
      CASE ("MIX_AGILUS_VEROWHITEULTRA_520800PPM")
            C1=17.44
            C2=51.60
            C3=21284.80
            Tg=56.21
      CASE ("MIX_AGILUS_VEROWHITEULTRA_585700PPM")
            C1=17.44
            C2=51.60
            C3=21730.62
            Tg=52.14
      CASE ("MIX_AGILUS_VEROWHITEULTRA_650600PPM")
            C1=17.44
            C2=51.60
            C3=22231.59
            Tg=47.53
      CASE ("MIX_AGILUS_VEROWHITEULTRA_715600PPM")
            C1=17.44
            C2=51.60
            C3=22819.95
            Tg=42.04
      CASE ("MIX_AGILUS_VEROWHITEULTRA_780500PPM")
            C1=17.44
            C2=51.60
            C3=23577.50
            Tg=34.82
      CASE ("MIX_AGILUS_VEROWHITEULTRA_845400PPM")
            C1=17.44
            C2=51.60
            C3=25011.00
            Tg=20.00
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
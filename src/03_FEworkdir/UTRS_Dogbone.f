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
      CASE ("MIX_AGILUS_VEROWHITEULTRA_20900PPM")
            C1=17.44
            C2=51.60
            C3=18706.06
            Tg=79.22
      CASE ("MIX_AGILUS_VEROWHITEULTRA_62600PPM")
            C1=17.44
            C2=51.60
            C3=18886.85
            Tg=77.63
      CASE ("MIX_AGILUS_VEROWHITEULTRA_104400PPM")
            C1=17.44
            C2=51.60
            C3=19072.48
            Tg=75.99
      CASE ("MIX_AGILUS_VEROWHITEULTRA_146100PPM")
            C1=17.44
            C2=51.60
            C3=19262.42
            Tg=74.32
      CASE ("MIX_AGILUS_VEROWHITEULTRA_187900PPM")
            C1=17.44
            C2=51.60
            C3=19458.02
            Tg=72.59
      CASE ("MIX_AGILUS_VEROWHITEULTRA_229600PPM")
            C1=17.44
            C2=51.60
            C3=19658.83
            Tg=70.81
      CASE ("MIX_AGILUS_VEROWHITEULTRA_271400PPM")
            C1=17.44
            C2=51.60
            C3=19866.37
            Tg=68.96
      CASE ("MIX_AGILUS_VEROWHITEULTRA_313100PPM")
            C1=17.44
            C2=51.60
            C3=20080.35
            Tg=67.06
      CASE ("MIX_AGILUS_VEROWHITEULTRA_354900PPM")
            C1=17.44
            C2=51.60
            C3=20302.60
            Tg=65.07
      CASE ("MIX_AGILUS_VEROWHITEULTRA_396600PPM")
            C1=17.44
            C2=51.60
            C3=20533.05
            Tg=63.00
      CASE ("MIX_AGILUS_VEROWHITEULTRA_438400PPM")
            C1=17.44
            C2=51.60
            C3=20774.04
            Tg=60.83
      CASE ("MIX_AGILUS_VEROWHITEULTRA_480100PPM")
            C1=17.44
            C2=51.60
            C3=21025.94
            Tg=58.56
      CASE ("MIX_AGILUS_VEROWHITEULTRA_521900PPM")
            C1=17.44
            C2=51.60
            C3=21292.00
            Tg=56.15
      CASE ("MIX_AGILUS_VEROWHITEULTRA_563600PPM")
            C1=17.44
            C2=51.60
            C3=21573.61
            Tg=53.58
      CASE ("MIX_AGILUS_VEROWHITEULTRA_605400PPM")
            C1=17.44
            C2=51.60
            C3=21875.86
            Tg=50.81
      CASE ("MIX_AGILUS_VEROWHITEULTRA_647100PPM")
            C1=17.44
            C2=51.60
            C3=22202.76
            Tg=47.80
      CASE ("MIX_AGILUS_VEROWHITEULTRA_688900PPM")
            C1=17.44
            C2=51.60
            C3=22564.51
            Tg=44.43
      CASE ("MIX_AGILUS_VEROWHITEULTRA_730600PPM")
            C1=17.44
            C2=51.60
            C3=22974.51
            Tg=40.58
      CASE ("MIX_AGILUS_VEROWHITEULTRA_772400PPM")
            C1=17.44
            C2=51.60
            C3=23466.91
            Tg=35.89
      CASE ("MIX_AGILUS_VEROWHITEULTRA_814100PPM")
            C1=17.44
            C2=51.60
            C3=24142.36
            Tg=29.28
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
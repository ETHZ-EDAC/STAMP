% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function HELPER_GenerateSubroutine(FEinfo)

path = FEinfo.WorkDir;
file = strcat('UTRS_',FEinfo.InpFile,'.f');
fileID = fopen(fullfile(path,file),'w'); 

 matnames = fieldnames(FEinfo.Materials);
%%
fprintf(fileID, '      SUBROUTINE UTRS(SHIFT,TEMP,DTEMP,TIME,DTIME,PREDEF,DPRED,STATEV,\n');
fprintf(fileID, '     1 CMNAME,COORDS)\n');
fprintf(fileID, 'C\n');
fprintf(fileID, 'C     CUSTOM SUBROUTINE FOR WLF AND ARRHENIUS SHIFT IMPLEMENTATION\n');
fprintf(fileID, 'C\n');
fprintf(fileID, '      INCLUDE ''ABA_PARAM.INC''\n');
fprintf(fileID, 'C\n');
fprintf(fileID, '      DIMENSION TIME(2)\n');
fprintf(fileID, '      DIMENSION PREDEF(1),DPRED(1),STATEV(1),COORDS(1),SHIFT(2)\n');
fprintf(fileID, '      CHARACTER*80 CMNAME\n');
fprintf(fileID, '      DATA T0,TREL0,TREL1/1.D0,1.D0,1.D0/\n');
fprintf(fileID, 'C\n');
fprintf(fileID, 'C      WRITE( *, * ) ''Subroutine Selected''\n');
fprintf(fileID, '      SELECT CASE (CMNAME)\n');
for i = 1:size(matnames,1)
fprintf(fileID, '      CASE ("%s")\n',upper(FEinfo.Materials.(matnames{i}).Name));
fprintf(fileID, '            C1=%.2f\n',FEinfo.Materials.(matnames{i}).C1);
fprintf(fileID, '            C2=%.2f\n',FEinfo.Materials.(matnames{i}).C2);
fprintf(fileID, '            C3=%.2f\n',FEinfo.Materials.(matnames{i}).C3);
fprintf(fileID, '            Tg=%.2f\n',FEinfo.Materials.(matnames{i}).Tg);
end
fprintf(fileID, '      END SELECT\n');
fprintf(fileID, 'C\n');
fprintf(fileID, '      TREL0=TEMP-DTEMP+273.15\n');
fprintf(fileID, '      TREL1=TEMP+273.15\n');
fprintf(fileID, 'C\n');
fprintf(fileID, 'C     WLF:        aT  =  10**(-C1*(TREL-T0)/(C2+(TREL-T0)))\n');
fprintf(fileID, 'C     ARRHENIUS:  aT  =  10**(C3*(1/TREL-1/T0))\n');
fprintf(fileID, 'C\n');
fprintf(fileID, '      T0=TG+273.15\n');
fprintf(fileID, '      IF (T .GE. T0) THEN\n');
fprintf(fileID, 'C           WLF \n');
fprintf(fileID, '            SHIFT(1)=10**(-C1*(TREL0-T0)/(C2+(TREL0-T0)))\n');
fprintf(fileID, '            SHIFT(2)=10**(-C1*(TREL1-T0)/(C2+(TREL1-T0)))\n');
fprintf(fileID, '      ELSE\n');
fprintf(fileID, 'C           ARRHENIUS\n');
fprintf(fileID, '            SHIFT(1)=10**(C3*(1/TREL0-1/T0))\n');
fprintf(fileID, '            SHIFT(2)=10**(C3*(1/TREL1-1/T0))\n');
fprintf(fileID, '      ENDIF\n');
fprintf(fileID, 'C      WRITE( *, * ) SHIFT(1),SHIFT(2)\n');
fprintf(fileID, '      RETURN\n');
fprintf(fileID, '      END');

fclose(fileID);
end


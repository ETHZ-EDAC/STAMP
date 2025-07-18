% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function [FEinfo] = HELPER_GenerateAbaqusInputFile(FEinfo)
%% Import the required Include file with the Mesh and Relevant Sets
[FEinfo] = HELPER_GenerateAbaqusIncludeFile(FEinfo);

%% Output
path = FEinfo.WorkDir;
file = strcat(FEinfo.InpFile,'.inp');
fileID = fopen(fullfile(path,file),'w'); 

fprintf(fileID, '*HEADING\n'); 
fprintf(fileID, 'Voxel FE Sim\n');
fprintf(fileID,'**\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**\n');
fprintf(fileID,'** Joël Chapuis & Marc Wirth, %s \n',datetime("today"));
fprintf(fileID,'** Include File: %s.inc\n',FEinfo.InpFile);
fprintf(fileID,'** Description: Voxelized Matter FE Sim for Stratasys Materials\n');
fprintf(fileID,'**\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**\n');
fprintf(fileID,'*Include, Input=%s.inc\n',FEinfo.InpFile);
fprintf(fileID,'**\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**                                                                       **\n');
fprintf(fileID,'**   Element Sections                                                    **\n');
fprintf(fileID,'**                                                                       **\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**\n');

%Generate all Sections
switch FEinfo.ElementType
    case 'solid'
        for i = 1:size(FEinfo.SetsMaterial,1)
            fprintf(fileID,'** Section: SO_%s\n',FEinfo.SetsMaterial{i,2});
            fprintf(fileID,'*SOLID SECTION, ELSET=e_%s, controls=EC-1, MATERIAL = %s\n',FEinfo.SetsMaterial{i,2},FEinfo.SetsMaterial{i,2});
            fprintf(fileID,',\n');
        end
    case 'shell'
        for i = 1:size(FEinfo.SetsMaterial,1)
            fprintf(fileID,'** Section: SO_%s\n',FEinfo.SetsMaterial{i,2});
            fprintf(fileID,'*SHELL SECTION, ELSET=e_%s, controls=EC-1, MATERIAL = %s\n',FEinfo.SetsMaterial{i,2},FEinfo.SetsMaterial{i,2});
            fprintf(fileID,'%.1f,\n',FEinfo.ElementSettings.ShellThickness);         
            fprintf(fileID,',\n');
        end
end

fprintf(fileID,'**\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**                                                                       **\n');
fprintf(fileID,'**   Element Controls                                                    **\n');
fprintf(fileID,'**                                                                       **\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**\n');

fprintf(fileID,'*Section Controls, name=EC-1, hourglass=ENHANCED\n');
fprintf(fileID,'1., 1., 1.\n');

fprintf(fileID,'**\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**                                                                       **\n');
fprintf(fileID,'**   Materials                                                           **\n');
fprintf(fileID,'**                                                                       **\n');
fprintf(fileID,'***************************************************************************\n');
fprintf(fileID,'**\n');

matnames = fieldnames(FEinfo.Materials);
for i = 1:size(matnames,1)
    %Define Material Name
    fprintf(fileID,'*Material, name=%s\n',FEinfo.Materials.(matnames{i}).Name);

    %Define Material Density
    fprintf(fileID,'*Density\n');
    fprintf(fileID,' %e\n',FEinfo.Materials.(matnames{i}).Density);
    
    %Set Depvar to zero as no cross increment storage is needed
    fprintf(fileID,'*Depvar\n');
    fprintf(fileID,'  1,\n');

    %Define Material Thermal Expansion
    fprintf(fileID,'*Expansion\n');
    for j = 1:size(FEinfo.Materials.(matnames{i}).Expansion,1)
        fprintf(fileID,' %e, %e\n',FEinfo.Materials.(matnames{i}).Expansion(j,1),FEinfo.Materials.(matnames{i}).Expansion(j,2));
    end

    if FEinfo.MaterialSettings.HyperelasticBool == 1
        %Define Material Hyperelastic Behavior
        fprintf(fileID,'*Hyperelastic, mooney-rivlin, test data input, moduli=LONG TERM, poisson=%0.3d\n',FEinfo.Materials.(matnames{i}).Poisson);
        fprintf(fileID,'*Uniaxial Test Data\n');
        for j = 1:size(FEinfo.Materials.(matnames{i}).Hyperelastic,1)
            fprintf(fileID,' %e, %e\n',FEinfo.Materials.(matnames{i}).Hyperelastic(j,1),FEinfo.Materials.(matnames{i}).Hyperelastic(j,2));
        end
    else
        %Define Material Elastic Behavior
        fprintf(fileID,'*Elastic, moduli=LONG TERM\n');
        fprintf(fileID,'%e, %e\n',FEinfo.Materials.(matnames{i}).LongtermModulus,FEinfo.Materials.(matnames{i}).Poisson);
    end

    %Define Material Viscoelastic Behavior
    fprintf(fileID,'*Viscoelastic, time=PRONY\n');
    for j = 1:size(FEinfo.Materials.(matnames{i}).Viscoelastic,1)
        fprintf(fileID,' %e, %e, %e\n',FEinfo.Materials.(matnames{i}).Viscoelastic(j,1),FEinfo.Materials.(matnames{i}).Viscoelastic(j,2),FEinfo.Materials.(matnames{i}).Viscoelastic(j,3));
    end

    %Define Material Temperature Behavior (Custom Subroutine)
    fprintf(fileID,'*Trs, definition=USER\n');
end
fprintf(fileID,'**\n');
fprintf(fileID,'***************************************************************************\n');

fclose(fileID);

end
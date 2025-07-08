function [FEinfo] = HELPER_GenerateAbaqusIncludeFile(FEinfo)
%% Output
% [~,path] = uiputfile('*.inc','Save Parameter File','VoxelFE.inc');
path = FEinfo.WorkDir;
file = strcat(FEinfo.InpFile,'.inc');
fileID = fopen(fullfile(path,file),'w');  

%Export nodes
fprintf(fileID, '*NODE, NSET=n_All\n');
    for i = 1:size(FEinfo.p,1)
        id = join(repmat({' '},1,10-numel(num2str(i))),'');
        id = append(id{1},num2str(i));
        fprintf(fileID, '%s,  %1.8f,  %1.8f,  %1.8f\n', id, FEinfo.p(i,1), FEinfo.p(i,2), FEinfo.p(i,3));
    end

% Export elements by set
switch FEinfo.ElementType
    case 'solid'
        for i_setsEle = 1:size(FEinfo.SetsMaterial,1)
            fprintf(fileID, '*ELEMENT,TYPE= C3D4H,ELSET=e_%s\n',FEinfo.SetsMaterial{i_setsEle,2});
            for i = 1:size(FEinfo.SetsMaterial{i_setsEle,3},1)
                id_ele = FEinfo.SetsMaterial{i_setsEle,3}(i,1);
                id = join(repmat({' '},1,10-numel(num2str(id_ele))),'');
                id = append(id{1},num2str(id_ele));
                fprintf(fileID, '%s,  %1.0f,  %1.0f,  %1.0f,  %1.0f\n', id, FEinfo.e_solid(id_ele,1), FEinfo.e_solid(id_ele,2), FEinfo.e_solid(id_ele,3), FEinfo.e_solid(id_ele,4));
            end
        end
    case 'shell'
        for i_setsEle = 1:size(FEinfo.SetsMaterial,1)
            fprintf(fileID, '*ELEMENT,TYPE=S3R,ELSET=e_%s\n',FEinfo.SetsMaterial{i_setsEle,2});
            for i = 1:size(FEinfo.SetsMaterial{i_setsEle,3},1)
                id_ele = FEinfo.SetsMaterial{i_setsEle,3}(i,1);
                id = join(repmat({' '},1,10-numel(num2str(id_ele))),'');
                id = append(id{1},num2str(id_ele));
                fprintf(fileID, '%s,  %1.0f,  %1.0f,  %1.0f\n', id, FEinfo.e_solid(id_ele,1), FEinfo.e_solid(id_ele,2), FEinfo.e_solid(id_ele,3));
            end
        end
end

fclose(fileID);

end
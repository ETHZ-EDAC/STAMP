function POSTPROCESS_VisualizeFE(FEinfo,matinfo,cg_res)
% progress report
fprintf('Plot FE mesh ... ');

% retreive elements
e_solid = FEinfo.e_solid;
p = FEinfo.p;

% map colors to material IDs
matnames = fieldnames(matinfo);
matnames(end-3:end) = [];
mapping = [];
for i_mat = 1:size(matnames,1)
    mapping = [mapping; [matinfo.(matnames{i_mat}).ID, matinfo.(matnames{i_mat}).col]];
end

% associate color mapping to material rows
mapping  = sortrows(mapping,1);
col2mat  = sortrows(matinfo.col2mat,2);
mapping  = sortrows([col2mat(:,1),  mapping(:,2:end)],1);

% create colors
uniqueIDs = cell2mat(FEinfo.SetsMaterial(:,1));
uniqueClr = zeros(size(uniqueIDs,1),3);
for iClr =  1:size(FEinfo.SetsMaterial,1)
    mix = single(FEinfo.mat_FE(find(FEinfo.mixID==uniqueIDs(iClr),1),:));
    uniqueClr(iClr,:) = sum(repmat(mix',1,3)/sum(mix)  .* mapping(:,2:end),1) / 255;
end

% section for plotting to allow cuts
[rowExcl,~] = find(FEinfo.ElementCentroids(:,2)<=0);
rowExcl = [];


if size(FEinfo.e_solid,2) == 10 | size(FEinfo.e_solid,2) == 4
    figure;
    hold on;
    %find elements that are within the cut and also on the boundary
    ElemsToPlot = setdiff(linspace(1,size(FEinfo.e_solid,1),size(FEinfo.e_solid,1))',rowExcl);
    ElemsToPlotMapping = [ElemsToPlot,linspace(1,size(ElemsToPlot,1),size(ElemsToPlot,1))'];
    TR = triangulation(FEinfo.e_solid(ElemsToPlotMapping(:,1),:),FEinfo.p);

    F = freeBoundary(TR);
    BoundaryMapping = zeros(size(F,1),1);
    parfor iRows = 1:size(F,1)
        BoundaryMapping(iRows,1) = intersect(ElemsToPlot,find((sum(FEinfo.e_solid == F(iRows,1),2)+sum(FEinfo.e_solid == F(iRows,2),2)+sum(FEinfo.e_solid == F(iRows,3),2))==3));
    end

    for iSets =  1:size(FEinfo.SetsMaterial,1)
        iB = find(ismember(BoundaryMapping,FEinfo.SetsMaterial{iSets,3})==1);
        trimesh(F(iB,:), ...
        FEinfo.p(:,1),FEinfo.p(:,2),FEinfo.p(:,3), ...
        'FaceColor',uniqueClr(iSets,:),'EdgeColor','black');
    end

elseif size(FEinfo.e_solid,2) == 3
    figure; view(3);
    for iSets =  1:size(FEinfo.SetsMaterial,1)
        hold on;
        trimesh(FEinfo.e_solid(FEinfo.SetsMaterial{iSets,3},:), ...
                FEinfo.p(:,1),FEinfo.p(:,2),FEinfo.p(:,3), ...
                'FaceColor',uniqueClr(iSets,:),'EdgeColor','black');
    end
end

% progress report
axis equal;
fprintf('DONE \n');

end


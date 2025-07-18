% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function POSTPROCESS_visualize(gridinfo,mat,matinfo,stlfile,type)
    % progress report
    fprintf('Visualize structure ... ');
   
    % get matinfo entries out of struct
    mat2col = matinfo.mat2col;

    % cull entries in matinfo
    matinfo = rmfield(matinfo,'col2mat');
    matinfo = rmfield(matinfo,'mat2col');
    matinfo = rmfield(matinfo,'basemat');
    matinfo = rmfield(matinfo,'void');
    matinfo = rmfield(matinfo,'basematRow');

    % names of all material
    matnames = fieldnames(matinfo);
    
    % retrieve plot colors and ID
    colorID = zeros(size(matnames,1),4);
    for imat = 1:size(matnames,1)
        colorID(imat,:) = [matinfo.(matnames{imat}).ID, matinfo.(matnames{imat}).col];
    end
    colorID = sortrows(colorID,1);

    % set up figure
    figure()
    view(3)
    hold on
    grid on
    axis equal

    % active mixtures
    mixes = unique(mat,"rows");
    
    % cull void mixes
    mixes(mixes(:,1)>0,:) = [];

    % plot all mixtures
    xyzPoints = [];
    xyzColor = [];
    for imix = 1:size(mixes,1)
        % IDs of mixture material
        activematID = mat2col(ismember(mat2col(:,2),find(mixes(imix,:)>0)),1);
        % percentage of mixture
        matperc = single(mixes(imix,mixes(imix,:)>0))/10000;
        % colors mix
        color = [0,0,0];
        for iID = 1:size(activematID,1)
            color = color + colorID(colorID(:,1)==activematID(iID),2:4)*matperc(iID);
        end
        % coordinates
        pointID = find(sum(abs(mat - mixes(imix,:)),2)==0);
        xval = gridinfo(1).vals(gridinfo(1).array(pointID));
        yval = gridinfo(2).vals(gridinfo(2).array(pointID));
        zval = gridinfo(3).vals(gridinfo(3).array(pointID));

        xyzPoints = [xyzPoints;...
                     xval,yval,zval];
        xyzColor = [xyzColor;...
                    repmat(color/255,size(xval,1),1)];
    end
    pcshow(xyzPoints,xyzColor,"MarkerSize",150,"BackgroundColor",[0.9 0.9 0.9])

    % progress report
    fprintf('DONE \n');
end
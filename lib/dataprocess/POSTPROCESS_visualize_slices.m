% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function POSTPROCESS_visualize_slices(gridinfo,mat,matinfo,stlfile,type,sliceID,showvoid)
    % progress report
    fprintf('Visualize slices ... ');
   
    % get matinfo entries out of struct
    mat2col = matinfo.mat2col;

    % cull entries in matinfo
    matinfo = rmfield(matinfo,'col2mat');
    matinfo = rmfield(matinfo,'mat2col');
    matinfo = rmfield(matinfo,'basemat');
    matinfo = rmfield(matinfo,'basematRow');
    if showvoid==0
        matinfo = rmfield(matinfo,'void');
    end

    % names of all material
    matnames = fieldnames(matinfo);
    
    % retrieve plot colors and ID
    colorID = zeros(size(matnames,1),4);
    for imat = 1:size(matnames,1)
        colorID(imat,:) = [matinfo.(matnames{imat}).ID, matinfo.(matnames{imat}).col];
    end
    colorID = sortrows(colorID,1);
    
    % determine number of tiles
    ntiles = sliceID(2)-sliceID(1)+1;
    aspect_ratio = 16 / 9;
    c = ceil(sqrt(ntiles * aspect_ratio)); 
    r = ceil(ntiles / c); 

    % array of slice IDs
    sliceIDarray = sliceID(1):sliceID(2);

    % set up figure
    figure()
    
    for t = 1:ntiles
        subplot(r,c,t)
        hold on
        grid on
        axis equal
    
        % active mixtures
        mixes = unique(mat,"rows");
        
        % cull void mixes
        if showvoid==0
            mixes(mixes(:,1)>0,:) = [];
        end
        
        % plot all mixtures
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
    
            % only keep values of current slice
            ztarget = gridinfo(3).vals(sliceIDarray(t));
            IDz = find(zval == ztarget);
            xval = xval(IDz);
            yval = yval(IDz);
    
            % plot
            scatter(xval,yval,'.','MarkerEdgeColor',color/255)
            title(['Slice ',num2str(sliceIDarray(t))])
        end
    end

    % progress report
    fprintf('DONE \n');
end
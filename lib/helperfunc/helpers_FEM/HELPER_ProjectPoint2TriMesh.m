% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function [projectedPoints]=HELPER_ProjectPoint2TriMesh(inputs,points)   
    %% Create Geometry
    % read input
    faces=inputs.faces;
    nodes=inputs.nodes;
    % vertices
    p1 = nodes(faces(:,1),:);
    p2 = nodes(faces(:,2),:);
    p3 = nodes(faces(:,3),:);
    % edges
    edges = [faces(:,1),faces(:,2); faces(:,2),faces(:,3); faces(:,3),faces(:,1)];
    % number of elements
    nf = size(faces,1);
    nn = size(nodes,1);
    ne = size(edges,1);
    % face normals  
    faceNormals = cross(p2-p1,p3-p1,2);
    faceNormals = faceNormals ./ repmat(vecnorm(faceNormals,2,2),1,3);
    % face centroids
    faceCentroids = (p1+p2+p3)/3;

    %% Closest Projection    
    % Initialize 
    projectedPoints = zeros(size(points)); 
    % Loop for each point
    parfor p = 1:size(points, 1)
        % initialize
        point = points(p, :);
        minDistance = Inf;
        bestProjection = point; 
        % vector point to face centroids
        pointToCentroid = repmat(point,nf,1) - faceCentroids;
        % projection on all faces
        projection = repmat(point,nf,1) - repmat(dot(pointToCentroid, faceNormals,2),1,3) .* faceNormals;
        % check if point is in faces
        isIn = isPointInTriangle(projection, p1, p2, p3);
        % read minimum projection if some projections are in faces
        if any(isIn)    
            % relevant face IDs
            IDinside = find(isIn);
            % projection distance
            distance = vecnorm(repmat(point,size(IDinside,2),1) - projection(isIn,:),2,2);
            % find closest projection
            [minDistance,IDmin] = min(distance);
            % projection face ID
            IDface = IDinside(IDmin);
            % put point in template
            projectedPoints(p,:) =  projection(IDface,:);
        end

        % project point on all edges
        projectionOnEdge = projectPointOnEdge(point, edges, nodes);
        % projection distances
        distance = vecnorm(repmat(point,ne,1) - projectionOnEdge,2,2);
        % find minimum projection
        [minDistanceEdge,IDmin] = min(distance);
        % replace make entry if projection is closer
        if minDistanceEdge<minDistance
            projectedPoints(p,:) =  projectionOnEdge(IDmin,:);
        end        
    end
    
    % %% CHECK - Visualize
    % figure();  hold on;  view(3);
    % patch('Faces',faces,'Vertices',nodes,'FaceColor','r','FaceAlpha',.2,'EdgeAlpha',.2);
    % scatter3(nodes(:,1),nodes(:,2),nodes(:,3),'.','black')
    % scatter3(points(:,1),points(:,2),points(:,3),'.','red');
    % scatter3(projectedPoints(:,1),projectedPoints(:,2),projectedPoints(:,3),'.','green');
    % dir  =  projectedPoints - points;
    % quiver3(points(:,1),points(:,2),points(:,3), ...
    %         dir(:,1),dir(:,2),dir(:,3),'off','black','ShowArrowHead','off')
    % axis equal
end


%% Helper Functions

% Check if a point is inside of  a set of triangles
function isIn = isPointInTriangle(pt, p1, p2, p3)
    % Relative vectors
    p0   = p2 - p1;  
    p1p3 = p3 - p1;  
    p1pt = pt - p1;  
    % Dot products
    dot00 = dot(p0, p0, 2);
    dot01 = dot(p0, p1p3, 2);
    dot02 = dot(p0, p1pt, 2);
    dot11 = dot(p1p3, p1p3, 2);
    dot12 = dot(p1p3, p1pt, 2);    
    % Barycentric coordinates
    invDenom = 1 ./ (dot00 .* dot11 - dot01 .* dot01);
    u = (dot11 .* dot02 - dot01 .* dot12) .* invDenom;
    v = (dot00 .* dot12 - dot01 .* dot02) .* invDenom;
    % Check if point is inside the triangles
    isIn = all([u >= 0, v >= 0, u + v <= 1],2);
end


% Project point on set of edges
function proj = projectPointOnEdge(pt, edges, nodes)
    % start end end ID
    IDstart = edges(:,1);
    IDend   = edges(:,2);
    % points at start and end
    pstart = nodes(IDstart,:);
    pend   = nodes(IDend,:);
    % number of  edges
    ne = size(edges,1);
    % Vector from p1 to pt
    p1pt = repmat(pt,ne,1) - pstart;
    % Vector from v1 to v2
    p1p2 = pend - pstart;
    % Projection scalar t
    t = dot(p1pt, p1p2,2) ./ dot(p1p2, p1p2,2);
    % Clamp t to [0, 1] to ensure projection is within the edge segment
    t = max(0, min(1, t));
    % Calculate projection
    proj = pstart + t .* p1p2;
end



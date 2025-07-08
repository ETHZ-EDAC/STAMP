function stlfile_out = PREPROCESS_SampleShellSTL(stlfile,elemsize)
% toggle shell creation vizualization
toggle_viz = 0;

%% Input Processing
faces = stlfile.ConnectivityList; % faces
vertices = stlfile.Points; % vertices

if toggle_viz
    figure(); hold on;
    subplot(1,4,1)
    trimesh(faces,vertices(:,1),vertices(:,2),vertices(:,3),'FaceColor','cyan','EdgeColor','black');
    axis equal
end

%% Create Edges
edges = freeBoundary(stlfile); % all edges
edges_temp = edges; % copy
edges_split = {}; % template
runsplit = 1;
% split into connected loops
while runsplit
    startID = edges_temp(1,1);
    endrow  = find(edges_temp(:,2)==startID,1);
    edges_split{length(edges_split)+1} = edges_temp(1:endrow,:);
    edges_temp(1:endrow,:) = [];
    if length(edges_temp)==0
        runsplit=0;
    end
end

%% Fill Edge Loops
% templates
vertices_add = [];
faces_add    = [];
% fill each edge with triangle to the center
for i = 1:length(edges_split)
    edge = edges_split{i};
    pedge = vertices(unique(edge(:)),:);
    centroid = mean(pedge,1);
    vertices_add = [vertices_add;centroid];
    IDadd = size(vertices,1)+i;
    newfaces = [flip(edge,2), ones(size(edge,1),1)*IDadd];
    faces_add = [faces_add; newfaces];
end
faces_filled = [faces; faces_add];
vertices_filled = [vertices; vertices_add];

if toggle_viz
    subplot(1,4,2)
    trimesh(faces_filled,vertices_filled(:,1),vertices_filled(:,2),vertices_filled(:,3),'FaceColor','cyan','EdgeColor','black');
    axis equal
end

%% Create PDE Geometry
% create model
trfilled = triangulation(faces_filled,vertices_filled);
model = femodel(Geometry=trfilled);
model = generateMesh(model,Hmax=elemsize);
% load points and elements
p = model.Geometry.Mesh.Nodes';
e = model.Geometry.Mesh.Elements';
% reduce elements
ered = e(:,1:4);
pred = p(unique(ered(:)),:);
% make list of faces and centroids
facelist = [ered(:,1),ered(:,3),ered(:,2); ...
            ered(:,1),ered(:,2),ered(:,4); ...
            ered(:,1),ered(:,4),ered(:,3); ...
            ered(:,2),ered(:,3),ered(:,4)];
facecenter = (pred(facelist(:,1),:)+pred(facelist(:,2),:)+pred(facelist(:,3),:))/3;

if toggle_viz
    subplot(1,4,3)
    trimesh(facelist,p(:,1),p(:,2),p(:,3),'FaceColor','cyan','EdgeColor','black');
    axis equal
end

%% Find Hull
% load original data
inputs.faces = faces;
inputs.nodes = vertices;
% project face centers to stl
[projectedPoints]=HELPER_ProjectPoint2TriMesh(inputs,facecenter);
% find faces with short distance
uvw = projectedPoints - facecenter;
IDout = find(vecnorm(uvw,2,2)<elemsize/10);
facesout =  facelist(IDout,:);

%% Reduce
IDpout    = unique(facesout(:)); % output point IDs
pout      = pred(IDpout,:); % output points
IDpnew    = (1:1:size(IDpout,1))'; % new IDs
facesout  = changem(facesout,IDpnew,IDpout); % replace IDs
centroids = (pout(facesout(:,1),:)+pout(facesout(:,2),:)+pout(facesout(:,3),:))/3; % face centroids

%% Output
stlfile_out = struct();
stlfile_out.faces = facesout;
stlfile_out.vertices = pout;
stlfile_out.centroids = centroids;

if toggle_viz
    subplot(1,4,4)
    trimesh(facesout,pout(:,1),pout(:,2),pout(:,3),'FaceColor','cyan','EdgeColor','black');
    axis equal
end

end
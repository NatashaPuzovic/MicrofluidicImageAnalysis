% tracking via point set registration 

% generate unique identifiers for IDs and LIDs
ID_pool =  randperm(10000, 5000);
LID_pool = randperm(1000, 1000);

%%
tic

% initialize first frame (IDs, LIDs, TSD)
% set TSD to 10 so any could be dividing
blob_stack{1}(:, 8) = 10;

% add IDs
blob_stack{1}(:, 9) = ID_pool(1:size(blob_stack{1}, 1));
ID_pool = ID_pool(size(blob_stack{1}, 1) + 1:end);

% add LIDs
blob_stack{1}(:, 10) = LID_pool(1:size(blob_stack{1}, 1));
LID_pool = LID_pool(size(blob_stack{1}, 1) + 1:end);

%% load images and centroids

i=1;

    blob_info_frame1 = blob_stack{i};
    blob_info_frame2 =  blob_stack{i +1};
    
    centroids_frame1 = blob_info_frame1(:, 2:3);
    centroids_frame2 = blob_info_frame2(:, 2:3);
    
    I1 = image_stack(:, :, i);    
    I2 = image_stack(:, :, i + 1);

 %% try to map 
    points1 = detectHarrisFeatures(I1);
    points2 = detectHarrisFeatures(I2);
 
    [features1,valid_points1] = extractFeatures(I1, points1);
    [features2,valid_points2] = extractFeatures(I2, points1);
    
    
    indexPairs = matchFeatures(centroids_frame1, centroids_frame2);
    
    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:);
    
    figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);

    
%%
points1 = detectSURFFeatures(I1);
points2 = detectSURFFeatures(I2);


[f1,vpts1] = extractFeatures(I1, centroids_frame1);
[f2,vpts2] = extractFeatures(I2, centroids_frame2);


indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));

figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);
legend('matched points 1','matched points 2');    
    
%%

tform = pcregrigid(centroids_frame2, centroids_frame1);

%%

 fixed = image_stack(:, :, i);    
 moving  = image_stack(:, :, i + 1);
imshowpair(fixed, moving,'Scaling','joint');
    
    
    [optimizer, metric] = imregconfig('multimodal');
    optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

tform = imregtform(moving, fixed, 'affine', optimizer, metric);
movingRegistered = imwarp(moving,tform,'OutputView',imref2d(size(fixed)));

figure
imshowpair(fixed, movingRegistered,'Scaling','joint')
    
    
    
    
    
    
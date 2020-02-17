% get statistics of blobs
tic

% create a blob analysis object/function
% the BlobAnalysis object computes statistics for connected regions in a
% binary image. Specify which output the object(function) returns - list of possible outputs in the documentation 
getBlobs = vision.BlobAnalysis( ...
                'AreaOutputPort', true, ...
                'CentroidOutputPort', true, ...
                'BoundingBoxOutputPort', true, ...
                'MajorAxisLengthOutputPort', true, ...
                'MinorAxisLengthOutputPort', true, ...
                'LabelMatrixOutputPort', true, ...
                'MinimumBlobArea', 10, ... % this affects the smoothness of the population growth curve (higher = more ragged)
                'MaximumBlobArea', 3000, ...
                'MaximumCount', 20000);                        

% empty cell array for blob information, each cell is the output of blob
% analysis of one frame
blob_stack = cell(1, num_images);

% empty 3D matrix for labels
labels_stack = zeros(img_width, img_height, num_images, 'double');   

for i=1:num_images
    % read one frame from segmented image stack
    bin_frame_smooth = segmented_image_stack(:, :, i);
    
    % apply blob analysis
    [areas, centroids, bboxes, majoraxislength, minoraxislength, labels] = step(getBlobs, bin_frame_smooth);  
    
    % save blob information of this frame
    % ratios = majoraxislength./minoraxislength;
    empty_col = NaN(length(centroids), 1);
    blob_output = [areas centroids bboxes empty_col empty_col empty_col];
    blob_stack(i) = {blob_output};
    
    % save label matrix to label stack
    labels_stack(:, :, i) = labels;
       
end

toc
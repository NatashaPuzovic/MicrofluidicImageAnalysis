% adjust for possible segmentation errors when 2 cells appear as a single blob just because they are close
% FOR ONE FRAME

% if the bounding box of the frame 2 overlaps with >1 centroid from frame
% 1, it means there is a segmentation error and two cells merged together
% so the bounding boxes and centroids from the previous frames should be
% used or cluster with 2 means 

for nbox = 1:size(blob_info_frame2, 1) 
    % centroid should be larger than left boundary of bbox and smaller than
    % left boundary + width
    cells_that_overlap_by_x = find(blob_info_frame1(:, 2) >  blob_info_frame2(nbox, 4) & ...
        blob_info_frame1(:, 2) <  blob_info_frame2(nbox, 4) +  blob_info_frame2(nbox, 6));
    
    % also lower than upper boundary and higher than upper boundary minus
    % height
    cells_that_overlap_by_y = find(blob_info_frame1(:, 3) > blob_info_frame2(nbox, 5) & ...
        blob_info_frame1(:, 3) < blob_info_frame2(nbox, 5) + blob_info_frame2(nbox, 7));
    
    overlapping_cells_indices = intersect(cells_that_overlap_by_x, cells_that_overlap_by_y); % index of cells
    num_overlapping =  length(overlapping_cells_indices); % how many centroids overlap with this bbox?
    
    if num_overlapping > 1
    % remove this blob from frame 2
    blob_info_frame2(nbox, :) = [];
    
    % add blobs from previous frame that overlapped with the removed one
    blob_info_frame2 = [blob_info_frame2; blob_info_frame1(overlapping_cells_indices, :)];
    end
    
end















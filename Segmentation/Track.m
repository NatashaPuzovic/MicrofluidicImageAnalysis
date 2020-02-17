 %% track via centroids
% generate unique identifiers for IDs and LIDs

ID_pool =  randperm(10000, 5000);
LID_pool = randperm(1000, 1000);

%%
% for 30 frames takes ~120 sec
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

for i = 1:num_images - 1
    % get information on blobs from two consecutive frames
    blob_info_frame1 = blob_stack{i};
    blob_info_frame2 =  blob_stack{i +1};
    
    % adjust for detection errors due to segmentation faults (test if this
    % is still needed!)
    Correct_detection_errors;
    blob_stack{i +1} = blob_info_frame2;
   
    % calculate distances between centroids
    Get_distances_between_centroids;
    
    % find minimum distances row-wise and their column location
    [val, loc] = min(dist_matrix');

        % assign centroid from first frame to closest centroid in the second frame 
        for m = 1:nblobs_in_frame1
            closest_centroid_in_second_frame = loc(m);
            blob_info_frame2(closest_centroid_in_second_frame, 8) = blob_info_frame1(m, 8) + 1;
            blob_info_frame2(closest_centroid_in_second_frame, [9 10]) = blob_info_frame1(m, [9 10]);
        end

    % add new cells
    new_cell_indices = find(blob_info_frame2(:, 9) == 0);  
    
    % get distances of cells one from another in frame 2
    points = blob_info_frame2(:, [2 3]);
    point_distances = squareform(pdist(points));
    
    % for each new cell assign a lineage 
        for num_newcell = 1:length(new_cell_indices)
            new_cell_index = new_cell_indices(num_newcell);
            
            % add a new ID to a newly appeared cell and a TSD of 1
            new_id = ID_pool(1);
            blob_info_frame2(new_cell_index, 9) = new_id;
            blob_info_frame2(new_cell_index, 8) = 1;
            ID_pool = ID_pool(2:end); 
            
            %
            % this is where lineage assignment code goes
            
            % assign LID from the nearest neighbour in a 120 pixel radius
            % which has divided in more than 10 frames ago
                cells_within_neighbourhood = point_distances(:, new_cell_index) < 120 ...
                & point_distances(:, new_cell_index)  ~=0;
                cells_within_neighbourhood = find(cells_within_neighbourhood);
           
                neighbouring_new_cells = intersect(new_cell_indices, cells_within_neighbourhood);
                neighbouring_old_cells = setxor(cells_within_neighbourhood, neighbouring_new_cells);

                recently_divided = find(blob_info_frame2(neighbouring_old_cells, 8) < 10);

                best_candidates = neighbouring_old_cells;
                best_candidates(recently_divided) = [];

                % out of these find the closest centroid and assign same
                % lineage and set TSD to 1
                if ~isempty(best_candidates)
                    mother_cell = best_candidates(find(min(point_distances(best_candidates, new_cell_index))));
                    blob_info_frame2(new_cell_index, 10) = blob_info_frame2(mother_cell, 10);
                    blob_info_frame2(mother_cell, 8) = 1;
            
            % otherwise assign a new lineage if the new cell is too far
            % away (just entered the frame)
                else 
                    new_lid = LID_pool(1);
                    blob_info_frame2(new_cell_index, 10) = new_lid;
                    blob_info_frame2(new_cell_index, 8) = 10;
                end
           
            %
            
        end

    
% change blob info stack
    blob_stack{i + 1} = blob_info_frame2;
end


toc
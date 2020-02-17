% calculate distances between centroids in two frames
nblobs_in_frame1 = size(blob_info_frame1, 1);
nblobs_in_frame2 = size(blob_info_frame2, 1);


dist_matrix = pdist2(blob_info_frame1(:, [2 3]), blob_info_frame2(:, [2 3]));

% 
% dist_matrix = nan(nblobs_in_frame1, nblobs_in_frame2);
% for m = 1:nblobs_in_frame1
%    for n = 1:nblobs_in_frame2
%     distance_sq = (blob_info_frame1(m, 2) - blob_info_frame2(n, 2))^2 + ...
%        (blob_info_frame1(m, 3) - blob_info_frame2(n, 3))^2;
%    distance = sqrt(double(distance_sq));
%    dist_matrix(m,n) = distance;
%    end
%end

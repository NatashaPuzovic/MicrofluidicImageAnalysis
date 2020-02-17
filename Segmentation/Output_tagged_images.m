% output image with detections and labels
tic 

% name folder for segmented images
tagged_dir = char(sprintf("%s", path, "Tagged_images"));
mkdir(tagged_dir);


for i = 26:50
    raw_image = mat2gray(image_stack(:, :, i));
    blob_info_frame1 = blob_stack{i};
    
    marked_raw_image = insertMarker(raw_image, blob_info_frame1(:, [2 3]), '*', 'Color', 'red');
    bboxes = blob_info_frame1(:, [4 5 6 7]);
    
    lids = blob_info_frame1(:, 10);
    tags = sprintfc('LID%i', lids);
    
    % ids = blob_info_frame1(:, 9);
    % tags = sprintfc('ID%i', ids);
    % tags = blob_info_frame1(:, 8);
    marked_raw_image = insertObjectAnnotation(marked_raw_image, 'rectangle', bboxes, tags,...
                                                                'Color', 'cyan', 'FontSize', 20);
    imwrite(marked_raw_image, sprintf('%s\\lineage_detections_frame%i.png', tagged_dir, i));  
end

toc
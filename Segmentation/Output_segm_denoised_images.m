 % output segmented and/or denoised images

% name folder for segmented and/or images
% segm_dir = char(sprintf("%s", path, "Segmented_and_filtered_images"));
% denoised_dir = char(sprintf("%s", path, "Denoised_and_filtered_images"));

% delete previous segmentation folder if it exists
%{ 
if exist(segm_dir, 'dir')
       rehash()
       rmdir(segm_dir, 's')
end
mkdir(segm_dir);
%}

%{
% delete previous denoised folder if it exists
if exist(denoised_dir, 'dir')
       rehash()
       rmdir(denoised_dir, 's')
end
mkdir(denoised_dir);
%}

% write segmented and/or denoised individual PNG images
%{
for i = 1:num_images
    
    frame = segmented_image_stack(:, :, i);
    output_image_name = sprintf('%sSegmented_images\\segmented_image_%d.png', path, i);
    imwrite(frame, output_image_name);  
    
    denoised_image = denoised_image_stack(:, :, i);
    output_image_name = sprintf('%sDenoised_images\\denoised_image_%d.png', path, i);
    imwrite(denoised_image, output_image_name);  
   
end
%}

% write segmented and/or denoised TIFF image stack

% make a file by writing the first image, the rest will be appended to the
% first

% out_segm_stack_name = sprintf('%s\\segmented_filtered_stack_%s.tiff', segm_dir, stack_id);
% imwrite(segmented_image_stack(:, :, 1), out_segm_stack_name);
if ~isempty(denoised_image_stack)
    out_denois_stack_name = sprintf('%s\\denoised_filtered_stack_%s.tiff', denoised_dir, image_stack_name);
    imwrite(denoised_image_stack(:, :, 1), out_denois_stack_name);
    % fill out from the second 
    for i = 2:size(denoised_image_stack, 3)
        % imwrite(segmented_image_stack(:, :, i) ,out_segm_stack_name, 'WriteMode', 'append');
        imwrite(denoised_image_stack(:, :, i) ,out_denois_stack_name, 'WriteMode', 'append');
    end

else
    % do nothing
end
    
    
    
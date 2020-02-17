% segment each frame in the image stack

% empty 3D matrix for segmented images
segmented_image_stack = zeros(img_width, img_height, num_images, 'logical');   

% empty 3D matrix for denoised raw frames
denoised_image_stack = zeros(img_width, img_height, num_images);   

% empty 3D matrix for backgrounds
% backgrounds_image_stack = zeros(img_width, img_height, num_images); 

for i = 1:num_images
    % read one image from stack
    raw_frame = RFP_stack(:, :, i);
    
    % remove the differences in background intensity
    se = strel('disk', 40);
    background = imopen(raw_frame, se);
    frame = raw_frame - background;
    
    % binarize the image using Otsu's threshold
    thresh = multithresh(frame);
    bin_frame = imbinarize(frame, 0.9 * thresh);
    
    % save segmented image into a new stack
    segmented_image_stack(:, :, i) = bin_frame;
    denoised_image_stack(:, :, i) = frame;
    % backgrounds_image_stack(:, :, i) = background;
end
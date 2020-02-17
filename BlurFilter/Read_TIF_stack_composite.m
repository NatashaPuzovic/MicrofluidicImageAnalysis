% read tif image stacks (composite) and split them into two stacks based on
% channel

image_stack_location = char(sprintf('%s', path, image_stack_name)); 

img_info = imfinfo(image_stack_location);
num_comp_images = numel(img_info);
img_width = img_info(1).Width;
img_height = img_info(1).Height;

num_images = num_comp_images/2;
  
RFP_stack = zeros(img_width, img_height, num_images, 'double');
BF_stack = zeros(img_width, img_height, num_images, 'double');

for k = 1:num_comp_images
    one_frame = imread(image_stack_location, k, 'Info', img_info);
    one_frame = mat2gray(one_frame);
    
    if mod(k, 2) == 1
        BF_stack(:, :, ceil(k/2)) = one_frame;
    else 
        RFP_stack(:, :, k/2) = one_frame;
    end
end
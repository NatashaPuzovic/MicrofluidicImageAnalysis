% read tif image stacks (grayscale)
tic
image_stack_location = char(sprintf('%s', path, image_stack_name)); 

% get info on images
img_info = imfinfo(image_stack_location);
num_images = length(img_info);
img_width = img_info(1).Width;
img_height = img_info(1).Height;

% empty stack
image_stack = zeros(img_width, img_height, num_images, 'double');      

% fill out stack with each image
TifLink = Tiff(image_stack_location, 'r');
for i = 1:num_images
   TifLink.setDirectory(i);
   one_frame = TifLink.read();
   one_frame = mat2gray(one_frame);
   image_stack(:, :, i) = one_frame; 
end
TifLink.close();

toc
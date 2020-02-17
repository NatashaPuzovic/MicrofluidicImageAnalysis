%% GlobWatch
% this code 
% runtime estimates based on 16GB RAM, Intel Core i7-8550U Processor (1.8
% GHz) on HDD storage

clc;
clear;
cd 'D:\Github\Natasha\ImageAnalysis\';
addpath('D:\Github\Natasha\ImageAnalysis')

%% path, filenames and parameters
% Folder where the raw image stacks are 
path = 'D:\Projekti\PH_Cybergenetics\Image analysis\Exp24_11142018\GrowthRate1320181114_52238 PM_20181115_92021 AM\';

stacks_to_be_analyzed = [ 
"GrowthRate1320181114_52238 PM_f0000_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0000_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0001_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0001_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0002_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0002_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0003_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0003_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0004_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0004_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0005_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0005_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0006_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0006_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0007_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0007_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0008_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0008_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0009_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0009_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0010_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0010_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0011_t000000.tif", ...
"GrowthRate1320181114_52238 PM_f0012_t000001.tif", ...
"GrowthRate1320181114_52238 PM_f0012_t000000.tif" 
];

% input check 
% are all image stack names unique? 
are_all_filenames_unique = length(stacks_to_be_analyzed) == ...
    length(unique(stacks_to_be_analyzed)) % must be 1
% do stacks with the listed file names exist in the folder?
cd(path)
are_all_files_there = [];
for i = 1:length(stacks_to_be_analyzed)
    are_all_files_there(i) = exist(stacks_to_be_analyzed(i)) == 2;
end
are_all_files_there % must be a series of 1

% parameters
min_peak_prominence = 0.02; % for detecting blurred images
max_frames_each_stack = 200; 

%% 
num_stacks = length(stacks_to_be_analyzed);
Movie_Name = strings(num_stacks*max_frames_each_stack, 1);
Frame_in_Movie = nan(num_stacks*max_frames_each_stack, 1);
Blurred = nan(num_stacks*max_frames_each_stack, 1);
table_counter = 1;

% name folder for denoised images
denoised_dir = char(sprintf("%s", path, "Denoised_and_filtered_images"));

% delete previous denoised folder if it exists
if exist(denoised_dir, 'dir')
       rehash()
       rmdir(denoised_dir, 's')
end
mkdir(denoised_dir);


for stack_num = 1:num_stacks %number of stacks
    disp(['On stack number ' num2str(stack_num) ', out of ' num2str(num_stacks)])
    
    image_stack_name = stacks_to_be_analyzed(stack_num);
    
    % read image stacks and split into BF/RFP channels
    Read_TIF_stack_composite;

    % segment images
    Segment;

    % find and remove blurred images
    Detect_blurred_images;
     
    % save segmented and/or denoised images into new folders
    Output_segm_denoised_images;
    
    % fill table
    Movie_Name(table_counter:(table_counter + num_images - 1)) = image_stack_name; % stack
    Frame_in_Movie(table_counter:(table_counter + num_images - 1)) = 1:num_images; % frame
    Blurred(kept_frames + table_counter - 1) = 0; % sharp images
    Blurred(removed_frames + table_counter - 1) = 1; % blurred images
    table_counter = table_counter + num_images;
end

% remove excess NaNs from name, frame, blurtest vectors
Movie_Name(strcmp('', Movie_Name)) = [];
Frame_in_Movie = Frame_in_Movie(~isnan(Frame_in_Movie));
Blurred = Blurred(~isnan(Blurred));

% construct and write table
blur_detection_table = table(Movie_Name, Frame_in_Movie, Blurred);
writetable(blur_detection_table, 'Blurred_Frames_table.txt', 'Delimiter', '\t');

%% save segmented and denoised images into new folders
% (takes ~3sec for segmented only or ~60sec for both)
Output_segm_denoised_images;

%% configure blob analyser and run blob analysis
% (takes ~5sec)
Get_blob_info;

%% count cells in each frame, plot population growth, calculate generation time 
% (takes ~1sec)
Count_cells;

%% calculate generation time

% calculate growth rate
time = num_images * 6; % in minutes
N_begin = counts_per_frame(1);
N_end = counts_per_frame(num_images);
num_generations = log10(N_end/N_begin)/log10(2);

generation_time = time/num_generations; % in minutes

generation_time

%% TRACKING
% track cells frame to frame 
% (takes ~ 3sec)
Track;


%% output tagged images
% (takes 30min to output images)
Output_tagged_images;

%% overlay detected cells on raw image
% (takes ~2sec for 1st frame and ~51sec for 120th frame)
Show_marked_images;






















 
 
 
 
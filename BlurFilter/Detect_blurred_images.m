% find blurred images and delete them from the stack

% calculate variances of segmented RFP images
focus_measures = zeros(1, num_images);
% stat_matr = zeros(num_images, 4);

% Laplacian kernel with diagonal
% Laplacian_kernel = -1 * ones(3);
% Laplacian_kernel(2,2) = 8;

% Laplacian_kernel = [0 1 0; 1 -4 1; 0 1 0];

for i = 1:num_images
    % img = BF_stack(:, :, i);    
    img = segmented_image_stack(:, :, i);
    % v = var(img(:));
    % m = mean(img(:));
    % diffImage = conv2(img, kernel);
    % cpp = mean2(diffImage);
    %glcms = graycomatrix(img);
    %stats = graycoprops(glcms);
    % segm_RFP_variances(i) = m;
    % output = conv2(img, Laplacian_kernel, 'same');
    % segm_RFP_variances(i) = var(output(:));
    % stat_matr(i, :) = [stats.Contrast stats.Correlation stats.Energy stats.Homogeneity];
    focus_measures(i) = fmeasure(img, 'TENG');
end

kept_frames = 1:num_images;
frame_and_focus_list = [kept_frames' focus_measures'];
% plot(focus_measures, 'b', 'LineWidth', 2)

% kept_frames = 1:num_images+1;
% focus_measures = [focus_measures 0.1]
% frame_and_focus_list = [kept_frames' focus_measures'];
%% find blurred images

% remove completely out of focus frames (smudge frames) and all black frms
removed_frames = find(frame_and_focus_list(:, 2) > 0.5 | frame_and_focus_list(:, 2) == 0);
frame_and_focus_list(removed_frames, :) = [];

if ~ isempty(frame_and_focus_list) % if not all frames are completely out of focus
        [peaks, locs] = findpeaks(frame_and_focus_list(:, 2), 'MinPeakProminence', min_peak_prominence);
        
        if ~isempty(peaks)      % if there are any blurred frames
                frame_and_focus_list(locs, :) = [];    
                % remove first found peaks and run peak finder again, and iteratively
                % remove those peaks until no peaks remain, which means all frames are
                % focused
                while ~isempty(peaks)
                    [peaks, locs] = findpeaks(frame_and_focus_list(:, 2), ...
                        'MinPeakProminence', min_peak_prominence);
                    frame_and_focus_list(locs, :) = [];
                end

                kept_frames = frame_and_focus_list(:, 1);
                removed_frames = find(~ismember(1:num_images, frame_and_focus_list(:, 1)));
                
                % plot focus measures of all frames and mark blurred ones to be removed
                f = figure('visible','off');
                plot(focus_measures, 'b', 'LineWidth', 2), hold on
                plot(removed_frames, focus_measures(removed_frames), 'rx')
                title_first_line = sprintf('Focus measure of each frame, %d blurred frames marked', ...
                                                     length(removed_frames));
                title({title_first_line; image_stack_name}, 'FontSize', 12, 'FontWeight', 'bold')
                xlabel('Frame', 'FontSize', 12, 'FontWeight', 'bold')
                ylabel('Focus measure (Tenengrad)', 'FontSize', 12, 'FontWeight', 'bold')
                fig_name = sprintf('%s_frame_foci.png', image_stack_name);
                print(fig_name,'-dpng')
        else                      % if there are no blurred frames
                f = figure('visible','off');
                plot(focus_measures, 'b', 'LineWidth', 2)
                title_first_line = 'Focus measure of each frame, no blurred frames found';
                title({title_first_line; image_stack_name}, 'FontSize', 12, 'FontWeight', 'bold')
                xlabel('Frame', 'FontSize', 12, 'FontWeight', 'bold')
                ylabel('Focus measure (Tenengrad)', 'FontSize', 12, 'FontWeight', 'bold' )
                fig_name = sprintf('%s_frame_foci.png', image_stack_name);
                print(fig_name,'-dpng')
        end
else                % all frames are completely out of focus
    % plot focus measures of all frames and mark blurred ones to be removed
        kept_frames = [];
        f = figure('visible','off');
        plot(focus_measures, 'b', 'LineWidth', 2), hold on
        plot(removed_frames, focus_measures(removed_frames), 'rx')
        title_first_line = sprintf('Focus measure of each frame, %d blurred frames marked', ...
                                length(removed_frames));
        title({title_first_line; image_stack_name}, 'FontSize', 12, 'FontWeight', 'bold')
        xlabel('Frame', 'FontSize', 12, 'FontWeight', 'bold')
        ylabel('Focus measure (Tenengrad)', 'FontSize', 12, 'FontWeight', 'bold')
        fig_name = sprintf('%s_frame_foci.png', image_stack_name);
        print(fig_name,'-dpng')
end
%% check whether the detected blurred frames are really blurred
% implay(segmented_image_stack(:, :, removed_frames));
% implay(segmented_image_stack(:, :, kept_frames));

%% remove blurred images
% removed_image_stack = RFP_stack(:, :, removed_frames);
% RFP_stack = RFP_stack(:, :, kept_frames);
denoised_image_stack = denoised_image_stack(:, :, kept_frames);
% segmented_image_stack = segmented_image_stack(:, :, kept_frames);


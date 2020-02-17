% count blobs in each frame
tic

counts_per_frame = [];
for i=1:num_images
    dimensions = size(blob_stack{i});
    count_in_this_frame = dimensions(1);
    counts_per_frame = [counts_per_frame count_in_this_frame];
end

% plot cell number per frame and per minute and save plots
figure_dir = char(sprintf("%s", path, "Figures"));

mkdir(figure_dir);

% population growth in frames
h = figure;
plot(counts_per_frame);
xlabel('frame');
ylabel('# cells');
saveas(h, sprintf('%s\\population_growth_in_frames.png', figure_dir));

% population growth in minutes
h = figure;
minutes = (1:num_images)*6;
plot(minutes, counts_per_frame)
axis([0 minutes(num_images) 0 counts_per_frame(num_images)+100])
xlabel('minute');
ylabel('# cells');
saveas(h, sprintf('%s\\population_growth_in_minutes.png', figure_dir));


toc
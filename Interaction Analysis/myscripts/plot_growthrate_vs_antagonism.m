function fighandle = plot_growthrate_vs_antagonism(correlation_structure,lineage_labels,fignum)
fighandle = figure(fignum);
clf(fignum)
fighandle.Position = [fighandle.Position(1) fighandle.Position(2) 900 300];

% Unpack structure
% % Per lineage
% correlation_structure.lineage_abundance
% correlation_structure.lineage_antagonism
% correlation_structure.lineage_sensitivity
% correlation_structure.lineage_growth
% correlation_structure.lineage_prevalence
% % Per Sample
% correlation_structure.sample_abundance
% correlation_structure.sample_antagonism
% correlation_structure.sample_sensitivity
% correlation_structure.sample_growth

lineage_x = correlation_structure.lineage_antagonism;
lineage_y = correlation_structure.lineage_growth;
sample_x = correlation_structure.lineage_antagonism;
sample_y = correlation_structure.lineage_growth;
color_x = '#C03026'; %red
color_y = '#58A051'; %green

% color_x = '#C03026'; %red
% color_y = '#808285'; %grey
% color_x = '#58A051'; %green
% color_y = '#3870B8'; %blue
% color_y = '#8C67AC'; %purple


[linear_rho,linear_p] = corr(sample_x,sample_y,'Type','Pearson');
[spearman_rho,spearman_p] = corr(lineage_x,lineage_y,'Type','Spearman');

t = tiledlayout(1, 3);

% Linear correlation, samples
nexttile;
mdl = fitlm(sample_x,sample_y);
scatter(sample_x,sample_y,20,'k','filled','MarkerFaceAlpha',0.5)
hold on
h=plot(mdl);
% Get handles to plot components
dataHandle = findobj(h,'DisplayName','Data');
delete(dataHandle);
fitHandle = findobj(h,'DisplayName','Fit');
cbHandles = findobj(h,'DisplayName','Confidence bounds');
cbHandles = findobj(h,'LineStyle',cbHandles.LineStyle, 'Color', cbHandles.Color);

xlim([0 1])
ylim([0 1])
pbaspect([1 1 1])

xlabel('Antagonism frequency (vs. all lineages)') 
ylabel('Median growth rate [h-1]')
title(['Correlation of antagonism and growth rate' newline 'Linear rho = ' num2str(linear_rho) ' p = ' num2str(linear_p)])
legend('hide')

% Pearson correlation, bars
nexttile([1 2]);
[sorted_x,idxs] = sort(lineage_x);
sorted_y = lineage_y(idxs);
bar(-sorted_x,'FaceColor',color_x);
hold on
bar(sorted_y,'FaceColor',color_y);

xticks(1:numel(sorted_x))
xticklabels(lineage_labels(idxs))
set(gca,'box','off')
pbaspect([2 1 1])

xlabel('Lineage')
title(['Correlation of growth rate and antagonism' newline 'Spearman rho = ' num2str(spearman_rho) ' p = ' num2str(spearman_p)])


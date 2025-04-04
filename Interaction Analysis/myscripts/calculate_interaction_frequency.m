function [freq_structure] = calculate_interaction_frequency(composition_matrix,ZOI_matrix,subject_labels,weight_option)

[M,N] = size(composition_matrix);

% composition: M samples x N lineages
% ZOI_matrix: N lineages x N lineages
% composition matrix and composition must be in the same lineage order
% subject_labels: M samples, assumes each sample is independent 

% NOTE: code does not filter out absent lineages, so 

if size(ZOI_matrix,1)~=N || size(ZOI_matrix,2)~=N
    error('ZOI matrix must be of same size as composition matrix.')
end
if max(ZOI_matrix,[],'all') > 1
    error('ZOI matrix must be logical array of ZOI calls, not areas.')
end

%% Calculate expected frequency based on weighting option

switch weight_option
    case 'weighted'
        % Calculate total abundance by adding subjects
        [Gnum,subjects] = findgroups(subject_labels);
        
        for g=1:numel(subjects)
            subject_composition(g,:) = mean(composition_matrix(Gnum==g,:),1);
        end
        if g>1
            total_abundance=(sum(subject_composition,1)./g)';
        else
            total_abundance = subject_composition;
        end
        total_abundance_scaling_matrix = total_abundance*total_abundance';
        
        
        % Calculate expected frequency of all off-diagonal interactions
        scaled_interaction_matrix = ZOI_matrix.*total_abundance_scaling_matrix.*(1-eye(N));
        expected_freq = nansum(scaled_interaction_matrix,'all')./nansum(total_abundance_scaling_matrix.*(1-eye(N)),'all');

    case 'nonweighted'
        % Calculate total abundance and per sample abundance using equal composition
        
        [Gnum,subjects] = findgroups(subject_labels);
        
        total_abundance = ones(N,1)./N;
        total_abundance_scaling_matrix = total_abundance*total_abundance';
        
        % Overwrite composition_matrix
        composition_matrix = composition_matrix>0;
        composition_matrix = composition_matrix./sum(composition_matrix,2);
        
        
        % Calculate expected frequency of all off-diagonal interactions
        scaled_interaction_matrix = ZOI_matrix.*total_abundance_scaling_matrix.*(1-eye(N));
        expected_freq = nansum(scaled_interaction_matrix,'all')./nansum(total_abundance_scaling_matrix.*(1-eye(N)),'all');
end

%% Calculate per subject interaction, antagonism, and sensitivity frequency
% Loop through all samples

% calculate per sample scaled freq
for m=1:M    
    sample_lineages = composition_matrix(m,:)>0;
    sample_abundance = composition_matrix(m,sample_lineages);
    outgroup_lineages = ~sample_lineages;
    sample_abundance_scaling_matrix = sample_abundance'*sample_abundance;
    S = sum(sample_lineages);

    % calculate potential contribution from missing lineages
    missing_abundance = 1-sum(sample_abundance);


    if S>1
        sample_scaled_interaction_matrix = ZOI_matrix(sample_lineages,sample_lineages).*sample_abundance_scaling_matrix.*(1-eye(S));
        per_sample_interaction_num(m) = nansum(sample_scaled_interaction_matrix>0,'all');
        per_sample_interaction_freq(m) = nansum(sample_scaled_interaction_matrix,'all')./nansum(sample_abundance_scaling_matrix.*(1-eye(S)),'all');
        
    else
        per_sample_interaction_freq(m) = 0;
        per_sample_interaction_num(m) = 0;
    end
    upperbound_scaling_matrix = [sample_abundance missing_abundance]'*[sample_abundance missing_abundance];
    upperbound_interaction_matrix = expected_freq.*(1-eye(S+1,S+1)); %assume expected freq interactions
    upperbound_interaction_matrix(1:S,1:S) = ZOI_matrix(sample_lineages,sample_lineages); %add real data back in
    upperbound_interaction_matrix = upperbound_interaction_matrix.*upperbound_scaling_matrix.*(1-eye(S+1));
    per_sample_interaction_freq_upperbound(m) = nansum(upperbound_interaction_matrix,'all')./nansum(upperbound_scaling_matrix.*(1-eye(S+1)),'all');

end

for g=1:numel(subjects)
    per_subject_interaction_freq(g) = mean(per_sample_interaction_freq(Gnum==g));
end

freq_structure.expected_freq = expected_freq;
freq_structure.per_sample_interaction_freq = per_sample_interaction_freq;
freq_structure.per_subject_interaction_freq = per_subject_interaction_freq;
freq_structure.subjects = subjects;
freq_structure.per_sample_interaction_num = per_sample_interaction_num;
freq_structure.per_sample_interaction_freq_upperbound = per_sample_interaction_freq_upperbound;

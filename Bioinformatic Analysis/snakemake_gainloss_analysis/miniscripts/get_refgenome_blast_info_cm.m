function [ perc_region_covered_reg, reg_positions, ref_contig_names  ] = get_refgenome_blast_info( path_blast_csv, path_reg_fasta, region_name  )


%% Load data

% Read blast csv file
blast_table = readtable(path_blast_csv,'Format','auto',"ReadVariableNames",false,'HeaderLines', 1);

% Fields: query id   subject id  % identity  alignment length    mismatches  gap opens   q. start    q. end  s. start    s. end  evalue  bit score

% Read region fasta file
region_fasta = fastaread( path_reg_fasta );
region_length = numel( region_fasta.Sequence );


%% Case 1: No alignments to reference genome

%filter for region of interest
blast_table.Var1 = categorical(blast_table.Var1);
blast_table=blast_table(blast_table.Var1==region_name,:);

% Return if no hits
if isempty( blast_table )
    reg_positions = [];
    perc_region_covered_reg = 0;
    ref_contig_names = {};
    return
end

%% Case 2: Alignments to reference genome

% Get column of interest
contig_names = [ blast_table.Var2 ];
reg_pos_1 = [ blast_table.Var7 ];
reg_pos_2 = [ blast_table.Var8 ];
c1_pos_1 = [ blast_table.Var9 ];
c1_pos_2 = [ blast_table.Var10 ];
aln_len = [ blast_table.Var4 ];
aln_eval = log10( blast_table.Var11 );
aln_eval( aln_eval == -Inf ) = -100; % -Inf annoying for plots
aln_pid = [ blast_table.Var3 ];


%% Filter parameters

% Filter parameters
min_aln_len = 100; % minimum alignment length
max_eval = 0;%-3; % max evalue
min_pid = 99.99;

% Filter boolean
filter = find( aln_len >= min_aln_len & aln_eval <= max_eval & aln_pid >= min_pid );

if numel(filter)>0
    % Positions on region covered
    reg_positions = [];
    reg_positions = [ reg_pos_1(filter), reg_pos_2(filter) ];
    pos_covered_reg = [];
    for h=1:numel(filter)
        if reg_pos_1(filter(h)) < reg_pos_2(filter(h))
            pos_covered_reg = [ pos_covered_reg, reg_pos_1(filter(h)):1:reg_pos_2(filter(h)) ];
        else
            pos_covered_reg = [ pos_covered_reg, reg_pos_2(filter(h)):1:reg_pos_1(filter(h)) ];
        end
    end
    pos_covered_reg = unique( pos_covered_reg );
    perc_region_covered_reg = 100*numel(pos_covered_reg)/region_length;
    % Positions on reference covered
    refgenome_positions = [ c1_pos_1(filter), c1_pos_2(filter) ];
    ref_contig_names = {};
    pos_covered_ref = [];
    for h=1:numel(filter)
        if c1_pos_1(filter(h)) < c1_pos_2(filter(h))
            pos_covered_ref = [ pos_covered_ref, c1_pos_1(filter(h)):1:c1_pos_2(filter(h)) ];
        else
            pos_covered_ref = [ pos_covered_ref, c1_pos_2(filter(h)):1:c1_pos_1(filter(h)) ];
            
        end
        ref_contig_names = [ref_contig_names,contig_names(filter(h))];
    end
    pos_covered_ref = unique( pos_covered_ref );
    perc_region_covered_ref = 100*numel(pos_covered_ref)/region_length;
else
    refgenome_positions = [];
    ref_contig_names = {};
    reg_positions = [];
    perc_region_covered_reg = 0;
end


end
function matlabbatch = set_t_contrasts(analysis_dir)
% set batch to estimate the following contrasts
% (1) auditory responses for congruent non-McGurk�MacDonald stimuli (i.e. CON), 
% (2) auditory responses for incongruent non-McGurk�MacDonald stimuli (i.e. INC), 
% (3) auditory responses for McGurk�MacDonald stimuli in congruent blocks (AuditoryCon), 
% (4) fused responses for McGurk�MacDonald stimuli in congruent blocks (FusedCon), 
% (5) auditory responses for McGurk� MacDonald stimuli in incongruent blocks (AuditoryInc), 
% (6) fused ressponses for McGurk�MacDonald stimuli in incongruent blocks (FusedInc), 
% (7) congruent blocks (i.e. CONContext)
% (8) incongruent blocks (i.e. INCContext). 
% (9) all events

% cdt_ls = {...
%     'mcgurk_con_aud', ...
%     'mcgurk_con_fus', ...
%     'mcgurk_con_other', ...
%     'mcgurk_inc_aud', ...
%     'mcgurk_inc_fus', ...
%     'mcgurk_inc_other', ...
%     'con_aud_vis', ...
%     'con_other', ...
%     'inc_aud', ...
%     'inc_vis', ...
%     'inc_other', ...
%     'missed'};
 
% blocks_ls = {'con_block', 'inc_block'};

cdt_ls = {...
    'con_aud_vis', ...
    'inc_aud', ...
    'mcgurk_con_aud', ...
    'mcgurk_con_fus', ...
    'mcgurk_inc_aud', ...
    'mcgurk_inc_fus', ...
    'con_block', ...
    'inc_block'};

load(fullfile(analysis_dir, 'SPM.mat'), 'SPM');

matlabbatch{1}.spm.stats.con.spmmat{1} = fullfile(analysis_dir, 'SPM.mat');
matlabbatch{1}.spm.stats.con.delete = 1;

for iCdt = 1:numel(cdt_ls)
    
    % add the suffix '*bf(1)' to look for regressors that are convolved
    % with canonical HRF
    idx = contains(SPM.xX.name', [cdt_ls{iCdt} '*bf(1)']);
    
    % in case we are dealing with a block regressors that was added
    % manually and not convolved automatically by SPM
    if sum(idx)==0
        idx = contains(SPM.xX.name', [cdt_ls{iCdt}]); 
    end
    weight_vec = zeros(size(idx));
    
    if sum(idx)>0
        
        % we normalize by the number of sessions this sondition was present
        % in.
        weight_vec(idx) = 1;
        weight_vec = weight_vec/sum(weight_vec);
        
        matlabbatch{1}.spm.stats.con.consess{iCdt}.tcon.name = cdt_ls{iCdt};
    else
        matlabbatch{1}.spm.stats.con.consess{iCdt}.tcon.name = 'dummy_contrast';;
    end

    matlabbatch{1}.spm.stats.con.consess{iCdt}.tcon.weights = weight_vec;
    matlabbatch{1}.spm.stats.con.consess{iCdt}.tcon.sessrep = 'none';
    
end

%% we do the same but the [all events > baseline] contrast
all_events_ls = {...
    'mcgurk_con_aud', ...
    'mcgurk_con_fus', ...
    'mcgurk_con_other', ...
    'mcgurk_inc_aud', ...
    'mcgurk_inc_fus', ...
    'mcgurk_inc_other', ...
    'con_aud_vis', ...
    'con_other', ...
    'inc_aud', ...
    'inc_vis', ...
    'inc_other', ...
    'missed'};


end


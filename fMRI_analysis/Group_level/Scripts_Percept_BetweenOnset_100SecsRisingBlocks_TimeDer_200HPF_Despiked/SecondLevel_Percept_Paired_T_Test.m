clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
PresentFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];


% ListOfTest = {'Blocks', ...
%               'Non_McGurk_Auditory_Answers', ...
%               'McGurk_Auditory_Answers_VS_Fused', ...
%               'McGurk_Auditory_CON_VS_INC' ...
%               'Interaction'};
% 
% ContrastOfInterest = [ 13 14 ; ...
%                        4 11  ; ...
%                        26 27 ; ...
%                        23 24 ; ...
%                        35 36]; 
% 
% ListOfContrastNames = {' CON Blocks', ' INC Blocks'; ...
%                         ' Congruent trials Auditory answers', ' Incongruent trials Auditory answers'; ...
%                         ' McGurk Auditory answers', ' McGurk Fused answers'; ...
%                         ' McGurk in Congruent', ' McGurk in Incongruent'; ...
%                         '(MG_F - MG_A)_CON', ' (MG_A - MG_F)_INC'};
                    
                    
% ListOfTest = {'INC_VS_CON'; ...
%               'INC-McGurk_VS_CON'};
% 
% ContrastOfInterest = [ 17 18 ; ...
%                        17 20 ]; 
% 
% ListOfContrastNames = {' CON trials', ' INC trials';
%                        ' CON trials', ' INC & McGurk trials'};          

% ListOfTest = {'Inc trial VS Con trials'};
% 
% ContrastOfInterest = [ 16 15 ]; 
% 
% ListOfContrastNames = {' INC trials', ' CON trials'};     

ListOfTest = {'Blocks trial VS Events'};

ContrastOfInterest = [ 17 24 ]; 

ListOfContrastNames = {'Blocks', ' Event'};    
                    
                   
for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h));
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
        
        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);
       
        %load SPM
        
        %{SPM.xCon(ContrastOfInterest(2,:)').name}'
        
        %{SPM.xCon(:).name}'
        
     
        cd(PresentFolder)
                   
end

Y


% ConditionsToCheck = {ones(1,length(SubjectsList))==1 ; ...
%                      any([Y(4,:) ; Y(11,:)]>10) ;...
%                      ~any([sum(Y([2 7],:)) ; sum(Y([3 8],:))]<10) ; ...
%                      ~any([sum(Y([2 3],:)) ; sum(Y([7 8],:))]<10) ; ...
%                      ~any([Y(2,:) ; Y(3,:) ; Y(7,:) ; Y(8,:)]<10) };
                 
                 
% ConditionsToCheck = {ones(1,length(SubjectsList))==1; ...
%                      ones(1,length(SubjectsList))==1};   

ConditionsToCheck = {ones(1,length(SubjectsList))==1}; 

clear B SOT X h Sorted_SOT

%%
cd SecondLevel
mkdir (fullfile(pwd,'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', 'Paired_T-Test_2'));
cd ..

GroupAnalysisFolder = fullfile(pwd, 'SecondLevel', 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', 'Paired_T-Test_2');


for j=1%:length(ListOfTest)

    matlabbatch = {};

    matlabbatch{1,1}.spm.stats.factorial_design.cov = struct('name',{},'levels',{});

    matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.em = cell(1,1);

    matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;

    matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;


    matlabbatch{1,1}.spm.stats.factorial_design.des.pt.gmsca = 0;
    matlabbatch{1,1}.spm.stats.factorial_design.des.pt.ancova = 0;



    cd (GroupAnalysisFolder)

    if exist(ListOfTest{j},'dir')==0
        mkdir (ListOfTest{j});
    end;

    cd (ListOfTest{j})

    matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};
    
    
    SubjectsListTemp = SubjectsList(ConditionsToCheck{j});

    
    for i=1:length(SubjectsListTemp)
        
        A = strcat(PresentFolder, filesep, num2str(SubjectsListTemp(i)), filesep, ...
            'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep, ...
            'con_00');
        
        B = num2str(ContrastOfInterest(j,:)');
        B(B==' ')='0';
        if size(B,2)==1
            B=[['0';'0'] B];
        end

        matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{1,1} = strcat(A, B(1,:) ,'.img,1');
        matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{2,1} = strcat(A, B(2,:) ,'.img,1');
        
        strcat(A, B(1,:) ,'.img,1')
        strcat(A, B(2,:) ,'.img,1')
        
        clear A B
    end
    
    ListOfTest{j}
    SubjectsListTemp
    length(SubjectsListTemp)



    % Estimate model
    matlabbatch{1,end+1}={};
    matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = strcat(GroupAnalysisFolder, filesep, (ListOfTest{j}), filesep, 'SPM.mat');     %set the spm file to be estimated
    matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

    cd(GroupAnalysisFolder)

    save (strcat('Second_Level_Paired_TTest_', (ListOfTest{j}) , '_jobs'));

    spm_jobman('run', matlabbatch)


    %% Load the right SPM.mat
    cd (ListOfTest{j})
    load SPM.mat

    ContrastsValues =   [ 1 -1 zeros(1,length(SubjectsListTemp)); ...
                         -1 1 zeros(1,length(SubjectsListTemp)); ...
                          1 0 ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          0 1 ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                         -1 0 -ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          0 -1 -ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          0.5 0.5 ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          -0.5 -0.5 -ones(1,length(SubjectsListTemp))/length(SubjectsListTemp)];
    
    ContrastsNames ={ strcat(ListOfContrastNames{j,1}, ' > ', ListOfContrastNames{j,2}) ; ...
                      strcat(ListOfContrastNames{j,2}, ' > ', ListOfContrastNames{j,1}) ; ...
                      strcat(ListOfContrastNames{j,1}, ' > ', ' Baseline') ; ...
                      strcat(ListOfContrastNames{j,2}, ' > ', ' Baseline') ; ...
                      strcat(ListOfContrastNames{j,1}, ' < ', ' Baseline') ; ...
                      strcat(ListOfContrastNames{j,2}, ' < ', ' Baseline') ; ...
                      strcat(ListOfContrastNames{j,1}, ' & ', ListOfContrastNames{j,2}, ' > ', ' Baseline') ; ...
                      strcat(ListOfContrastNames{j,1}, ' & ', ListOfContrastNames{j,2}, ' < ', ' Baseline') };

                  
    for i=1:size(ContrastsValues,1)  
        cname = ContrastsNames{i};
        c = ContrastsValues(i,:);
        if i==1
            SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);
        else
            SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);
        end
    end


    % Evaluate
    spm_contrasts(SPM);
    
    
    %%

    clear jobs

    c = [eye(2) repmat(ones(1,length(SubjectsListTemp))/length(SubjectsListTemp),2,1)];

    jobs{1,1}.spm.stats.con.spmmat = {fullfile(pwd,'SPM.mat')};

    jobs{1,1}.spm.stats.con.consess{1,1}.fcon.name = 'Beta estimates';
    jobs{1,1}.spm.stats.con.consess{1,1}.fcon.convec{1,1} = c;

    spm_jobman('run',jobs);
    
    
    % Make a masked image of the subject structural
    imgsMat{1,1} = strcat(pwd, filesep, 'mask.hdr');
    imgsMat{2,1} = strcat('/home/SHARED/Experiment/IRMf/Pilot_5', filesep, 'GroupAverage', filesep, 'MeanStructural.nii');

    imgsInfo = spm_vol(char(imgsMat));

    volumes = spm_read_vols(imgsInfo);

    Mask = volumes(:,:,:,1);

    GroupAverage = volumes(:,:,:,2);

    GroupAverage(Mask==0)=GroupAverage(Mask==0)*0.5;

    
    % spm_write_vol: writes an image volume to disk
    newImgInfo = imgsInfo(2);

    % Change the name in the header
    newImgInfo.fname = strcat(pwd, filesep, 'MeanStructuralMasked.nii');
    newImgInfo.private.dat.fname = newImgInfo.fname;

    spm_write_vol(newImgInfo, GroupAverage);
    

    cd (PresentFolder)

end
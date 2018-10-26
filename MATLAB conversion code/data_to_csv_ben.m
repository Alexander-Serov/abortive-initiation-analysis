%% The function converts Matlab files from Ben to csv to be exported to Python

% constants;

%% Constants
gene_folders_short = {'hb', 'kn', 'sn'};
data_folder = 'D:\\Experimental_Data\Transcription. Processed data from Ben\';
csv_output_path = 'D:\\Experimental_Data\Transcription. Processed data from Ben\all_data_new.csv';
fluo_per_polymerase = 3.5e4/100; % in Stucken.	Am I sure about this number?

%%



% gene_folders = {'HunchBack', 'Knirps', 'SNAIL'};


% Initialize an empty structure


% AP_missing_datasets = {};
% required_fields_list = {'OriginalParticle','Frame','Index','xPos','yPos','APpos', 'APPos', 'APposParticle', 'NuclearAP','MeanAP','MedianAP','DVpos','MeanDV','MedianDV','FirstFrame','Approved','Fluo','Off','Off2','Fluo2','FluoOld','FluoRaw','FluoError','FitType','nc','Nucleus','PParticle','DParticle','EParticle','NucStart','NucEnd','TotalmRNA','TotalmRNAError','dataset','construct','gene'};


files = dir(fullfile(data_folder, '*.mat'));
files_len = length(files);
% data_sub = struct([]);

error_files = {};
output = struct([]);
output_id = 1;
for file_ind = 1: files_len
    file = files(file_ind); 

    file_path = fullfile(data_folder, file.name);
    fprintf('Processing file `%s`', file_path);

    try
        traces = load(file_path, 'Data');
        traces = traces.Data;
    catch
        error_files{end + 1} = file_path;
        continue;
    end



    traces_len = length(traces);
    for trace_id = 1:traces_len
        trace = traces(trace_id);
        fprintf('Processing file %i/%i, trace %i/%i\n', file_ind, files_len, trace_id, traces_len);

        % Identify the gene
        if contains(trace.emName, 'kn', 'IgnoreCase', true)
            g_ind = 2;
        elseif contains(trace.emName, 'sna', 'IgnoreCase', true)
            g_ind = 3;
        else
            g_ind = 1;
        end


        % Identify the construct
        if contains(trace.emName, 'shad', 'IgnoreCase', true)
            construct = 'no_sh';
            construct_id = 3;
        elseif contains(trace.emName, 'prim', 'IgnoreCase', true)
            construct = 'no_pr';
            construct_id = 2;
        else
            construct = 'bac';
            construct_id = 1;
        end
        
        % Get dataset name
        dataset = trace.emName(1:end-1);
        dataset = replace(dataset, '/', '-');
        
        



        fields = fieldnames(trace);
        frames_len = length(trace.time);
        for frame=1:frames_len

            for field_ind = 1:length(fields)
                field=fields{field_ind};
                if ~ischar(trace.(field)) && length(trace.(field)) > 1 
                    output(output_id).(field) = trace.(field)(frame);
                else
                    output(output_id).(field) = trace.(field);
                end

            end

            % Add & drop fields
            output(output_id).dataset = dataset;
            output(output_id).construct = construct;
            output(output_id).construct_id = construct_id;
            output(output_id).gene = gene_folders_short{g_ind};
            output(output_id).gene_id = g_ind - 1;
            output(output_id).trace_id = trace_id;
%             output(output_id).polymerases = output(output_id).intensity / fluo_per_polymerase;
            
            if output(output_id).time >= 0
                output(output_id).nc = 14;
%             elseif output(output_id).time >= -15
%                 output(output_id).nc = 13;
            else
                output(output_id).nc = nan;
            end

            output_id = output_id + 1;

        end
    end
end






% Ouput to file
output_table = struct2table(output);
% fid = fopen(csv_output_path,'w'); 
% fprintf(fid, data_table);
% fclose(fid);
writetable(output_table, csv_output_path, 'Delimiter', ';');

disp('Folders combined!');
count = length(error_files);
if count > 0
    disp('Encountered errors in the subfolders:');
    for i =1:count
        fprintf('%s\n', error_files{i});
    end
else
    disp('No errors while importing!')
end


















function process_stacks(reference_period)
% Maps of MAR

% Period as reference year

%reference_period = [datetime(2024,06,01),datetime(2024,06,30)]

baseline_period = [datetime(1990,09,30),datetime(2020,10,01)];

% Variable to process
if ismac
    load('/Volumes/data-1/projects/mar/geo.mat')
    data_path = '/Users/andrigun/Dropbox/01-Projects/data/climato.be/ftp/fettweis/tmp/andri/'
elseif isunix
    load('/data/projects/mar/geo.mat')
    data_path = '/data/mar'
    addpath /data/git/cdt
end

%%
% Location of netcdf data
% Find files
cd(data_path)
d = dir('*.nc');

% Filter baseline period stack files
for i = 1:length(d)
    sp = strsplit([d(i).name],{'-','.'});
    d(i).year = str2num(char(sp(end-1)));
end
%%
%ix = find(([d.year] >= baseline_period.Year(1)) &...
%    ([d.year] <= baseline_period.Year(end)));

%d = d(ix);

% Read and sum data
vars_to_process = [{'TTZ'};{'SMB'};{'SF'};{'RF'}];

for k = 1:length(vars_to_process)

    var_to_process = string(vars_to_process(k));

    nc_stack = [];
    nc_Time = [];

    for i = 1:length(d)

        % Need to check if the reference period spans more than one year, if
        % so, we need two files.

        fn = [d(i).folder,filesep,d(i).name];
        disp(['Reading file ', d(i).name])

        nc = ncread(fn,var_to_process);
        nc_time = ncdateread(fn, 'TIME');

        switch var_to_process
            case ['TTZ','SMB']
                nc_data = squeeze(nc(:,:,1,:));
            otherwise
                nc_data = squeeze(nc(:,:,:));
        end
        % Röðum saman gögnunum í stórann ref stack
        nc_stack = cat(3, nc_stack, nc_data);
        nc_Time = [nc_Time;nc_time];
    end

    %% Make baseline data
    % Check if reference_period spans over 2 years
    uqy = baseline_period.Year(1):1:baseline_period.Year(2);

    for i = 1:length(uqy)

        yr = uqy(i);

        if reference_period.Year(1) == reference_period.Year(2)
            disp('Data within the same calander year')
            year_to_process = 1;

            startTime =[datetime(yr,...
                reference_period.Month(1),...
                reference_period.Day(1))],...

            endTime = [datetime(yr,...
                reference_period.Month(end),...
                reference_period.Day(end))];
        else
            disp('Data spans more than one year')
            year_to_process = 2;

            startTime =[datetime(yr,...
                reference_period.Month(1),...
                reference_period.Day(1))];

            endTime = [datetime(yr+1,...
                reference_period.Month(end),...
                reference_period.Day(end))];
        end

        data_ix = find(nc_Time >= startTime &...
            nc_Time <= endTime);

        times = nc_Time(data_ix);

        dataTimes(i,1) = times(1);
        dataTimes(i,2) = times(end);

        data_bper_mean(:,:,i) = mean(nc_stack(:,:,data_ix),3,'omitmissing');
        data_bper_sum(:,:,i) = sum(nc_stack(:,:,data_ix),3,'omitmissing');

    end

    % Make reference data
    uqy = reference_period.Year(1):1:reference_period.Year(2);

    for i = 1:length(uqy)

        yr = uqy(i);

        if reference_period.Year(1) == reference_period.Year(2)
            disp('Data within the same calander year')
            year_to_process = 1;

            startTime =[datetime(yr,...
                reference_period.Month(1),...
                reference_period.Day(1))],...

            endTime = [datetime(yr,...
                reference_period.Month(end),...
                reference_period.Day(end))];
        else
            disp('Data spans more than one year')
            year_to_process = 2;

            startTime =[datetime(yr,...
                reference_period.Month(1),...
                reference_period.Day(1))],...

            endTime = [datetime(yr+1,...
                reference_period.Month(end),...
                reference_period.Day(end))];
        end

        data_ix = find(nc_Time >= startTime &...
            nc_Time <= endTime);

        times = nc_Time(data_ix);

        dataTimes_ref(i,1) = times(1);
        dataTimes_ref(i,2) = times(end);

        data_rper_mean(:,:,i) = mean(nc_stack(:,:,data_ix),3,'omitmissing');
        data_rper_sum(:,:,i) = sum(nc_stack(:,:,data_ix),3,'omitmissing');

    end
    %% Map result to stack
    switch var_to_process
        case 'TTZ'
            variable_name = 'air_temperature_2m';
        case 'SMB'
            variable_name = 'smb_mmweq';
        case 'SF'
            variable_name = 'snowfall_mmweq';
        case 'RF'
            variable_name = 'rainfall_mmweq';

        otherwise
    end

    cube.(string([variable_name,'_bp_mean'])) = data_bper_mean;
    cube.(string([variable_name,'_bp_sum'])) = data_bper_sum;

    cube.(string([variable_name,'_rp_mean'])) = data_rper_mean;
    cube.(string([variable_name,'_rp_sum'])) = data_rper_sum;

    cube.geo = geo;
    cube.reference_period = reference_period;
    cube.baseline_period = baseline_period;

end

cd /data/projects/mar/monthly_data
savename = [datestr(reference_period(1),'dd_mm_yyyy'),'-',datestr(reference_period(2),'dd_mm_yyyy')];
save(['marStacks-',savename,'.mat'],"cube")
end
%%
% figure,
% pcolor(geo.lon_mar,geo.lat_mar,...
%     cube.smb_mmweq_rp_sum(:,:,1))
% colorbar
% shading interp





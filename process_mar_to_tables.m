% MAR dumper to timetable
clear all
disp('Processing MAR data')

addpath /git/cdt
addpath /git/timeseriestools

load('/projects/mar/geo.mat')
cd /data/mar

d = dir('MARv3.14-5km-iceland*.nc');

MAR = struct;
%%
for k = 1:length(d)
    fn = [d(k).folder,filesep,d(k).name];
    disp(fn)
    nc = ncstruct(fn);
    nc.time = ncdateread(fn, 'TIME');

    SMB = squeeze(nc.SMB(:,:,1,:));

    % Breytur til að vinna fyrir utan SMB
    var.SU = squeeze(nc.SU(:,:,1,:)); % Sublimation
    var.ME = squeeze(nc.ME(:,:,1,:)); % Meltwater production
    var.SF = squeeze(nc.SF(:,:,:)); % Snowfall
    var.RF = squeeze(nc.RF(:,:,:)); % Meltwater production
    var.RU = squeeze(nc.RU(:,:,1,:)); % Runoff rain and melt

    % Climate breytur til að vinna
    var.LHF = squeeze(nc.LHF(:,:,:)); %Latent Heat Flux'
    var.SHF = squeeze(nc.SHF(:,:,:)); %'Sensible Heat Flux'
    var.TTZ = squeeze(nc.TTZ(:,:,1,:)); %'Temperature'

    var.U2Z = squeeze(nc.U2Z(:,:,1,:)); % x-reg-Wind Speed component
    var.V2Z = squeeze(nc.V2Z(:,:,1,:)); % y-reg-Wind Speed component
    var.SWD = squeeze(nc.SWD(:,:,:)); % Short Wave Downward
    var.LWD = squeeze(nc.LWD(:,:,:)); % Long  Wave Downward
    var.LWU = squeeze(nc.LWU(:,:,:)); % Long  Wave Upward
    var.AL2 = squeeze(nc.AL2(:,:,1,:)); % Albedo
    var.RHZ = squeeze(nc.RHZ(:,:,1,:)); % Relative humidity
    var.CU = squeeze(nc.CU(:,:,:));  % Cloud Cover (up)
    var.CM = squeeze(nc.CM(:,:,:));  % Cloud Cover (Middle)
    var.CD = squeeze(nc.CD(:,:,:));  % Cloud Cover (down)
    % Areas to proccess. Need to be ins with 1 as data to use and NaN to mask
    % out
    sites = fieldnames(geo.ins);

    for i = 1:length(sites)

        site = sites(i);

        % Area of the processed area
        area_km2 = sum(nc.AREA.*geo.ins.(string(site)),...
            [1,2],'omitmissing');

        area_m2 = sum(nc.AREA.*geo.ins.(string(site)),...
            [1,2],'omitmissing')*1000*1000;
        %
        if k == 1 % First loop to initiate tables
            MAR.(string(site)) = table;
            MAR.(string(site)).Time = nc.time;

            MAR.(string(site)).smb_mmWeq = squeeze(mean(SMB.*geo.ins.(string(site)),...
                [1,2],'omitmissing'));

            MAR.(string(site)).smb_mWeq = squeeze(mean(SMB.*geo.ins.(string(site)),...
                [1,2],'omitmissing'))/1000;

            MAR.(string(site)).smb_Gl = (MAR.(string(site)).smb_mWeq*area_m2)/1000000;

            % Melt area
            % 1 if area is melting
            %MAR.(string(site)).melt_area_km2
            melt_area = SMB.*geo.ins.(string(site));
            melt_area(melt_area>0) = 0;
            melt_area(melt_area<0) = 1;

            melt_area(isnan(melt_area)) = 0;
            melt_area_logi = logical(melt_area);
            x = size(melt_area);

            for j = 1:x(3)
                ix = melt_area_logi(:,:,j);

                ma = zeros(101,87);
                ma(ix) = nc.AREA(ix);
                MAR.(string(site)).melt_area_km2(j) = sum(ma,[1,2],'omitmissing');
                MAR.(string(site)).melt_area_prc(j) = (sum(ma,[1,2],'omitmissing')./area_km2)*100;
            end

            varstp = fieldnames(var);

            for v = 1:length(varstp)
                varName = string(varstp(v));

                switch varName
                    case 'TTZ'
                        MAR.(string(site)).([char(string(varName)),'_C°']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'LHF','SHF','SWD','LWD','LWU'}
                        MAR.(string(site)).([char(string(varName)),'_wm2']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'U2Z','V2Z'}
                        MAR.(string(site)).([char(string(varName)),'_ms']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'AL2','CU','CM','CD'}
                        MAR.(string(site)).([char(string(varName)),'']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'RHZ'}
                        MAR.(string(site)).([char(string(varName)),'_%']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    otherwise
                        MAR.(string(site)).([char(string(varName)),'_mmWeq']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                        MAR.(string(site)).([char(string(varName)),'_Gl']) =...
                            (squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing')/1000)*area_m2)/1000000;
                end
            end

        else % Loop for k > 1
  
            tmp = table;
            tmp.Time = nc.time;
            tmp.smb_mmWeq = squeeze(mean(SMB.*geo.ins.(string(site)),...
                [1,2],'omitmissing'));

            tmp.smb_mWeq = squeeze(mean(SMB.*geo.ins.(string(site)),...
                [1,2],'omitmissing'))/1000;

            tmp.smb_Gl = (tmp.smb_mWeq*area_m2)/1000000;

            % Melt area
            % 1 if area is melting
            %MAR.(string(site)).melt_area_km2
            melt_area = SMB.*geo.ins.(string(site));
            melt_area(melt_area>0) = 0;
            melt_area(melt_area<0) = 1;

            melt_area(isnan(melt_area)) = 0;
            melt_area_logi = logical(melt_area);
            x = size(melt_area);

            for j = 1:x(3)
                ix = melt_area_logi(:,:,j);

                ma = zeros(101,87);
                ma(ix) = nc.AREA(ix);
                tmp.melt_area_km2(j) = sum(ma,[1,2],'omitmissing');
                tmp.melt_area_prc(j) = (sum(ma,[1,2],'omitmissing')./area_km2)*100;
            end

            for v = 1:length(varstp) % All vars in var structure
                varName = string(varstp(v));

                switch varName

                    case 'TTZ'
                        tmp.([char(string(varName)),'_C°']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'LHF','SHF','SWD','LWD','LWU'}
                        tmp.([char(string(varName)),'_wm2']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'U2Z','V2Z'}
                        tmp.([char(string(varName)),'_ms']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'AL2','CU','CM','CD'}
                        tmp.([char(string(varName)),'']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    case {'RHZ'}
                        tmp.([char(string(varName)),'_%']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                    otherwise
                        tmp.([char(string(varName)),'_mmWeq']) =...
                            squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing'));

                        tmp.([char(string(varName)),'_Gl']) =...
                            (squeeze(mean(var.(string(varName)).*geo.ins.(string(site)),...
                            [1,2],'omitmissing')/1000)*area_m2)/1000000;
                end
            end
            
            MAR.(string(site)) = [MAR.(string(site));tmp];
        end
    end
end
% Make timetables from tables
x = fieldnames(MAR);
for j = 1:length(x)
    MAR.(string(x(j))) = table2timetable(MAR.(string(x(j))));
end

%
cd /projects/mar/daily_output
save('MAR_all.mat',"MAR",'-v7.3')

%% Clean and process table
% Get all field names in the structure
fieldNames = fieldnames(MAR);
% Select field names containing the string 'sensor'
selectedFields = fieldNames(contains(fieldNames, 'jokull'));

% Create a new structure to store the selected timetables
MAR_glaciers = struct();

%% Loop through the selected fields and extract the corresponding timetables
for i = 1:length(selectedFields)
    MAR_glaciers.(selectedFields{i}) = MAR.(selectedFields{i});
end

%% rename variables

fieldNames = fieldnames(MAR_glaciers);

for i = 1:length(fieldNames)
    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'SU_mmWeq'}, {'sublimation_mmWeq'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'SU_Gl'}, {'sublimation_Gl'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'ME_mmWeq'}, {'meltwater_mmWeq'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'ME_Gl'}, {'meltwater_Gl'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'SF_mmWeq'}, {'snowfall_mmWeq'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'SF_Gl'}, {'snowfall_Gl'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'RF_mmWeq'}, {'rainfall_mmWeq'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'RF_Gl'}, {'rainfall_Gl'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'RU_mmWeq'}, {'runoff_mmWeq'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'RU_Gl'}, {'runoff_Gl'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'TTZ_C°'}, {'air_temperature_2m'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'AL2'}, {'albedo'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'RHZ_%'}, {'rh'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'CU'}, {'cloud_upper'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'CM'}, {'cloud_middle'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'CD'}, {'cloud_down'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'U2Z_ms'}, {'ws_north_ms'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'V2Z_ms'}, {'ws_west_ms'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'SWD_wm2'}, {'sw_in_wm2'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'LWD_wm2'}, {'lw_in_wm2'});

    MAR_glaciers.(string(fieldNames(i))) = renamevars(MAR_glaciers.(string(fieldNames(i))),...
        {'LWU_wm2'}, {'lw_out_wm2'});



%% Add calcuialteed variables
% Wind speed
MAR_glaciers.(string(fieldNames(i))).wind_speed = ...
    sqrt(...
    MAR_glaciers.(string(fieldNames(i))).ws_north_ms.^2 ...
    + MAR_glaciers.(string(fieldNames(i))).ws_west_ms.^2);

% Wind direction
% Calculate wind direction in radians, then convert to degrees
wind_direction_rad = atan2(MAR_glaciers.(string(fieldNames(i))).ws_west_ms,...
     MAR_glaciers.(string(fieldNames(i))).ws_north_ms); % atan2(y, x)

MAR_glaciers.(string(fieldNames(i))).wind_direction_deg = rad2deg(wind_direction_rad);

% Ensure the direction is within [0, 360) degrees
MAR_glaciers.(string(fieldNames(i))).wind_direction_deg(MAR_glaciers.(string(fieldNames(i))).wind_direction_deg < 0) = MAR_glaciers.(string(fieldNames(i))).wind_direction_deg(MAR_glaciers.(string(fieldNames(i))).wind_direction_deg < 0) + 360;

% Radiation
MAR_glaciers.(string(fieldNames(i))).sw_out_wm2 = ...
    MAR_glaciers.(string(fieldNames(i))).sw_in_wm2.*...
    (1-MAR_glaciers.(string(fieldNames(i))).albedo);

MAR_glaciers.(string(fieldNames(i))).sw_net_wm2 = ...
    MAR_glaciers.(string(fieldNames(i))).sw_in_wm2 - MAR_glaciers.(string(fieldNames(i))).sw_out_wm2;

MAR_glaciers.(string(fieldNames(i))).lw_net_wm2 = ...
    MAR_glaciers.(string(fieldNames(i))).lw_in_wm2 - MAR_glaciers.(string(fieldNames(i))).lw_out_wm2;
end

cd /projects/mar/daily_output
%cd /Users/andrigun/Dropbox/01-Projects/data
save('MAR_glaciers.mat',"MAR_glaciers",'-v7.3')

%%
cd /projects/mar/daily_output
%%
baseline_period = [datetime(1990,01,01),datetime(2020,12,31)];
par_structure_of_timetables_to_overlay(MAR_glaciers,baseline_period)

%% Make MAR hydro
% Get all field names in the structure
fieldNames = fieldnames(MAR);
%% Select field names containing the string 'sensor'
selectedFields = fieldNames(~contains(fieldNames, 'jokull'));

%% Create a new structure to store the selected timetables
MAR_hydro = struct();

%% Loop through the selected fields and extract the corresponding timetables
for i = 1:length(selectedFields)
    MAR_hydro.(selectedFields{i}) = MAR.(selectedFields{i});
end

%% rename variables

fieldNames = fieldnames(MAR_hydro);

for i = 1:length(fieldNames)
    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'SU_mmWeq'}, {'sublimation_mmWeq'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'SU_Gl'}, {'sublimation_Gl'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'ME_mmWeq'}, {'meltwater_mmWeq'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'ME_Gl'}, {'meltwater_Gl'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'SF_mmWeq'}, {'snowfall_mmWeq'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'SF_Gl'}, {'snowfall_Gl'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'RF_mmWeq'}, {'rainfall_mmWeq'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'RF_Gl'}, {'rainfall_Gl'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'RU_mmWeq'}, {'runoff_mmWeq'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'RU_Gl'}, {'runoff_Gl'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'TTZ_C°'}, {'air_temperature_2m'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'AL2'}, {'albedo'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'RHZ_%'}, {'rh'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'CU'}, {'cloud_upper'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'CM'}, {'cloud_middle'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'CD'}, {'cloud_down'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'U2Z_ms'}, {'ws_north_ms'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'V2Z_ms'}, {'ws_west_ms'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'SWD_wm2'}, {'sw_in_wm2'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'LWD_wm2'}, {'lw_in_wm2'});

    MAR_hydro.(string(fieldNames(i))) = renamevars(MAR_hydro.(string(fieldNames(i))),...
        {'LWU_wm2'}, {'lw_out_wm2'});

%% Add calcuialteed variables
% Wind speed
MAR_hydro.(string(fieldNames(i))).wind_speed = ...
    sqrt(...
    MAR_hydro.(string(fieldNames(i))).ws_north_ms.^2 ...
    + MAR_hydro.(string(fieldNames(i))).ws_west_ms.^2);

% Wind direction
% Calculate wind direction in radians, then convert to degrees
wind_direction_rad = atan2(MAR_hydro.(string(fieldNames(i))).ws_west_ms,...
     MAR_hydro.(string(fieldNames(i))).ws_north_ms); % atan2(y, x)

MAR_hydro.(string(fieldNames(i))).wind_direction_deg = rad2deg(wind_direction_rad);

% Ensure the direction is within [0, 360) degrees
MAR_hydro.(string(fieldNames(i))).wind_direction_deg(MAR_hydro.(string(fieldNames(i))).wind_direction_deg < 0) = MAR_hydro.(string(fieldNames(i))).wind_direction_deg(MAR_hydro.(string(fieldNames(i))).wind_direction_deg < 0) + 360;

% Radiation
MAR_hydro.(string(fieldNames(i))).sw_out_wm2 = ...
    MAR_hydro.(string(fieldNames(i))).sw_in_wm2.*...
    (1-MAR_hydro.(string(fieldNames(i))).albedo);

MAR_hydro.(string(fieldNames(i))).sw_net_wm2 = ...
    MAR_hydro.(string(fieldNames(i))).sw_in_wm2 - MAR_hydro.(string(fieldNames(i))).sw_out_wm2;

MAR_hydro.(string(fieldNames(i))).lw_net_wm2 = ...
    MAR_hydro.(string(fieldNames(i))).lw_in_wm2 - MAR_hydro.(string(fieldNames(i))).lw_out_wm2;
end
%%
cd /projects/mar/daily_output
%cd /Users/andrigun/Dropbox/01-Projects/data
save('MAR_hydro.mat',"MAR_hydro",'-v7.3')

%%
cd /projects/mar/daily_output
%%
baseline_period = [datetime(1990,01,01),datetime(2020,12,31)];
par_structure_of_timetables_to_overlay(MAR_hydro,baseline_period)




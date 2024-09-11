function mapped_data = mar2modisgrid(data,geo)
% Make georefernce object for RAV
% Old code, virkar ekki, gögnin eru á uneven griddi úr ráv2
%     latlim = [min(min(geo.lat_rav)) max(max(geo.lat_rav))];
%     lonlim = [min(min(geo.lon_rav)) max(max(geo.lon_rav))];
%     x = size(geo.lat_rav);
%     rasterSize = [x(2) x(1)];
%     R = georefcells(latlim,lonlim,rasterSize);

%n = ncinfo(ncfile);
%n.Variables.Name; % if we want to ds all the rav variables
%Variables to process
%	X = geo.lat(:);               % Latitudes for MODIS
%   Y = geo.lon(:);               % Longitudes for MODIS
%% Hnitun frá MODIS
xq = double(geo.lat);
yq = double(geo.lon);
% Hnitun frá R�?V2
x = double(geo.lat_mar(:));
y = double(geo.lon_mar(:));
% 
% for i = 1:length(vars2mapp);  %length({n.Variables.Name});
%     %data = ncread(ncfile,n.Variables(i).Name);
   % data = data;%ncread(ncfile,string(vars2mapp(i)));
    %dataflip = flipud(rot90(data));
    v = double(data(:));
    mapped_data = griddata(x,y,v,xq,yq);
    %rav_mapped = rav_mapped.*geo.ins.island;
    %rav_mapped = ltln2val(dataflip,R,X,Y,'nearest');  % Map elevation from isl_dem_500m_wgs
 %   rav.(string(vars2mapp(i))) = rav_mapped; %reshape(rav_mapped,[2400,2400]);
%end
end
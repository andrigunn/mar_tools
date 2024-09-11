load('/Volumes/data-1/projects/mar/daily_output/marStacks-01_05_2024-30_05_2024.mat')
S = shaperead('/Users/andrigun/Dropbox/04-Repos/geo/shp/island_utlina.shp')
%%
load('geo_hv17.mat')
cube.geo.lat = lat;
cube.geo.lon = lon;
cube.geo.mask.island_rav = island;
%%
downscale = 1
% plt_mar_cubes(cube, downscale,variable)
%%
vis = 'on'
text_up_left = 'precip'
variable = 'precip'

if contains(variable, 'air_temperature')

    data = cube.air_temperature_2m_rp_mean-...
        mean(cube.air_temperature_2m_bp_mean,3,'omitmissing');

elseif contains(variable, 'precip')

        data = (cube.rainfall_mmweq_rp_sum+cube.snowfall_mmweq_rp_sum)...
            -...
        mean((cube.rainfall_mmweq_bp_sum+cube.smb_mmweq_bp_sum),3,'omitmissing');
end

%
    
    if downscale == 1
        mapped_data = mar2modisgrid(data,cube.geo).*cube.geo.mask.island_rav;
        lats = cube.geo.lat;
        lons = cube.geo.lon;

    else
        mapped_data = data;
        lats = cube.geo.lat_mar;
        lons = cube.geo.lon_mar;

    end
%data = cube.rainfall_mmweq_rp_sum-mean(cube.rainfall_mmweq_bp_sum,3,'omitmissing')...
 %   .*geo.ins.island_utlina;
%%
set(0,'defaultfigurepaperunits','centimeters');
x = 25;
y = 45;
set(0,'DefaultAxesFontSize',15)
set(0,'defaultfigurecolor','w');
set(0,'defaultfigureinverthardcopy','off');
set(0,'defaultfigurepaperorientation','landscape');
set(0,'defaultfigurepapersize',[y x]);
set(0,'defaultfigurepaperposition',[.25 .25 [y x]-0.5]);
set(0,'DefaultTextInterpreter','none');
set(0, 'DefaultFigureUnits', 'centimeters');
set(0, 'DefaultFigurePosition', [.25 .25 [y x]-0.5]);

latlimit = [63.3943927778338 66.5377933091516];
lonlimit = [-24.5326753866627 -13.4946206239503];

figure
axesm('MapProjection','mercator','MapLatLimit',latlimit,'MapLonLimit',lonlimit);
hold on

pcolorm(double(lats),...
    double(lons),...
    double(mapped_data));
    
    shading interp
    
    cmocean('balance','pivot',0)
    colorbar
    plotm(S.Y,S.X,'Color','k')
    reference_period = ([['Tímabil: ' datestr(cube.reference_period(1),'dd.mm.yyyy'),' til ',datestr(cube.reference_period(2),'dd.mm.yyyy')]]);
    baseline_period = ([['Viðmið: ' datestr(cube.baseline_period(1),'yyyy'),' til ',datestr(cube.baseline_period(2),'yyyy')]]);

    text(0.01,0.01,[reference_period],...
        'Units','normalized','HorizontalAlignment','left',...
        'VerticalAlignment','bottom','FontSize',16,'FontWeight','normal',...
        'Interpreter','none');

    text(0.99,0.01,[baseline_period],...
        'Units','normalized','HorizontalAlignment','right',...
        'VerticalAlignment','bottom','FontSize',16,'FontWeight','normal',...
        'Interpreter','none');

    text(0.01,0.99,[text_up_left],...
        'Units','normalized','HorizontalAlignment','left',...
        'VerticalAlignment','top','FontSize',16,'FontWeight','normal',...
        'Interpreter','none');

    text(1,0,['MARv3.5 forced by ERA5'],'Units','normalized','HorizontalAlignment','right',...
        'VerticalAlignment','top','Interpreter','none','FontSize',12,...
        'FontWeight','normal');

     


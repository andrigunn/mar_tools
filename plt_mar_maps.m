load('/Volumes/data-1/projects/mar/daily_output/marStacks-01_05_2024-30_05_2024.mat')

%% plt_mar_cubes()
%%
vis = 'on'
text_up_left = 'rainfall_mmweq_bp_sum'
%data = cube.air_temperature_2m_rp_mean-mean(cube.air_temperature_2m_bp_mean,3,'omitmissing');

data = cube.rainfall_mmweq_rp_sum-mean(cube.rainfall_mmweq_bp_sum,3,'omitmissing')...
    .*geo.ins.island_utlina;

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

pcolorm(double(cube.geo.lat_mar),...
    double(cube.geo.lon_mar),...
    double(data));
    
    shading interp
    
    cmocean('balance','pivot',0)
    colorbar
    
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

     


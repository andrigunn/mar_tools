
cd /project/mar/daily_output
%%
addpath /Users/andrigun/Dropbox/04-Repos/Water.Basics/cdt/
addpath /Users/andrigun/Dropbox/04-Repos/timeseriestools/

set(0,'defaultfigurepaperunits','centimeters');
set(0,'DefaultAxesFontSize',16)
set(0,'defaultfigurecolor','w');
set(0,'defaultfigureinverthardcopy','off');
set(0,'defaultfigurepaperorientation','landscape');
set(0,'defaultfigurepapersize',[35 21]);
set(0,'defaultfigurepaperposition',[.25 .25 [35 21]-0.5]);
set(0,'DefaultTextInterpreter','none');
set(0, 'DefaultFigureUnits', 'centimeters');
set(0, 'DefaultFigurePosition', [.25 .25 [35 21]-0.5]);

%% Find all the overlay structures
d = dir('*_overlay*');
%%
for i = 1%:length(d)
    load([d(i).name])
    gname = [d(i).name];
    gname = replace( gname , '_' , ' ' );
    gname = replace( gname , 'overlay.mat' , ' ' );
    fig_title = replace( gname , 'jokull' , 'jökull' );

figure, hold on
plt_overlay(Rt.smb_mmWeq,tbl.smb_mmWeq,...
    [2021,2022,2023],[fig_title,'Dagleg afkoma yfirborðs'],...
    '(mm w.eq.)',...
    'SMB',' smb_mmWeq')

    cd '/projects/mar/daily_output'
    exportgraphics(gcf,'mar_smb_mmWeq_ts.jpg');
    exportgraphics(gcf,'mar_smb_mmWeq_ts.pdf');


figure, hold on
plt_overlay(Rc.smb_mmWeq,tbl.smb_mmWeq,...
    [2021,2022,2023],[fig_title,'- Uppsöfnuð afkoma yfirborðs'],...
    '(mm w.eq.)',...
    '','smb_mmWeq')
    
    exportgraphics(gcf,'mar_smb_mmWeq_cumts.jpg');
    exportgraphics(gcf,'mar_smb_mmWeq_cumts.pdf');

figure, hold on
plt_overlay(Rc.snowfall_mmWeq,tbl.snowfall_mmWeq,...
    [2021,2022,2023],[fig_title,'- Uppsöfnuð úrkoma (snjór)'],...
    '(mm w.eq.)',...
    'mmWeq',' ')

    exportgraphics(gcf,'mar_snowfall_mmWeq_cumts.jpg');
    exportgraphics(gcf,'mar_snowfall_mmWeq_cumts.pdf');

figure, hold on
plt_overlay(Rc.rainfall_mmWeq,tbl.rainfall_mmWeq,...
    [2021,2022,2023],[fig_title,'- Uppsöfnuð úrkoma (regn)'],...
    '(mm w.eq.)',...
    'mmWeq',' ')

    exportgraphics(gcf,'mar_rainfall_mmWeq_cumts.jpg');
    exportgraphics(gcf,'mar_rainfall_mmWeq_cumts.pdf');

figure, hold on
plt_overlay(Rc.runoff_mmWeq,tbl.runoff_mmWeq,...
    [2021,2022,2023],[fig_title,'- afrennsli'],...
    '(mm w.eq.)',...
    'mmWeq',' ')

    exportgraphics(gcf,'mar_runoff_mmWeq_cumts.jpg');
    exportgraphics(gcf,'mar_runoff_mmWeq_cumts.pdf');

figure, hold on
plt_overlay(Rc.meltwater_mmWeq,tbl.meltwater_mmWeq,...
    [2021,2022,2023],[fig_title,'- leysing'],...
    '(mm w.eq.)',...
    'mmWeq',' ')

    exportgraphics(gcf,'mar_meltwater_mmWeq_cumts.jpg');
    exportgraphics(gcf,'mar_meltwater_mmWeq_cumts.pdf');

figure, hold on
plt_overlay(Rt.air_temperature_2m,tbl.air_temperature_2m,...
    [2021,2022,2023],[fig_title,'- lofthiti'],...
    '(°C)',...
    '',' ')

    exportgraphics(gcf,'mar_air_temperature_2m_ts.jpg');
    exportgraphics(gcf,'mar_air_temperature_2m_ts.pdf');

sw_n = Rt.sw_net_wm2.HY_2023;
lw_n = Rt.lw_net_wm2.HY_2023;
shf = Rt.SHF_wm2.HY_2023;
lhf = Rt.LHF_wm2.HY_2023;
time = Rt.sw_in_wm2.Time;
T = timetable(time, sw_n, lw_n, shf, lhf);

sw_n_mean = Rt.sw_net_wm2.AY_mean;
lw_n_mean = Rt.lw_net_wm2.AY_mean;
shf_mean = Rt.SHF_wm2.AY_mean;
lhf_mean = Rt.LHF_wm2.AY_mean;
T_mean = timetable(time, sw_n_mean, lw_n_mean, shf_mean, lhf_mean);

clines = lines(6)
figure, hold on
tiledlayout(4,1)
nexttile, hold on
plot(T.time,T.sw_n,'LineWidth',1.2,'Color',clines(1,:),...
    'DisplayName','sw_{net}')
plot(T_mean.time,T_mean.sw_n_mean,'LineWidth',1.5,'Color',[clines(1,:),0.7],...
    'DisplayName','sw_{mean}')

legend show
grid on

nexttile, hold on
plot(T.time,T.lw_n,'LineWidth',1.2,'Color',clines(2,:),...
    'DisplayName','lw_{net}')
plot(T_mean.time,T_mean.lw_n_mean,'LineWidth',1.5,'Color',[clines(2,:),0.7],...
    'DisplayName','lw_{mean}')

legend show
grid on

nexttile, hold on
plot(T.time,T.shf,'LineWidth',1.2,'Color',clines(3,:),...
    'DisplayName','shf')
plot(T_mean.time,T_mean.shf_mean,'LineWidth',1.5,'Color',[clines(3,:),0.7],...
    'DisplayName','shf_{mean}')

legend show
grid on

nexttile, hold on
plot(T.time,T.lhf,'LineWidth',1.2,'Color',clines(4,:),...
    'DisplayName','lhf')
plot(T_mean.time,T_mean.lhf_mean,'LineWidth',1.5,'Color',[clines(4,:),0.7],...
    'DisplayName','lhf_{mean}')

legend show
grid on

sgtitle([fig_title,'- orkuþættir'])

    exportgraphics(gcf,'mar_seb_ts.jpg');
    exportgraphics(gcf,'mar_seb_ts.pdf');


end

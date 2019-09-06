%% SinusDemo by KalMa    #MatFunZone (2019)
%  contact: maciej.kalarus@gmail.com
%  ------------------------------------------------------------------------

function SinusDemo
    global Demo
    
    Demo.Name          = 'SinusDemo';
    Demo.Version       = 1;
    Demo.FPS           = 20;               % [frames per second]

    %% Board
    Board.Size    = [500 500];        % [X Y] [pixels]
    Board.Color   = [0.9 0.9 0.9];

    Demo.Panel.Width   = 220;
    Demo.Panel.Color   = [0.7 0.7 0.7];
    Demo.Control.Left  = Board.Size(1) + 6;
    Demo.Control.Top   = Board.Size(1) - 30;

    Demo.BallStyle     = struct('Marker','o','MarkerSize',20,'Color',[0 0.5 0],'LineStyle','none');
    Demo.CommonStyle   = struct('Units','pixels','BackgroundColor',Demo.Panel.Color);
    
    %% application window
    ScreenSize = get(0,'ScreenSize');
    S = Board.Size;
    figure( 'Units','pixels',...
            'Position',[(ScreenSize(3:4) - S - [Demo.Panel.Width, 0])*0.5, S] + [0 0 Demo.Panel.Width 10],...
            'MenuBar','none',...
            'NumberTitle','off',...
            'Resize','off',...
            'Color',Demo.Panel.Color,...
            'Name',sprintf('%s by KalMa (v%0.1f)', Demo.Name, Demo.Version),...
            'CloseRequestFcn',@(~,~)CloseApp());
    
    axes( 'Units','pixels',...
          'Position',[5 5 S-1],...
          'NextPlot','add',...
          'box','on',...
          'Color',Board.Color,...
          'xlim',[-2.1 2.1],...
          'ylim',[-2.1 2.1],...
          'XTick',[],...
          'YTick',[]);
       
    ln = linspace(-1,1,361);
    Demo.hBall = line(ln,ln,Demo.BallStyle);
    Demo.p = [0 0 0 0];

    %% controls
    Left = Demo.Control.Left;
    Top  = Demo.Control.Top;
    
    PS = PredefinedSettings();
    Demo.Settings = uicontrol(...
        'Style','popupmenu',...
        'Position',[Left+60,Top,Demo.Panel.Width - 100,20],...
        'String',{PS(:).N},...
        'Callback', @(src,~)ChangeSettings(src.Value));

    Demo.P(1)  = CuiControl('Phase x1', [Left, Top - 50], -180, 180, 0);
    Demo.P(2)  = CuiControl('Phase x2', [Left, Top - 80], -180, 180, 0);
    Demo.P(3)  = CuiControl('Phase y1', [Left, Top - 110], -180, 180, 0);
    Demo.P(4)  = CuiControl('Phase y2', [Left, Top - 140], -180, 180, 0);

    Demo.S(1)  = CuiControl('Step x1', [Left, Top - 180], -180, 180, 0);
    Demo.S(2)  = CuiControl('Step x2', [Left, Top - 210], -180, 180, 0);
    Demo.S(3)  = CuiControl('Step y1', [Left, Top - 240], -180, 180, 0);
    Demo.S(4)  = CuiControl('Step y2', [Left, Top - 270], -180, 180, 0);
    
    Demo.SF(1) = CuiControl('Shift x1', [Left, Top - 310], -180, 180, 0);
    Demo.SF(2) = CuiControl('Shift x2', [Left, Top - 340], -180, 180, 0);
    Demo.SF(3) = CuiControl('Shift y1', [Left, Top - 370], -180, 180, 0);
    Demo.SF(4) = CuiControl('Shift y2', [Left, Top - 400], -180, 180, 0);
    
    Demo.nBall = CuiControl('nBall', [Left, Top - 450], 1, 90, 30);

    ChangeSettings(1);
    
    %% Timer
    Demo.hTimer = timer(...
        'Period',1/Demo.FPS,...
        'ExecutionMode','fixedRate',...
        'TimerFcn',@(~,~)Show());
    
    start(Demo.hTimer);
end

function Show()
    global Demo
    P = cell(4,1);
    S = 1:Demo.nBall.Value;
    for i=1:4
        Demo.p(i) = mod(Demo.p(i) + Demo.S(i).Value, 360);
        P{i} = Demo.P(i).Value + Demo.p(i) + S*Demo.SF(i).Value; 
    end
    x = sind(P{1}) + sind(P{2});
    y = sind(P{3}) + sind(P{4});
    
    set(Demo.hBall,'XData',x,'YData',y');
end

function CloseApp()
    global Demo
    stop(Demo.hTimer);
    delete(gcf);
end

function h = CuiControl(name, position, min, max, value)
    global Demo
    Control.Width = Demo.Panel.Width - 100;
    uicontrol(Demo.CommonStyle,...
        'Style','text',...
        'Position',[position,55,20],...
        'HorizontalAlignment','right',...
        'String',name);

    hv = uicontrol(Demo.CommonStyle,...
        'Style','text',...
        'Position',[position + [Control.Width+65,0],60,20],...
        'HorizontalAlignment','left',...
        'String',sprintf("%d",round(value)));

    h = uicontrol(Demo.CommonStyle,...
        'Style','slider',...
        'Min',min,...
        'Max',max,...
        'SliderStep',[1/(max-min),1/(max-min)*5],...
        'Position',[position + [60 4], Control.Width,20],...
        'Value',value,...
        'UserData',hv,...
        'Callback',@(src,~)UpdateParInfo(src));
end

function UpdateParInfo(src)
    src.UserData.String = sprintf("%d",round(src.Value));
    src.Value = round(src.Value);
end

function ChangeSettings(k)
    global Demo
    PS = PredefinedSettings();
    for i=1:4
        Demo.p(i) = 0;
        Demo.P(i).Value = PS(k).P(i);
        UpdateParInfo(Demo.P(i));
        Demo.S(i).Value = PS(k).S(i);
        UpdateParInfo(Demo.S(i));
        Demo.SF(i).Value = PS(k).SF(i);
        UpdateParInfo(Demo.SF(i));
    end
    Demo.nBall.Value = PS(k).nB;
    UpdateParInfo(Demo.nBall);
end

function PS = PredefinedSettings()
    PS(1)  = struct('N','2 curves', 'P',[0 88 0 0],'S',[4 -5 3 -4],'SF',[1 -179 1 180],'nB',90);
    PS(2)  = struct('N','4 curves', 'P',[-180 118 -20 88],'S',[7 5 2 -5],'SF',[91 -180 91 179],'nB',90);
    PS(3)  = struct('N','1 snake',  'P',[0 0 0 0],'S',[-4 7 -3 2],'SF',[-4 7 -3 2],'nB',90);
    PS(4)  = struct('N','2 snakes', 'P',[0 0 0 90],'S',[-4 3 -3 2],'SF',[-4 -177 177 2],'nB',90);
    PS(5)  = struct('N','dancer',   'P',[0 0 75 0],'S',[-6 -7 -4 5],'SF',[-4 5 -3 4],'nB',30);
    PS(6)  = struct('N','1 circle', 'P',[0 0 30 0],'S',[20 2 -3 -4],'SF',[10 0 -10 0],'nB',36);
    PS(7)  = struct('N','2 circles','P',[0 0 30 0],'S',[7 2 -3 -4],'SF',[10 180 -10 180],'nB',36);
    PS(8)  = struct('N','blinking', 'P',[0 0 30 0],'S',[7 178 -179 -4],'SF',[10 180 -10 180],'nB',36);
    PS(9)  = struct('N','ring',     'P',[0 0 0 0],'S',[2 -3 -5 -4],'SF',[30 1 -30 1],'nB',90);
    PS(10) = struct('N','swarm',    'P',[0 0 0 0],'S',[2 -3 -5 -4],'SF',[33 -2 -31 -3],'nB',90);
    PS(11) = struct('N','moire',    'P',[30 3 1 4],'S',[-1 1 1 1],'SF',[-1 1 1 1],'nB',90);
    PS(12) = struct('N','zero',     'P',[0 0 0 0],'S',[0 0 0 0],'SF',[0 0 0 0],'nB',1);
end

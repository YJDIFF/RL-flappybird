function data=flappybird2(alpha,gamma,iterationmax,learnresult)
import java.awt.*;
import java.awt.event.*;
%% System Variables:
GameVer = '1.0';          % The first full playable game

%% Constant Definitions:
GAME.MAX_FRAME_SKIP = [];

GAME.RESOLUTION = [];       % Game Resolution, default at [256 144]
GAME.WINDOW_SCALE = 2;     % The actual size of the window divided by resolution
GAME.FLOOR_TOP_Y = [];      % The y position of upper crust of the floor.
GAME.N_UPDATES_PER_SEC = [];
GAME.FRAME_DURATION = [];
GAME.GRAVITY = 0.10; %0.15; %0.2; %1356;  % empirical gravity constant
      
TUBE.MIN_HEIGHT = [];       % The minimum height of a tube
TUBE.RANGE_HEIGHT = [];     % The range of the height of a tube
TUBE.SUM_HEIGHT = [];       % The summed height of the upper and low tube
TUBE.H_SPACE = [];           % Horizontal spacing between two tubs
TUBE.V_SPACE = [];          % Vertical spacing between two tubs
TUBE.WIDTH   = [];            % The 'actual' width of the detection box
GAMEPLAY.RIGHT_X_FIRST_TUBE = [];  % Xcoord of the right edge of the 1st tube

ShowFPS = true;
SHOWFPS_FRAMES = 5;
%% Handles
MainFigureHdl = [];
MainAxesHdl = [];
MainCanvasHdl = [];
BirdSpriteHdl = [];
TubeSpriteHdl = [];
BeginInfoHdl = [];
FloorSpriteHdl = [];
ScoreInfoHdl = [];
GameOverHdl = [];
FloorAxesHdl = [];
IterationHdl = [];
%% Game Parameters
MainFigureInitPos = [];
MainFigureSize = [];
MainAxesInitPos = []; % The initial position of the axes IN the figure
MainAxesSize = [];

InGameParams.CurrentBkg = 1;
InGameParams.CurrentBird = 1;

Flags.IsGameStarted = true;     %
Flags.IsFirstTubeAdded = false; % Has the first tube been added to TubeLayer
Flags.ResetFloorTexture = true; % Result the pointer for the floor texture
Flags.PreGame = true;
Flags.NextTubeReady = true;
CloseReq = false;

FlyKeyNames = {'space', 'return', 'uparrow', 'w'};
FlyKeyStatus = false; %(size(FlyKeyNames));
FlyKeyValid = true(size(FlyKeyNames));      % 
%% Canvases:
MainCanvas = [];

% The scroll layer for the tubes
TubeLayer.Alpha = [];
TubeLayer.CData = [];


%% RESOURCES:
Sprites = [];

%% Positions:
Bird.COLLIDE_MASK = [];
Bird.INIT_SCREEN_POS = [45 100];                    % In [x y] order;
Bird.WorldX = [];
Bird.ScreenPos = [45 100]; %[45 100];   % Center = The 9th element horizontally (1based)
                                     % And the 6th element vertically 
Bird.SpeedXY = [ 0];
Bird.Angle = 0;
Bird.XGRID = [];
Bird.YGRID = [];
Bird.CurFrame = 1;
Bird.SpeedY = 0;
Bird.LastHeight = 0;

SinYRange = 44;
SinYPos = [];
SinY = [];

Score = 0;

Tubes.FrontP = 1;              % 1-3
Tubes.ScreenX = [300 380 460]-2; % The middle of each tube
Tubes.VOffset = ceil(rand(1,3)*55); 

Best = 0;

%% Q-learning
if learnresult==1 %training, initial Q matrix
Qloop=1;
Q = zeros(14,1,2);
Qall = zeros(14,1,2);
elseif learnresult==2%replay, load Q matrix
Qloop=1;
load('data\Qflappybird.mat','Q');
Qall = zeros(14,1,2);
end



% only used for priority visiting for larger maze
%visitFlag = zeros(size(maze2D,1),size(maze2D,2));

% status message for goal and bump

% BUMP = 10;

% learning rate settings
% alpha = 0.1; 
% gamma = 0.05;

v1 = VideoWriter('video\FlappybirdVideo.mp4','MPEG-4'); %initial videos

%% -- Game Logic --
initVariables();
initWindow();

if ShowFPS
    fps_text_handle = text(10,10, 'FPS:60.0', 'Visible', 'off');
    var_text_handle = text(10,20, '', 'Visible', 'off'); % Display a variable
    total_frame_update = 0;
end

% Show flash screen
CurrentFrameNo = double(0);

fade_time = cumsum([1 3 1]);

pause(0.5); %display logo
logo_stl = text(72, 100, 'Stellari Studio', 'FontSize', 20, 'Color',[1 1 1], 'HorizontalAlignment', 'center');
logo_and = text(72, 130, 'and', 'FontSize', 10, 'Color',[1 1 1], 'HorizontalAlignment', 'center');
logo_ilovematlabcn = image([22 122], [150 180], Sprites.MatlabLogo, 'AlphaData',0);
stageStartTime = tic;
while 1
    loops = 0;
    curTime = toc(stageStartTime);
    while (curTime >= ((CurrentFrameNo) * GAME.FRAME_DURATION) && loops < GAME.MAX_FRAME_SKIP)
        if curTime < fade_time(1)
            set(logo_stl, 'Color',1 - [1 1 1].*max(min(curTime/fade_time(1), 1),0));
            set(logo_ilovematlabcn, 'AlphaData', max(min(curTime/fade_time(1), 1),0));
            set(logo_and, 'Color',1 - [1 1 1].*max(min(curTime/fade_time(1), 1),0));
        elseif curTime < fade_time(2)
            set(logo_stl, 'Color',[0 0 0]);
            set(logo_ilovematlabcn, 'AlphaData', 1);
            set(logo_and, 'Color', [0 0 0]);
        else
            set(logo_stl, 'Color',[1 1 1].*max(min((curTime-fade_time(2))/(fade_time(3) - fade_time(2)), 1),0));
            set(logo_ilovematlabcn, 'AlphaData',1-max(min((curTime-fade_time(2))/(fade_time(3) - fade_time(2)), 1),0));
            set(logo_and, 'Color', [1 1 1].*max(min((curTime-fade_time(2))/(fade_time(3) - fade_time(2)), 1),0));
        end
        CurrentFrameNo = CurrentFrameNo + 1;
       loops = loops + 1;
       frame_updated = true;
    end
    if frame_updated
        drawnow;
    end
    if curTime > fade_time
        break;
    end
end
delete(logo_stl);
delete(logo_ilovematlabcn);
delete(logo_and);
pause(1);
% w(1,:)=[rand(),rand()];
iteration=1;
% gameover = false;

% Main Game
while 1

initGame();
CurrentFrameNo = double(0);%initial values
collide = false;
fall_to_bottom = false;
gameover = false;
stageStartTime = tic;
c = stageStartTime;
FPS_lastTime = toc(stageStartTime);
pressspace(); %start to play automatically
    presst=0;
    framenum=1;
    

while 1
    status = -1;
    countActions = 0;
    currentDirection = 1;
%     if iteration>1
%     load('data.mat');
%     Mdl = fitclinear(data(:,1:2),data(:,4));
% end
    loops = 0;
    curTime = toc(stageStartTime);
    c = stageStartTime;
    while (curTime >= ((CurrentFrameNo) * GAME.FRAME_DURATION) && loops < GAME.MAX_FRAME_SKIP)
        if FlyKeyStatus  % If left key is pressed     
            if ~gameover
                Bird.SpeedY = -1.5; % -2.5;
                FlyKeyStatus = false;
                Bird.LastHeight = Bird.ScreenPos(2);
                if Flags.PreGame
                    Flags.PreGame = false;                    
                    set(BeginInfoHdl, 'Visible','off');
                    set(ScoreInfoBackHdl, 'Visible','on');
                    set(ScoreInfoForeHdl, 'Visible','on');
                    Bird.ScrollX = 0;
                end
            else
                if Bird.SpeedY < 0
                    Bird.SpeedY = 0;
                end
            end

        end
        if Flags.PreGame
            processCPUBird;
        else
            processBird;
            Bird.ScrollX = Bird.ScrollX + 1;
            if ~gameover
                [distancex,distancey]=scrollTubes(1);%obtain bird state (distance from bird to next tube)
            end
        end
        %% Q learning
        if rem(framenum,6)==1 % every 6 frames
            if ~gameover % if not gameover, quantization bird y-distance
                GOAL=8;
                if distancey>=30
                    status=1;
                elseif distancey>=25
                    status=2;
                elseif distancey>=20
                    status=3;
                elseif distancey>=15
                    status=4;
                elseif distancey>=10
                    status=5;
                elseif distancey>=5
                    status=6;
                elseif distancey>=2
                    status=7;
                elseif distancey>=-2
                    status=8;
                elseif distancey>=-5
                    status=9;
                elseif distancey>=-10
                    status=10;
                elseif distancey>=-15
                    status=11;
                elseif distancey>=-20
                    status=12;
                elseif distancey>=-25
                    status=13;
                elseif distancey<=-25
                    status=14;
                end
            if status~= GOAL
                % record the current position of the robot for use later
                prvRow = status; prvCol = 1; %match the bird state to Q matrix
                
                % select an action value i.e. Direction
                % which has the maximum value of Q in it
                % if more than one actions has same value then select randomly from them
                [val,index] = max(Q(prvRow,prvCol,:)); %locate the largest value under current state
                [xx,yy] = find(Q(prvRow,prvCol,:) == val);
                if size(yy,1) > 1
                    index = 1+round(rand*(size(yy,1)-1));
                    action = yy(index,1);
                else
                    action = index;
                end
%                 display(action);
                % based on the selected actions correct the orientation of the
                % robot to conform to rules of simulator
%                 if currentDirection ~= action
%                     currentDirection = 1;
%                     % count the actions required to reach the goal
%                     countActions = countActions + 1;
%                 end
                
                % do the selected action i.e. MoveAhead
%                 display(framenum);
                if action==1 %take the action
                    pressspace();
                end
%                 if framenum<7
%                     pressspace();
%                 end
                
                % count the actions required to reach the goal
                countActions = countActions + 1; % quantization the next state
                if distancey>=30
                    status=1;
                elseif distancey>=25
                    status=2;
                elseif distancey>=20
                    status=3;
                elseif distancey>=15
                    status=4;
                elseif distancey>=10
                    status=5;
                elseif distancey>=5
                    status=6;
                elseif distancey>=2
                    status=7;
                elseif distancey>=-2
                    status=8;
                elseif distancey>=-5
                    status=9;
                elseif distancey>=-10
                    status=10;
                elseif distancey>=-15
                    status=11;
                elseif distancey>=-20
                    status=12;
                elseif distancey>=-25
                    status=13;
                elseif distancey<=-25
                    status=14;
                end
                % Get the reward values i.e. if final state then max reward
                % if bump into a wall then -1 is the reward for that action
                % other wise the reward value is 0

                if framenum<2 %when frame=1, take the first action
                    status1=status;
                    action=round(rand()+1);
                    rewardVal = 0;
                    action1=action;
                elseif framenum<8%when frame=1+6=7, take the second action
                    status2=status;
                    action=round(rand()+1);
                    rewardVal = 0;
                    action2=action;
                else
                    action3=action;
                    status3=status;
                    if abs(status3-7)>abs(status1-7) %compare the third state with the first state, if move further, negative reward
%                         &&abs(status(1,2))>2
                    rewardVal = -1;
                    elseif abs(status3-7)<abs(status1-7)%compare the third state with the first state, if move closer, positive reward
                    rewardVal = 1;
                    else
                    rewardVal = 0;
                    end
                    if status3==1 && action1==2 % special case, if bird still flys when it reaches the roof, negative reward
                        rewardVal = -1;
                    elseif status3==14 && action1==1% special case, if bird doesnt fly when it reaches the ground, negative reward
                        rewardVal = -1;
                    end
%                     if abs(status2-4)>abs(status1-4)
%                         rewardVal = rewardVal-0.2;
%                     elseif abs(status2-4)<abs(status1-4)
%                         rewardVal = rewardVal+0.2;
%                     end
                    status1=status2; %iteratively update states
                    status2=status3;
                end
                
                
                % enable this piece of code if testing larger maze
                %         if visitFlag(row,col) == 0
                %             rewardVal = rewardVal + 0.2;
                %             visitFlag(row,col) = 1;
                %         else
                %             rewardVal = rewardVal - 0.2;
                %         end
                
                % update information for robot in Q for later use
                if framenum>7 && learnresult==1 %update Q matrix from the third action
                fprintf('dis=%d, rewardVal=%d, prvrow=%d, birdpo=%d, prvcol=%d, action=%d\n',distancey,rewardVal,prvRow,Bird.ScreenPos(2),prvCol,action1);
                Q(prvRow,prvCol,action1) = Q(prvRow,prvCol,action1) + alpha*(rewardVal+gamma*max(Q(prvRow,prvCol,:)) - Q(prvRow,prvCol,action1));
                Qall(:,Qloop,:)=Q(:,prvCol,:); %record updating
                Qloop=Qloop+1;
%                 open(v2)
%                 writeVideo(v2,plot(1:Qloop,Qall(:,1:Qloop,1)));
%                 open(v3)
%                 writeVideo(v3,plot(1:Qloop,Qall(:,1:Qloop,2)));
                end
                if framenum>1 %update actions
                    action1=action2;
                    if framenum>7
                    action2=action3;
                    end
                end
            end
        end
        end
        %%
        addScore;
        Bird.CurFrame = 3 - floor(double(mod(CurrentFrameNo, 9))/3);

      %% Cycling the Palette
        % Update the cycle variables
       collide = isCollide();
       if collide
           gameover = true;
       end
       CurrentFrameNo = CurrentFrameNo + 1;
       loops = loops + 1;
       frame_updated = true;
       
       % If the bird has fallen to the ground
       if Bird.ScreenPos(2) >= 200-5
            Bird.ScreenPos(2) = 200-5;
            gameover = true;
            if abs(Bird.Angle - pi/2) < 1e-3
                fall_to_bottom = true;
                FlyKeyStatus = false;
            end
       end

    end

    %% Redraw the frame if the world has been processed
    if frame_updated       
        framenum=framenum+1;
        data(framenum,1)=distancex;
        data(framenum,2)=distancey;
%         drawToMainCanvas();
        set(MainCanvasHdl, 'CData', MainCanvas(1:200,:,:));
%         Bird.Angle = double(mod(CurrentFrameNo,360))*pi/180;
        if fall_to_bottom
            Bird.CurFrame = 2;
        end
        refreshBird();
        refreshTubes();
        if (~gameover)
            refreshFloor(CurrentFrameNo);
        end
        curScoreString = sprintf('%d',(Score));
        set(ScoreInfoForeHdl, 'String', curScoreString);
        set(ScoreInfoBackHdl, 'String', curScoreString);
        drawnow;
        frame_updated = false;
        c = toc(stageStartTime);
%         display(c);
        if ShowFPS
            total_frame_update = total_frame_update + 1;
            varname = 'collide';%'Mario.curFrame';
            if mod(total_frame_update,SHOWFPS_FRAMES) == 0 % If time to update fps
                set(fps_text_handle, 'String',sprintf('FPS: %.2f',SHOWFPS_FRAMES./(c-FPS_lastTime)));
                FPS_lastTime = toc(stageStartTime);
            end
            set(var_text_handle, 'String', sprintf('%s = %.2f', varname, eval(varname)));
        end
        set(IterationHdl, 'String', sprintf('Iteration: %d', iteration));
        if learnresult==1
            F=getframe;
            open(v1)
            writeVideo(v1,F); %write the video
        end
    end
    if fall_to_bottom
        if Score > Best
            Best = Score;
            
            for i_save = 1:4     % Try saving four times if error occurs
                try
                    save data\sprites2.mat Best -append
                    save data\Bestflappybird.mat Best
                    break;
                catch
                    continue;
                end
            end     % If the error still persist even after four saves, then
            if i_save == 4
                disp('FLAPPY_BIRD: Can''t save high score'); 
            end
        end
        score_report = {sprintf('Score: %d', Score), sprintf('Best: %d', Best)};
        set(ScoreInfoHdl, 'Visible','on', 'String', score_report);
        set(IterationHdl, 'Visible','on', 'String', iteration);
        set(GameOverHdl, 'Visible','on');
        save data\sprites2.mat Best -append
        save data\Bestflappybird.mat Best
%         save('data.mat','data' );
        if FlyKeyStatus
            FlyKeyStatus = false;
            break;
        end
%         for ii=(framenum-5):framenum
%             if data(ii,4)==1
%                 data(ii,4)=0;
%             else
%                 data(ii,4)=1;
%             end
%         end

        if learnresult==1 %training
            save('data\Qflappybird.mat','Q' );
            save('data\Qallflappybird.mat','Qall' );
        end
%         display(Q);
        pause(1)
        pressspace();  
    end


    if CloseReq
        if learnresult==1 %training
        save('data\Qflappybird.mat','Q' );
        save('data\Qallflappybird.mat','Qall' );
        end
%         figure,plot(1:Qloop,Qall(:,1:Qloop,1))
        delete(MainFigureHdl);
        clear all;
        return;
    end
end
iteration=iteration+1;
    if  iteration>iterationmax %stop to play automatically when preset iteration is reached
%         gameover = true;
        if learnresult==1 %training
            save('data\Qflappybird.mat','Q' );
            save('data\Qallflappybird.mat','Qall' );
        end
%         figure,plot(1:Qloop,Qall(:,1:Qloop,1))
        delete(MainFigureHdl);
        clear all;
        return
    end

end
    function initVariables()
        Sprites = load('data\sprites2.mat');
        GAME.MAX_FRAME_SKIP = 5;
        GAME.RESOLUTION = [256 144];
        GAME.WINDOW_RES = [256 144];
        GAME.FLOOR_HEIGHT = 56;
        GAME.FLOOR_TOP_Y = GAME.RESOLUTION(1) - GAME.FLOOR_HEIGHT + 1;
        GAME.N_UPDATE_PERSEC = 60;
        GAME.FRAME_DURATION = 1/GAME.N_UPDATE_PERSEC;
        
        TUBE.H_SPACE = 80;           % Horizontal spacing between two tubs
        TUBE.V_SPACE = 48;           % Vertical spacing between two tubs
        TUBE.WIDTH   = 24;            % The 'actual' width of the detection box
        TUBE.MIN_HEIGHT = 40;
        
        TUBE.SUM_HEIGHT = GAME.RESOLUTION(1)-TUBE.V_SPACE-...
            GAME.FLOOR_HEIGHT;
        TUBE.RANGE_HEIGHT = TUBE.SUM_HEIGHT -TUBE.MIN_HEIGHT*2;
        
        TUBE.PASS_POINT = [1 44];
        
        %TUBE.RANGE_HEIGHT_DOWN;      % Sorry you just don't have a choice
        GAMEPLAY.RIGHT_X_FIRST_TUBE = 300;  % Xcoord of the right edge of the 1st tube
        
        %% Handles
        MainFigureHdl = [];
        MainAxesHdl = [];
        
        %% Game Parameters
        MainFigureInitPos = [500 100];
        MainFigureSize = GAME.WINDOW_RES([2 1]).*2;
        MainAxesInitPos = [0 0]; %[0.1 0.1]; % The initial position of the axes IN the figure
        MainAxesSize = [144 200]; % GAME.WINDOW_RES([2 1]);
        FloorAxesSize = [144 56];
        %% Canvases:
        MainCanvas = uint8(zeros([GAME.RESOLUTION 3]));
                
        bird_size = Sprites.Bird.Size;
        [Bird.XGRID, Bird.YGRID] = meshgrid([-ceil(bird_size(2)/2):floor(bird_size(2)/2)], ...
            [ceil(bird_size(1)/2):-1:-floor(bird_size(1)/2)]);
        Bird.COLLIDE_MASK = false(12,12);
        [tempx tempy] = meshgrid(linspace(-1,1,12));
        Bird.COLLIDE_MASK = (tempx.^2 + tempy.^2) <= 1;
        
        
        Bird.OSCIL_RANGE = [128 4]; % [YPos, Amplitude]
        
        SinY = Bird.OSCIL_RANGE(1) + sin(linspace(0, 2*pi, SinYRange))* Bird.OSCIL_RANGE(2);
        SinYPos = 1;
        Best = 0;    % Best Score
    end

%% --- Graphics Section ---
    function initWindow()
        % initWindow - initialize the main window, axes and image objects
        MainFigureHdl = figure('Name', ['Flappy Bird ' GameVer], ...
            'NumberTitle' ,'off', ...
            'Units', 'pixels', ...
            'Position', [MainFigureInitPos, MainFigureSize], ...
            'MenuBar', 'figure', ...
            'Renderer', 'OpenGL',...
            'Color',[0 0 0], ...
            'KeyPressFcn', @stl_KeyPressFcn, ...
            'WindowKeyPressFcn', @stl_KeyDown,...
            'WindowKeyReleaseFcn', @stl_KeyUp,...
            'CloseRequestFcn', @stl_CloseReqFcn);
        FloorAxesHdl = axes('Parent', MainFigureHdl, ...
            'Units', 'normalized',...
            'Position', [MainAxesInitPos, (1-MainAxesInitPos.*2) .* [1 56/256]], ...
            'color', [1 1 1], ...
            'XLim', [0 MainAxesSize(1)]-0.5, ...
            'YLim', [0 56]-0.5, ...
            'YDir', 'reverse', ...
            'NextPlot', 'add', ...
            'Visible', 'on',...
            'XTick',[], 'YTick', []);
        MainAxesHdl = axes('Parent', MainFigureHdl, ...
            'Units', 'normalized',...
            'Position', [MainAxesInitPos + [0 (1-MainAxesInitPos(2).*2)*56/256], (1-MainAxesInitPos.*2).*[1 200/256]], ...
            'color', [1 1 1], ...
            'XLim', [0 MainAxesSize(1)]-0.5, ...
            'YLim', [0 MainAxesSize(2)]-0.5, ...
            'YDir', 'reverse', ...
            'NextPlot', 'add', ...
            'Visible', 'on', ...
            'XTick',[], ...
            'YTick',[]);
        
        
        MainCanvasHdl = image([0 MainAxesSize(1)-1], [0 MainAxesSize(2)-1], [],...
            'Parent', MainAxesHdl,...
            'Visible', 'on');
        TubeSpriteHdl = zeros(1,3);
        for i = 1:3
            TubeSpriteHdl(i) = image([0 26-1], [0 304-1], [],...
            'Parent', MainAxesHdl,...
            'Visible', 'on');
        end
        
        
        
        BirdSpriteHdl = surface(Bird.XGRID-100,Bird.YGRID-100, ...
            zeros(size(Bird.XGRID)), Sprites.Bird.CDataNan(:,:,:,1), ...
            'CDataMapping', 'direct',...
            'EdgeColor','none', ...
            'Visible','on', ...
            'Parent', MainAxesHdl);
        FloorSpriteHdl = image([0], [0],[],...
            'Parent', FloorAxesHdl, ...
            'Visible', 'on ');
        BeginInfoHdl = text(72, 100, 'Tap SPACE to begin', ...
            'FontName', 'Helvetica', 'FontSize', 20, 'HorizontalAlignment', 'center','Color',[.25 .25 .25], 'Visible','off');
        ScoreInfoBackHdl = text(72, 50, '0', ...
            'FontName', 'Helvetica', 'FontSize', 30, 'HorizontalAlignment', 'center','Color',[0,0,0], 'Visible','off');
        ScoreInfoForeHdl = text(70.5, 48.5, '0', ...
            'FontName', 'Helvetica', 'FontSize', 30, 'HorizontalAlignment', 'center', 'Color',[1 1 1], 'Visible','off');
        GameOverHdl = text(72, 70, 'GAME OVER', ...
            'FontName', 'Arial', 'FontSize', 20, 'HorizontalAlignment', 'center','Color',[1 0 0], 'Visible','off');
        
        ScoreInfoHdl = text(72, 110, 'Best', ...
            'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center','Color',[1 1 1], 'Visible', 'off');
        IterationHdl = text(110, 20, 'Iteration:0', ...
            'FontName', 'Helvetica', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color',[1 1 1], 'Visible','off');
    end
    function initGame()
                % The scroll layer for the tubes
        TubeLayer.Alpha = false([GAME.RESOLUTION.*[1 2] 3]);
        TubeLayer.CData = uint8(zeros([GAME.RESOLUTION.*[1 2] 3]));

        Bird.Angle = 0;
        Score = 0;
        %TubeLayer.Alpha(GAME.FLOOR_TOP_Y:GAME.RESOLUTION(1), :, :) = true;
        Flags.ResetFloorTexture = true;
        SinYPos = 1;
        Flags.PreGame = true;
%         scrollTubeLayer(GAME.RESOLUTION(2));   % Do it twice to fill the
%         disp('mhaha');
%         scrollTubeLayer(GAME.RESOLUTION(2));   % Entire tube layer
        drawToMainCanvas();
        set(MainCanvasHdl, 'CData', MainCanvas);
        set(BeginInfoHdl, 'Visible','on');
        set(ScoreInfoHdl, 'Visible','off');
        set(ScoreInfoBackHdl, 'Visible','off');
        set(ScoreInfoForeHdl, 'Visible','off');
        set(IterationHdl, 'Visible','on');
        set(GameOverHdl, 'Visible','off');
        set(FloorSpriteHdl, 'CData',Sprites.Floor.CData);
        Tubes.FrontP = 1;              % 1-3
        Tubes.ScreenX = [300 380 460]-2; % The middle of each tube
        Tubes.VOffset = ceil(rand(1,3)*105);
        refreshTubes;
        for i = 1:3
            set(TubeSpriteHdl(i),'CData',Sprites.TubGap.CData,...
                'AlphaData',Sprites.TubGap.Alpha);
            redrawTube(i);
        end
        if ShowFPS
            set(fps_text_handle, 'Visible', 'on');
            set(var_text_handle, 'Visible', 'on'); % Display a variable
        end
    end
%% Game Logic
    function processBird()
        Bird.ScreenPos(2) = Bird.ScreenPos(2) + Bird.SpeedY;
%         if Bird.ScreenPos(2)<0
%             Bird.ScreenPos(2)=0;
%         end
        Bird.SpeedY = Bird.SpeedY + GAME.GRAVITY;
        if Bird.SpeedY < 0
            Bird.Angle = max(Bird.Angle - pi/10, -pi/10);
        else
            if Bird.ScreenPos(2) < Bird.LastHeight
                Bird.Angle = -pi/10; %min(Bird.Angle + pi/100, pi/2);
            else
                Bird.Angle = min(Bird.Angle + pi/30, pi/2);
            end
        end
    end
    function processCPUBird() % Process the bird when the game is not started
        Bird.ScreenPos(2) = SinY(SinYPos);
        SinYPos = mod(SinYPos, SinYRange)+1;
    end
    function drawToMainCanvas()
        % Draw the scrolls and sprites to the main canvas
        
        % Redraw the background
        MainCanvas = Sprites.Bkg.CData(:,:,:,InGameParams.CurrentBkg);
        
        TubeFirstCData = TubeLayer.CData(:, 1:GAME.RESOLUTION(2), :);
        TubeFirstAlpha = TubeLayer.Alpha(:, 1:GAME.RESOLUTION(2), :);
        % Plot the first half of TubeLayer
        MainCanvas(TubeFirstAlpha) = ...
            TubeFirstCData (TubeFirstAlpha);
    end
    function [distancex,distancey]=scrollTubes(offset)
        Tubes.ScreenX = Tubes.ScreenX - offset;
        if Tubes.ScreenX(Tubes.FrontP) <=-26
            Tubes.ScreenX(Tubes.FrontP) = Tubes.ScreenX(Tubes.FrontP) + 240;
            Tubes.VOffset(Tubes.FrontP) = ceil(rand*55);
            redrawTube(Tubes.FrontP);
            Tubes.FrontP = mod((Tubes.FrontP),3)+1;
            Flags.NextTubeReady = true;
        end
        Tubes.FrontP1=Tubes.FrontP;
        if Tubes.ScreenX(Tubes.FrontP)-20 <=0
            Tubes.FrontP1 = mod((Tubes.FrontP),3)+1;
        end

            tubex=Tubes.ScreenX(Tubes.FrontP1)+13; %obtain x-distance and y-distance
            tubey=Tubes.VOffset(Tubes.FrontP1)-20;
            GapY = [128 177] - (Tubes.VOffset(Tubes.FrontP1)-1);
            distancex=tubex-Bird.ScreenPos(1); 
            distancey=Bird.ScreenPos(2)-(GapY(1)+GapY(2))/2;
%             display(Bird.ScreenPos(2));
%             display(Bird.ScreenPos(2)-(GapY(1)+GapY(2))/2);
    end

    function refreshTubes()
        % Refreshing Scheme 1: draw the entire tubes but only shows a part
        % of each
        for i = 1:3
            set(TubeSpriteHdl(i), 'XData', Tubes.ScreenX(i) + [0 26-1]);
        end
    end
    
    function refreshFloor(frameNo)
        offset = mod(frameNo, 24);
        set(FloorSpriteHdl, 'XData', -offset);
    end

    function redrawTube(i)
        set(TubeSpriteHdl(i), 'YData', -(Tubes.VOffset(i)-1));
    end

%% --- Math Functions for handling Collision / Rotation etc. ---
    function collide_flag = isCollide()
        collide_flag = 0;
        if Bird.ScreenPos(1) >= Tubes.ScreenX(Tubes.FrontP)-5 && ...
                Bird.ScreenPos(1) <= Tubes.ScreenX(Tubes.FrontP)+6+25
            
        else
            return;
        end
        
        GapY = [128 177] - (Tubes.VOffset(Tubes.FrontP)-1);    % The upper and lower bound of the GAP, 0-based
        
        if Bird.ScreenPos(2) < GapY(1)+4 || Bird.ScreenPos(2) > GapY(2)-4
            collide_flag = 1;
        end
        return;
    end
    
    function addScore()
        if Tubes.ScreenX(Tubes.FrontP) < 40 && Flags.NextTubeReady
            Flags.NextTubeReady = false;
            Score = Score + 1;
%             display(tubex-Bird.ScreenPos(1));
%             display(tubey-Bird.ScreenPos(2));
        end
    end

    function refreshBird()
        % move bird to pos [X Y],
        % and rotate the bird surface by X degrees, anticlockwise = +
        cosa = cos(Bird.Angle);
        sina = sin(Bird.Angle);
        xrotgrid = cosa .* Bird.XGRID + sina .* Bird.YGRID;
        yrotgrid = sina .* Bird.XGRID - cosa .* Bird.YGRID;
        xtransgrid = xrotgrid + Bird.ScreenPos(1)-0.5;
        ytransgrid = yrotgrid + Bird.ScreenPos(2)-0.5;
        set(BirdSpriteHdl, 'XData', xtransgrid, ...
            'YData', ytransgrid, ...
            'CData', Sprites.Bird.CDataNan(:,:,:, Bird.CurFrame));
    end
%% -- Display Infos --
    
        
%% -- Callbacks --
    function stl_KeyUp(hObject, eventdata, handles)
        key = get(hObject,'CurrentKey');
        % Remark the released keys as valid
        FlyKeyValid = FlyKeyValid | strcmp(key, FlyKeyNames);
    end
    function stl_KeyDown(hObject, eventdata, handles)
        key = get(hObject,'CurrentKey');
        
        % Has to be both 'pressed' and 'valid';
        % Two key presses at the same time will be counted as 1 key press
        down_keys = strcmp(key, FlyKeyNames);
        FlyKeyStatus = any(FlyKeyValid & down_keys);
        FlyKeyValid = FlyKeyValid & (~down_keys);
        data(framenum,3)=1;
        data(framenum,4)=1;
    end
    function stl_KeyPressFcn(hObject, eventdata, handles)
        curKey = get(hObject, 'CurrentKey');
        switch true
            case strcmp(curKey, 'escape') 
                CloseReq = true;            
        end
    end
    function stl_CloseReqFcn(hObject, eventdata, handles)
        CloseReq = true;
    end

%%key press
    function pressspace
        import java.awt.*;
        import java.awt.event.*;
        rob=Robot;
        rob.keyPress(KeyEvent.VK_W);
        FlyKeyStatus=1;
        FlyKeyValid=true(1);
    end
    function resetkeystatus
        FlyKeyStatus=0;
        FlyKeyValid=0;
    end
end
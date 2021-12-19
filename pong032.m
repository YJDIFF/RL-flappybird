%+-------------------------------------------------------+%
%|                DAVE'S MATLAB PONG v0.3                |%
%|                  by David Buckingham                  |%
%|                                                       |%
%| a fast-paced two-player game inspired by Atari's Pong |%
%+-------------------------------------------------------+%

%v0.3
%fixed bug where ball bouncing off right or left wall caused goal.
%paddle height reduced.
%ball acceleration reduced.
%changed colors and aesthetics.
%increased winning score to 5.
%main figure is wider and less tall. no change to plot dimensions.

%v0.2
%fixed bug where ball gets 'stuck' along top or bottom wall.

function [] = pong032(alpha,gamma,iterationmax,learnresult)

% close all
% clear all
% clc

%----------------------CONSTANTS----------------------
%game settings
MAX_POINTS = 50;
START_DELAY = 1;

%movemment
FRAME_DELAY = .01; %animation frame duration in seconds, .01 is good.
MIN_BALL_SPEED = 1.5; %each round ball starts at this speed
MAX_BALL_SPEED = 3; %wont accelerate bast this, dont set too high or bugs.
BALL_ACCELERATION = 0.05; %how much ball accelerates each bounce.
PADDLE_SPEED = 2.0;
%B_FACTOR and P_FACTOR increase the ball's dx/dy, i.e. making it move
%more horizontaly and less vertically. When the ball bounces, B_FACTOR
%is used to calculate a random variance in the resulting ball vector.
%Lower values increases dx/dy. 1 seems to work well for B_FACTOR. When the
%ball hits a paddle, its new vector is the line connecting the center of
%the paddle to the center of the ball. x value of this vector is multiplied
%P_FACTOR. Higher P_FACTOR increases the ball's dx/dy after hitting
%a paddle. 2 seems to work well for P_FACTOR.
B_FACTOR = 1;
P_FACTOR = 2;
%Y_FACTOR is used to fix a bug where ball would get 'stuck' bouncing
%back and forth along the top or bottom wall. A collision with top or
%bottom wall causes a bounce where new dx is -(old dx). If old dx is 0 then
%new dx is 0 so ball never leaves wall. Y_FACTOR is added to dx when
%ball bounces off top or bottom wall. It should be small. 0.01 works well.
Y_FACTOR = 0.01;
%GOAL_BUFFER is distance beyond end of plot ball must travel to score a
%goal. if this is 0 or too small, goals can be scored by fast ball bouncing
%off right or left wall. Too high and angled goals will bounce back in
GOAL_BUFFER = 20;

%layout/structure
BALL_RADIUS = 1.5; %radius to calculate bouncing
WALL_WIDTH = 3;
FIGURE_WIDTH = 800; %pixels
FIGURE_HEIGHT = 480;
PLOT_W = 150; %width in plot units. this will be main units for program
PLOT_H = 100; %height
GOAL_SIZE = 50;
GOAL_TOP = (PLOT_H+GOAL_SIZE);
GOAL_BOT = (PLOT_H-GOAL_SIZE)/1000;
PADDLE_H = 18; %height
PADDLE_W = 3; %width
PADDLE = [0 PADDLE_W PADDLE_W 0 0; PADDLE_H PADDLE_H 0 0 PADDLE_H];
PADDLE_SPACE = 10; %space between paddle and goal

%appearance
FIGURE_COLOR = [0, 0, 0]; %program background
AXIS_COLOR = [.15, .15, .15]; %the court
CENTER_RADIUS = 15; %radius of circle in center of court.
BALL_MARKER_SIZE = 10; %aesthetic, does not affect physics, see BALL_RADIUS
BALL_COLOR = [.1, .7, .1];
BALL_OUTLINE = [.7, 1, .7];
BALL_SHAPE = 'o';
PADDLE_LINE_WIDTH = 2;
WALL_COLOR = [.3, .3, .8]; %format string for drawing walls
PADDLE_COLOR = [1, .5, 0];
CENTERLINE_COLOR = PADDLE_COLOR .* .8; %format string for centerline
PAUSE_BACKGROUND_COLOR = FIGURE_COLOR;
PAUSE_TEXT_COLOR = [.9, .9, .9];
PAUSE_EDGE_COLOR = BALL_COLOR;
TITLE_COLOR = 'w';

%messages
PAUSE_WIDTH = 36; %min pause message width, DO NOT MODIFY, KEEP AT 36
MESSAGE_X = 38; %location of message displays. 38, 55 is pretty centered
MESSAGE_Y = 55;
MESSAGE_PAUSED = ['             GAME PAUSED' 10 10];
MESSAGE_INTRO = [...
  '             welcome to ' 10 10 ...
  '         DAVE' 39 'S MATLAB PONG' 10 10 ...
  '     first to get ' num2str(MAX_POINTS) ' points wins!' 10 10 ...
  '    player 1:           player 2:' 10 ...
  ' use (a) and (z)     use arrow keys' 10 10 ...
  ];
MESSAGE_CONTROLS = '  pause:(p)   reset:(r)   quit:(q)';
IterationHdl = [];
TimeHdl = [];
%----------------------VARIABLES----------------------
fig = []; %main program figure
quitGame = false; %guard for main loop. when true, program ends
paused = []; %true if game is paused
score = []; %1x2 vector holding player scores
winner = []; %normally 0. 1 if player1 wins, 2 if player2 wins
ballPlot = []; %main plot, includes ball and walls
paddle1Plot = []; %plot for paddle
paddle2Plot = [];
ballVector=[]; %normalized vector for ball movement
ballSpeed=[];
ballX = []; %ball location
ballY = [];
paddle1V = []; %holds either 0, -1, or 1 for paddle movement
paddle2V = [];
paddle1 = []; %2x5 matrix describing paddle, based on PADDLE
paddle2 = [];
paddle1V=1;

global Best
global Q
global Qloop
global Qall
if learnresult==1 %training, initial Q matrix
Qloop=1;
Q=zeros(6,40,2,2);
Qall = zeros(6,40,2,2,1);
elseif learnresult==2 %replay, load Q matrix
Qloop=1;
load('data\Qpingpong.mat','Q');
Qall = zeros(6,40,2,2,1);
end
% load('Q.mat');

% alpha = 0.3;
% gamma = 0.2;
v1 = VideoWriter('video\PingpongVideo.mp4','MPEG-4'); %initial video file
iteration=1; % iteration count
actioncount=0;
Best=0; % Best score of single play
%-----------------------SUBROUTINES----------------------

%------------createFigure------------
%sets up main program figure
%plots ball, walls, paddles
%called once at start of program
  function createFigure
    %ScreenSize is a four-element vector: [left, bottom, width, height]:
    scrsz = get(0,'ScreenSize');
    fig = figure('Position',[(scrsz(3)-FIGURE_WIDTH)/2 ...
      (scrsz(4)-FIGURE_HEIGHT)/2 ...
      FIGURE_WIDTH, FIGURE_HEIGHT]);
    %register keydown and keyup listeners
    set(fig,'KeyPressFcn',@keyDown, 'KeyReleaseFcn', @keyUp);
    %figure can't be resized
    set(fig, 'Resize', 'off');
    axis([0 PLOT_W 0 PLOT_H]);
    axis manual;
    %set color for the court, hide axis ticks.
    set(gca, 'color', AXIS_COLOR, 'YTick', [], 'XTick', []);
    %set background color for figure
    set(fig, 'color', FIGURE_COLOR);
    hold on;
    %plot walls
    topWallXs = [0,0,PLOT_W,PLOT_W];
    topWallYs = [GOAL_TOP,PLOT_H,PLOT_H,GOAL_TOP];
    bottomWallXs = [0,0,PLOT_W,PLOT_W];
    bottomWallYs = [GOAL_BOT,0,0,GOAL_BOT];
    plot(topWallXs, topWallYs, '-', ...
      'LineWidth', WALL_WIDTH, 'Color', WALL_COLOR);
    plot(bottomWallXs, bottomWallYs, '-', ...
      'LineWidth', WALL_WIDTH, 'Color', WALL_COLOR);
    %calculate circle to draw on court
    thetas = linspace(0, (2*pi), 100);
    circleXs = (CENTER_RADIUS .* cos(thetas)) + (PLOT_W / 2);
    circleYs = (CENTER_RADIUS .* sin(thetas))+ (PLOT_H / 2);
    %draw lines on court
    centerline = plot([PLOT_W/2, PLOT_W/2],[PLOT_H, 0],'--');
    set(centerline, 'Color', CENTERLINE_COLOR);
    centerCircle = plot(circleXs, circleYs,'--');
    set(centerCircle, 'Color', CENTERLINE_COLOR);

    %plot ball, we'll set ball location in refreshPlot
    ballPlot = plot(0,0);
    set(ballPlot, 'Marker', BALL_SHAPE);
    set(ballPlot, 'MarkerEdgeColor', BALL_OUTLINE);
    set(ballPlot, 'MarkerFaceColor', BALL_COLOR);
    set(ballPlot, 'MarkerSize', BALL_MARKER_SIZE);
    %plot paddles, we'll set paddle locations in refreshPlot
    paddle1Plot = plot(0,0, '-', 'LineWidth', PADDLE_LINE_WIDTH);
    paddle2Plot = plot(0,0, '-', 'LineWidth', PADDLE_LINE_WIDTH);
    set(paddle1Plot, 'Color', PADDLE_COLOR);
    set(paddle2Plot, 'Color', PADDLE_COLOR);
    
    IterationHdl = text(150, 0, 'Iteration:1', ...
            'FontName', 'Helvetica', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color',[1 1 1], 'Visible','on');
    TimeHdl = text(150, 10, 'Hold time:1', ...
            'FontName', 'Helvetica', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color',[1 0 1], 'Visible','on');

  end

%------------newGame------------
%resets game to starting conditions.
%called from main loop at program start
%called from keydown when user hits 'r'
%called from checkGoal after someone wins
%sets some variables, calls reset game,
%and calls pauseGame with intro message
  function newGame
    winner = 0;
    score = [0, 0];
    paddle1V = 1; %velocity
    paddle2V = 0; %velocity
    paddle1 = [PADDLE(1,:)+PADDLE_SPACE; ...
      PADDLE(2,:)+((PLOT_H - PADDLE_H)/2)];
    paddle2 = [PADDLE(1,:)+ PLOT_W - PADDLE_SPACE - PADDLE_W; ...
      PADDLE(2,:)+((PLOT_H - PADDLE_H)/2)];
    resetGame;
    if ~quitGame; %incase we try to quit from winner message
%       pauseGame([MESSAGE_INTRO, MESSAGE_CONTROLS]);
    end
  end

%------------resetGame------------
%resets ball location speed and direction
%resets title string to display scores
%called from newGame
%called from checkGoal after each goal
  function resetGame
    bounce([1-(2*rand), 1-(2*rand)]);
    ballSpeed=MIN_BALL_SPEED;
     ballX = PLOT_W/2;
     ballY = PLOT_H/2;
    %here 19 is the space between the scores
    titleStr = sprintf('%d / %d%19d / %d', ...
      score(1), MAX_POINTS, score(2), MAX_POINTS);
    t = title(titleStr, 'Color', TITLE_COLOR);
    set(t, 'FontName', 'Courier','FontSize', 15, 'FontWeight', 'Bold');
    refreshPlot;
    frame=1;
    if ~quitGame; %make sure we don't wait to quit if use hit 'q'
      pause(START_DELAY);
    end
  end

%------------moveBall------------
%calculates new ball location
%checks if it will hit any walls or paddles
%if it does, call bounce to change ball vector
%move ball to new location
%called from main loop on every frame
  function moveBall
    
    %paddle boundaries, useful for hit testing ball
    p1T = paddle1(2,1);
    p1B = paddle1(2,3);
    p1L = paddle1(1,1);
    p1R = paddle1(1,2);
    p1Center = ([p1L p1B] + [p1R p1T]) ./ 2;
    p2T = paddle2(2,1);
    p2B = paddle2(2,3);
    p2L = paddle2(1,1);
    p2R = paddle2(1,2);
    p2Center = ([p2L p2B] + [p2R p2T]) ./ 2;
    
    %while hit %calculate new vectors until we know it wont hit something
    %temporary new ball location, only apply if ball doesn't hit anything.
    newX = ballX + (ballSpeed * ballVector(1));
    newY = ballY + (ballSpeed * ballVector(2));
    
    %hit test right wall
    if (newX > (PLOT_W - BALL_RADIUS) ...
        && (ballY<GOAL_BOT+BALL_RADIUS || newY>GOAL_TOP-BALL_RADIUS))
      %hit right wall
%       bounce([newX - PLOT_W, newY - GOAL_BOT]);
      if (newY > GOAL_BOT && newY < GOAL_TOP - BALL_RADIUS)
        %hit bottom goal edge
        bounce([newX - PLOT_W, newY - GOAL_BOT]);
      elseif (newY < GOAL_TOP && newY > GOAL_BOT + BALL_RADIUS)
        %hit top goal edge
        bounce([newX - PLOT_W, newY - GOAL_TOP]);
      else
        %hit flat part of right wall
        bounce([-1 * abs(ballVector(1)), ballVector(2)]);
      end
      
      %hit test left wall
    elseif (newX < BALL_RADIUS ...
        && (newY<GOAL_BOT+BALL_RADIUS || newY>GOAL_TOP-BALL_RADIUS))
      %hit left wall
%       bounce([newX, newY - GOAL_BOT]);
      if (newY > GOAL_BOT && newY < GOAL_TOP - BALL_RADIUS)
        %hit bottom goal edge
        bounce([newX, newY - GOAL_BOT]);
      elseif (newY < GOAL_TOP && newY > GOAL_BOT + BALL_RADIUS)
        %hit top goal edge
        bounce([newX, newY - GOAL_TOP]);
      else
        bounce([abs(ballVector(1)), ballVector(2)]);
      end
      
      %hit test top wall
    elseif (newY > (PLOT_H - BALL_RADIUS))
      %hit top wall
      bounce([ballVector(1), -1 * (Y_FACTOR + abs(ballVector(2)))]);
      %hit test bottom wall
    elseif (newY < BALL_RADIUS)
      %hit bottom wall,
      bounce([ballVector(1), (Y_FACTOR + abs(ballVector(2)))]);
      
      %hit test paddle 1
    elseif (newX < p1R + BALL_RADIUS ...
        && newX > p1L - BALL_RADIUS ...
        && newY < p1T + BALL_RADIUS ...
        && newY > p1B - BALL_RADIUS)
      bounce([(ballX-p1Center(1)) * P_FACTOR, newY-p1Center(2)]);
      
      %hit test paddle 2
    elseif (newX < p2R + BALL_RADIUS ...
        && newX > p2L - BALL_RADIUS ...
        && newY < p2T + BALL_RADIUS ...
        && newY > p2B - BALL_RADIUS)
      bounce([(ballX-p2Center(1)) * P_FACTOR, newY-p2Center(2)]);
    else
      %no hits
    end
    
    %move ball to new location
    ballX = newX;
    ballY = newY;

  end

%------------movePaddles------------
%uses paddle velocity set paddles
%called from main loop on every frame
%% Q learning 
  function movePaddles
      paddle2midy=(paddle2(2,1)+paddle2(2,3))/2; % the midpoint of paddle2
      if frame==1 % at frame 1, initial score_present and Y_present
          score_preset=score(2)-score(1);
          Y_preset=abs(ballY-paddle2midy);
      end
      if mod(round(ballX),1)==0 &&ballX>20 &&ballSpeed * ballVector(1)>0 % move pad when ball x position is integer & ball x is coming to the pad
          status_x = ceil(ballX-paddle2midy); prvCol = ceil((ballY-paddle2midy)/5)+20; % quantization x-distance and y-distance
          if status_x<-50
              prvRow=1;
          elseif status_x<-20
              prvRow=2;
          elseif status_x<-10
              prvRow=3;
          elseif status_x<-5
              prvRow=4;
          elseif status_x<0
              prvRow=5;
          else
              prvRow=6;
          end
          Ballspeedx=round(ballSpeed * ballVector(1)*10); %quantization ball x-speed and y-speed
          Ballspeedy=abs(round(ballSpeed * ballVector(2)*10));
          if ballSpeed * ballVector(2)<0 %fit ball y-speed into Q matrix
              prvballspeedy=1;
          else
              prvballspeedy=2;
          end
%           display(Ballspeedx);
%           display(Ballspeedy);

          if prvRow~=0&&prvCol~=0&&Ballspeedx~=0&&Ballspeedy~=0 % when all value exist
              [val,index] = max(Q(prvRow,prvCol,prvballspeedy,:)); % find the largest value under current state
              [xx,yy] = find(Q(prvRow,prvCol,prvballspeedy,:) == val); 
              if size(yy,1) > 1
                  index = 1+round(rand*(size(yy,1)-1));
                  action = yy(index,1);
              else
                  action = index;
              end
              if action==1 % take the action
                  keyuparrow();
              else
                  keydownarrow();
              end
              actioncount=actioncount+1;
              if actioncount==1
                  action1=action;
              end
display(actioncount);
              if abs(ballY-paddle2midy)>Y_preset %define reward, if pad move further from the ball, negative reward
                  rewardVal = -1;
              elseif score(2)-score(1)>score_preset%no reward if pad wins
                  rewardVal = 0;
              elseif abs(ballY-paddle2midy)<Y_preset%if pad move closer to the ball, positive reward
                  rewardVal = 1;
              else   %no reward for others
                  rewardVal = 0;
              end
              display( abs(ballY-paddle2midy)-Y_preset);
              display(rewardVal);
              Q(prvRow,prvCol,prvballspeedy,action1) = Q(prvRow,prvCol,prvballspeedy,action1) + alpha*(rewardVal+gamma*max(Q(prvRow,prvCol,prvballspeedy,:)) - Q(prvRow,prvCol,prvballspeedy,action1)); %update Q matrix
              Qall(:,:,:,:,Qloop)=Q(:,:,:,:); %record the updating
              Qloop=Qloop+1;
              save('data\Qpingpong.mat','Q' ); %save the updating
              save('data\Qallpingpong.mat','Qall' );
              action1=action;
              score_preset=score(2)-score(1);%record the current state to determine the reward of next action
              Y_preset=abs(ballY-paddle2midy);

          elseif Ballspeedy==0 % special case, ball y-speed=0. Allow the pad to move without Q matrix
              if (paddle2(2,1)+paddle2(2,3))/2>ballY
                  paddle2V=-1;
              else
                  paddle2V=1;
              end
              if (paddle2(2,1)+paddle2(2,3))/2==ballY
                  paddle2V=0;
              end
          end
      end
    if (paddle1(2,1)+paddle1(2,3))/2>ballY % move paddle1 automatically following the ball
        paddle1V=-1;
    else
        paddle1V=1;
    end
    if (paddle1(2,1)+paddle1(2,3))/2==ballY
        paddle1V=0;
    end
%%
    %set new paddle y locations
    paddle1(2,:) = paddle1(2,:) + (PADDLE_SPEED * paddle1V);
    paddle2(2,:) = paddle2(2,:) + (PADDLE_SPEED * paddle2V);
    %if paddle out of bounds, move it in bounds
    if paddle1(2,1) > PLOT_H
      paddle1(2,:) = PADDLE(2,:) + PLOT_H - PADDLE_H;
      paddle1V=-1;
    elseif paddle1(2,3) < 0
      paddle1(2,:) = PADDLE(2,:);
      paddle1V=1;
    end
    if paddle2(2,1) > PLOT_H
      paddle2(2,:) = PADDLE(2,:) + PLOT_H - PADDLE_H;
    elseif paddle2(2,3) < 0
      paddle2(2,:) = PADDLE(2,:);
    end
  end

%------------refreshPlot------------
%sets data in plots
%calls matlab's drawnow to refresh plots
%uses matlab pause to create animation frame
%called from main loop on every frame
  function refreshPlot
    set(ballPlot, 'XData', ballX, 'YData', ballY);
    set(paddle1Plot, 'Xdata', paddle1(1,:), 'YData', paddle1(2,:));
    set(paddle2Plot, 'Xdata', paddle2(1,:), 'YData', paddle2(2,:));
    set(IterationHdl, 'Visible','on','String', sprintf('Iteration: %d', iteration));
    set(TimeHdl, 'Visible','on','String', sprintf('Hold time: %d', frame));
    drawnow;
    pause(FRAME_DELAY);
      F= getframe(gcf); %get frame and write the video
  open(v1)
  writeVideo(v1,F);
  end

%------------checkGoal------------
%check ballX to see if ball passed through goal
%update score and see if anybody won
%call resetGame to reset ball location etc.
%if somebody won, then
%call pauseGame to display message, call newGame
%called from main loop on every frame
  function checkGoal
    goal = false;
    
    if ballX > PLOT_W + BALL_RADIUS + GOAL_BUFFER
      score(1) = score(1) + 1;
      iteration=iteration+1;
      if score(1) == MAX_POINTS
        winner = 1;
      end
      goal = true;
    elseif ballX < 0 - BALL_RADIUS - GOAL_BUFFER
      score(2) = score(2) + 1;
      iteration=iteration+1;
      if score(2) == MAX_POINTS
        winner = 2;
      end
      goal = true;
    end
    
    if goal %a goal was made
      pause(START_DELAY);
      resetGame;
      if winner > 0 %somebody won
%         pauseGame(['      PLAYER ' num2str(winner) ' IS THE WINNER!!!' 10])
        newGame;
      else %nobody won
      end
    end

%     set(IterationHdl, 'Visible','on', 'String', iteration);
  end

%------------pauseGame------------
%%sets paused variable to true
%starts a while loop guarded by pause variable
%displays provided string message
%called from newGame at game start
%called from keyDown when user hits 'p'
%called from checkGoal when someone scores
  function pauseGame(input)
    paused = true;
    str = '      hit any key to continue...';
    spacer = 1:PAUSE_WIDTH;
    spacer(:) = uint8(' ');
    while paused
      printText = [spacer 10 input 10 str 10];
      h = text(MESSAGE_X,MESSAGE_Y,printText);
      set(h, 'BackgroundColor', PAUSE_BACKGROUND_COLOR)
      set(h, 'Color', PAUSE_TEXT_COLOR)
      set(h,'EdgeColor',PAUSE_EDGE_COLOR);
      set(h, 'FontSize',5,'FontName','Courier','LineStyle','-','LineWidth',1);
      pause(FRAME_DELAY)
      delete(h);
    end
  end

%------------unpauseGame------------
%sets paused to false
%called from keyDown when user hits any key
  function unpauseGame()
    paused = false;
  end

%------------bounce------------
%takes input vector as argument
%increases dx/dy for more horizontal movement
%normalizes vector sets as new ball vector
%accelerates ball
%called by moveBall whenever ball hits something
  function bounce (tempV)
    %increase dx by a random amount
    %helps keep the ball moving more horizontally than vertically.
    tempV(1) = tempV(1) * ((rand/B_FACTOR) + 1);
    %normalize vector
    tempV = tempV ./ (sqrt(tempV(1)^2 + tempV(2)^2));
    ballVector = tempV;
    %just to make things interesting, bouncing accelerates ball
    if (ballSpeed + BALL_ACCELERATION < MAX_BALL_SPEED)
      ballSpeed = ballSpeed + BALL_ACCELERATION;
    end
  end

%------------keyDown------------
%listener registered in createFigure
%listens for input
%sets appropriate variables and calls functions
  function keyDown(src,event)
    switch event.Key
%       case 'a'
%         paddle1V = 1;
%       case 'z'
%         paddle1V = -1;
      case 'i'
        paddle2V = 1;
      case 'k'
        paddle2V = -1;
      case 'p'
        if ~paused
          pauseGame([MESSAGE_PAUSED MESSAGE_CONTROLS]);
        end
      case 'r'
        newGame;
      case 'q'
        unpauseGame;
        quitGame = true;
    end
    unpauseGame;
  end

%------------keyUp------------
%listener registered in createFigure
%used to stop paddles on keyup
  function keyUp(src,event)
    switch event.Key
%       case 'a'
%         if paddle1V == 1
%           paddle1V = 0;
%         end
%       case 'z'
%         if paddle1V == -1
%           paddle1V = 0;
%         end
      case 'i'
%         if paddle2V == 1
          paddle2V = 0;
%         end
      case 'k'
%         if paddle2V == -1
          paddle2V = 0;
%         end
    end
  end

    function keyuparrow
        import java.awt.*;
        import java.awt.event.*;
        rob=Robot;
%         pause(0.1);
        rob.keyPress(KeyEvent.VK_I);
        
    end
    function keydownarrow
        import java.awt.*;
        import java.awt.event.*;
        rob=Robot;
%         pause(0.1);
        rob.keyPress(KeyEvent.VK_K);
        
    end

%----------------------MAIN SCRIPT----------------------
frame=1;
createFigure;
newGame;
score_preset=0;
action1=0;
Y_preset=abs(ballY-paddle2(2,3));
frame=1;
while ~quitGame

  moveBall;
  movePaddles;
  refreshPlot;
  checkGoal;
    if Best<frame %update score
        Best=frame;
    end
    save data\Bestpingpong.mat Best %save the best score
    frame=frame+1;
  if iteration>iterationmax %stop game if the preset iteration reached
      quitGame = true;
  end
end
close(fig);

end

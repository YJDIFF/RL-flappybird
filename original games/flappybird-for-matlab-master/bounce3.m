%|Bouncing ball game
%|A good example of animation and real-time user interaction
% University of Tennessee : EF 230 Fall, 2009 : Will Schleter
function bounce3
clear all; close all; clc;
format compact;
 
% use a global structure to store all values that need to be
% used in several different functions
global g;
 
get_settings();
init_figure();
create_ball();
 
tic; % start timer
while g.playing
    if g.moving==0, tic; drawnow; continue; end
    if g.moving==1, dt=toc; % get time since last bounce
    else, dt=.1; g.moving=0;
    end
    if dt<.05, continue; end % prevents updates of less than 1/20 of a second
    tic; % reset timer
    % new position and velocity
    g.cx=g.cx+g.vx*dt+.5*g.ax*dt*dt;
    g.cy=g.cy+g.vy*dt+.5*g.ay*dt*dt;
    g.cz=g.cz+g.vz*dt+.5*g.az*dt*dt;
    g.vx=round(g.vx+g.ax*dt);
    g.vy=round(g.vy+g.ay*dt);
    g.vz=round(g.vz+g.az*dt);
 
    % check for wall hits
    if (g.cx>g.xmax && g.vx>0) || (g.cx<0 && g.vx<0), g.vx=-g.cor*g.vx; beep; end
    if (g.cy>g.ymax && g.vy>0) || (g.cy<0 && g.vy<0), g.vy=-g.cor*g.vy; beep; end
    if (g.cz>g.zmax && g.vz>0) || (g.cz<0 && g.vz<0), g.vz=-g.cor*g.vz; beep; end
    update_graphics
end
close(1)
% msgbox('Thanks for playing')
 
return
 
function buttonpush(src,ed)
global g
dv=10;
if length(ed.Modifier)>0, dv=1; end  % shift, ctrl, alt all set dv=1
switch ed.Key
    case 'q'
        g.playing=0;
    case 'space'
        if g.moving, g.moving=0;
        else, g.moving=1;
        end
    case 'r'
        if length(ed.Modifier)>0
            g.cor=max(.1,g.cor-.01);
        else
            g.cor=min(1,g.cor+.01);
        end
    case 'z'
        if length(ed.Modifier)>0
            g.az=g.az-10;
        else
            g.az=g.az+10;
        end
    case 'y'
        if length(ed.Modifier)>0
            g.ay=g.ay-10;
        else
            g.ay=g.ay+10;
        end
    case 'x'
        if length(ed.Modifier)>0
            g.ax=g.ax-10;
        else
            g.ax=g.ax+10;
        end
    case 'tab'
        g.moving=2;
    case 'leftarrow'
        g.vx=g.vx-dv;
    case 'rightarrow'
        g.vx=g.vx+dv;
    case 'uparrow'
        g.vy=g.vy+dv;
    case 'downarrow'
        g.vy=g.vy-dv;
    case 'pageup'
        g.vz=g.vz+dv;
    case 'pagedown'
        g.vz=g.vz-dv;
    otherwise
        ed  % show key info
end
 
return
 
function get_settings
global g;
p={'X acceleration','Y acceleration','Z acceleration','Coef of restitution'};
t='Bouncing Ball Game';
d={'0','-100','0','1'};
a=inputdlg(p,t,1,d);
if length(a)==0, error('Cancelled'); end  % user pushed close or cancel
g.ax=str2double(a{1});
g.ay=str2double(a{2});
g.az=str2double(a{3});
g.cor=str2double(a{4});
 
% hardcoded values
g.playing=1;
g.moving=1;
g.xmax=100;
g.ymax=100;
g.zmax=100;
g.cx=g.xmax*rand(1);  % starting position
g.cy=g.ymax*rand(1);
g.cz=50;
g.vx=0;  % starting velocity
g.vy=0;
g.vz=0;
 
return
 
function create_ball
global g;
 
% create a 'ball'
r=7;
 
balltype='circle';
switch balltype
    case 'sphere'
        [g.bx,g.by,g.bz]=sphere;
        g.bx=g.bx*r;
        g.by=g.by*r;
        g.bz=g.bz*r;
        img=imread('amy1.jpg');
        g.ball=surf(g.bx,g.by,g.bz,'facecolor','texturemap','CData',img,'EdgeColor','none');
    case 'circle'
        t = linspace(0,2*pi,20);
        g.bx=r*cos(t);
        g.by=r*sin(t);
        [x y]=meshgrid(g.bx,g.by);
        g.bz=0.*x.*y;
        img=imread('amy1.jpg');
        g.ball=patch(g.bx,g.by,g.bz,'r');
        %g.ball=surf(g.bx,g.by,g.bz,'facecolor','texturemap','CData',img,'EdgeColor','none');
 
end
 
% trace (tail)
tlen=50;
g.trace.x=ones(1,tlen)*g.cx;
g.trace.y=ones(1,tlen)*g.cy;
g.trace.z=ones(1,tlen)*g.cz;
g.trace.h=plot3(g.trace.x,g.trace.y,g.trace.z,'b:');
 
% velocity vector
x=[g.cx g.cx];
y=[g.cy g.cy];
z=[g.cz g.cz];
g.velvec.h=plot3(x,y,z,'r-');
return
 
function init_figure
% set up figure window
global g;
figure(1);
hold on;
axis equal;
title('Bouncy Ball');
axis([0 g.xmax 0 g.ymax 0 g.zmax]);
axis off;
rectangle('Position',[0,0,g.xmax,g.ymax])
% set the function that gets called when a key is pressed
set(gcf,'WindowKeyPressFcn',@buttonpush);
view(3);
% instructions
text(102,90,{'Q: quit game',
    'space: pause/resume',
    'Tab: single step',
    'R: COR +.01',
    'sh-R: COR -.01',
    'X: Ax+10',
    'sh-X: Ax-10',
    'Y: Ay+10',
    'sh-Y: Ay-10',
    'Arrow keys:',
    ' "push" the ball'}, 'verticalalign','top' );
% status text
g.stattext_h=text(-30,90,'','verticalalign','top');
return
 
function update_graphics
global g;
 
% move ball to new position
 
set(g.ball,'XData',g.bx+g.cx);
set(g.ball,'YData',g.by+g.cy);
set(g.ball,'ZData',g.bz+g.cz);
 
% update status text
set(g.stattext_h,'String',...
    sprintf('Vx=%.0f\nAx=%.0f\n\nVy=%.0f\nAy=%.0f\n\nVz=%.0f\nAz=%.0f\n\nCOR=%.2f',...
            g.vx,g.ax,g.vy,g.ay,g.vz,g.az,g.cor));
 
% update trace
g.trace.x=[g.cx g.trace.x(1:end-1)];
g.trace.y=[g.cy g.trace.y(1:end-1)];
g.trace.z=[g.cz g.trace.z(1:end-1)];
set(g.trace.h,'XData',g.trace.x,'YData',g.trace.y,'ZData',g.trace.z);
 
% update velocity vector
x=[g.cx g.cx+g.vx/5];
y=[g.cy g.cy+g.vy/5];
z=[g.cz g.cz+g.vz/5];
set(g.velvec.h,'XData',x,'YData',y,'ZData',z);
 
% update display
drawnow
return

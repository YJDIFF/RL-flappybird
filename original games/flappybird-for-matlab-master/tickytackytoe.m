function tickytackytoe
global g
format compact;
play=1;
init_game();
while play
    get_players();
    init_stats();
    sameplayers=true;
    while sameplayers
        done = 0;
        init_board();
        while true
            showboard();
            if strcmp(g.pp(g.p).type,'H')
                %m=input('enter move: ')
                get_human_move();
            else
                get_computer_move();
            end
            done=checkboard();
            if done, break, end
            g.p=opp(g.p);
        end
        g.results(done)=g.results(done)+1;
        prompt = sprintf('Game #%d: ',sum(g.results)');
        if done<3
            prompt=sprintf('%s %s won!',prompt,g.pp(done).name);
        else
            prompt=sprintf('%s Tie.',prompt);
        end
        prompt=sprintf('%s\nWins for %s: %d\nWins for %s: %d\nTies: %d',prompt,g.pp(1).name,g.results(1),g.pp(2).name,g.results(2),g.results(3));
        g.numgames=g.numgames-1;
        if g.showgraph, fprintf('%s\n',prompt); end;
        if g.numgames==0
            but=questdlg(prompt,g.name,'Play again','Change Players','Quit','Play again');
            if strcmp(but,'Quit'), play=0; sameplayers=0; end
            if strcmp(but,'Change Players'), sameplayers=0; end
        end
    end
end
if gcf==1, close(1), end
 
function o=opp(p) % opponent player number
o=mod(p,2)+1;
return
 
function done=checkboard % checks if game is done
global g
 
showboard();
done=0;
if nnz(g.b)==9
    done=3; %tie
end
ways = [1 2 3
    4 5 6
    7 8 9
    1 4 7
    2 5 8
    3 6 9
    1 5 9
    3 5 7];
for i=1:8
    w=ways(i,:);
    r=g.b(w);
    if r(1)==0, continue, end
    if r(2)==r(1) && r(3)==r(1)
        done=r(1);
        showwin(xy(w(1)),xy(w(3)));
        return;
    end
end
return
 
function rc=xy(n) % converts number to row,column
r=mod(n-1,3)+1;
c=floor((n-1)/3)+1;
rc = [r c];
return
 
function showboard % displays current board
global g
%g.b %uncomment this to show board after each move
if ~g.showgraph, return, end;
figure(1);
clf(1)
gamenum=sum(g.results)+1;
txt=sprintf('Game #%d: %s''s move',gamenum,g.pp(g.p).name);
title(txt);
axis([0 4 0 4]);
axis equal;
axis off;
set(gca,'YDir','reverse')
hold on;
plot([1.5 1.5],[.5 3.5],'b-','linewidth',5)
plot([2.5 2.5],[.5 3.5],'b-','linewidth',5)
plot([.5 3.5],[1.5 1.5],'b-','linewidth',5)
plot([.5 3.5],[2.5 2.5],'b-','linewidth',5)
for y=1:3
    for x=1:3
        if g.b(y,x)==0, continue, end
        text(x,y,g.pp(g.b(y,x)).marker,...
            'fontsize',42,'fontweight','bold',...
            'horizontalalign','center')
    end
end
return
 
function showwin(p1,p2) % draws line thru 3 in a row
global g;
if ~g.showgraph, return, end;
plot([p1(2) p2(2)],[p1(1) p2(1)],'r-','linewidth',5);
drawnow
%rockytop2
return
 
function m=findtwo(p) % finds two in row with a blank
global g
ways = [1 2 3
    4 5 6
    7 8 9
    1 4 7
    2 5 8
    3 6 9
    1 5 9
    3 5 7];
for i=1:8
    r=g.b(ways(i,:));
    fp=find(r==p);
    if length(fp)==2
        c=find(r~=p);
        if r(c)==0
            m=ways(i,c);
            return;
        end
    end
end
m=0;
return;
 
function get_human_move % interactive input
global g
while true
    [x,y,button]=ginput(1);
    x=round(x);
    y=round(y);
    if x>=1 && x<=3 && y>=1 && y<=3 && g.b(y,x)==0
        g.b(y,x)=g.p;
        break;
    else
        beep
    end
end
return
 
function get_players % prompt for player info
global g;
id_title=g.name;
id_prompt={
    'Player 1 name',
    'Player 1 marker',
    'Player 1 type (H, R, A, E)'
    'Player 2 name',
    'Player 2 marker',
    'Player 2 type (H, R, A, E)',
    'Number of games'
    };
id_default={g.pp(1).name,g.pp(1).marker,g.pp(1).type,g.pp(2).name,g.pp(2).marker,g.pp(2).type,'1'};
inp=inputdlg(id_prompt,id_title,1,id_default);
g.pp(1).name=inp{1};
g.pp(1).marker=inp{2};
g.pp(1).type=inp{3};
g.pp(2).name=inp{4};
g.pp(2).marker=inp{5};
g.pp(2).type=inp{6};
g.numgames = str2double(inp{7});
if g.numgames<=0
    g.numgames=1;
end
return
 
function r=randfromlist(list) % random item from list
i=randi([1 length(list)]);
r=list(i);
return
 
function get_computer_move % automatic input
global g
 
m=0;
if nnz(g.b)==0, m=randfromlist(1:2:9); end % first move corner or middle
if nnz(g.b)==1 % second move
    o=find(g.b~=0);
    if o==5, m=randfromlist([1 3 7 9]); % corner
    else m=5; end; % center
end
if m==0, m=findtwo(g.p); end % win
if m==0, m=findtwo(opp(g.p)); end % block
if m==0, m = randfromlist(find(g.b==0)); end  % random
g.b(m)=g.p;
return
 
function init_game
global g;
g.name='Ticky Tacky';
g.showgraph=1;
g.pp(1).name='Human';
g.pp(1).marker='X';
g.pp(1).type='H';
g.pp(2).name='Computer';
g.pp(2).marker='O';
g.pp(2).type='A';
init_board();
init_stats();
return;
 
function init_stats
global g
g.results = [0 0 0];
return
 
function init_board
global g
g.p=mod(sum(g.results),2)+1;
g.b=zeros(3,3);
return
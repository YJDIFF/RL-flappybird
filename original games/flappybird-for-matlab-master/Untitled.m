import java.awt.*;
import java.awt.event.*;
%Create a Robot-object to do the key-pressing
rob=Robot;
%Commands for pressing keys:
% If the text cursor isn't in the edit box allready, then it
% needs to be placed there for ctrl+a to select the text.
% Therefore, we make sure the cursor is in the edit box by
% forcing a mouse button press:

% parfor ii = 1:2
%       if ii==1
%           flappybird();
%       else
%           pause(5);
%           rob.keyPress(KeyEvent.VK_W)
%       end
% end


pause(5);


rob.keyPress(KeyEvent.VK_W)


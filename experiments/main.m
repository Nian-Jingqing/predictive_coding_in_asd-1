 function main
% This experiment is to examine the difference between ASP and TN groups
% using reproduction and central tendency effect. 
% coded by Strongway (shi@lmu.de)
% date: 25th July., 2018

% experiment related parameters
para.viewDistance = 57; % viewing distance 57 cm
para.monitor = 22; % monitor size
para.fntSize = 24; % font size
para.bkColor = [128,128,128]; % background color
para.fColorCircle = [128,128,0]; % foreground color
para.fColorRectangle = [0,200,200]; % white color
para.fColorW = [200];
para.green = [0, 192, 0];
para.red = [192, 0, 0];

para.xPosition = 0; % 0 degree above
para.yPosition = 0; % 0 degree above
para.iti = [0.8, 1]; % range of inter-trial interval
para.iprp = 0.5; % inter production-reproduction interval
para.xyFeedbackArray = [-2,0; -1, 0; 0, 0; 1, 0; 2,  0]; % location of feedback array
para.fbRange = [-100, -0.3; -0.3, -0.1; -0.1, 0.1; 0.1, 0.3; 0.3, 100]; %feedback range with respect to the reproduction error
para.withFeedback = true;
para.vSize = 10; % 10 degree
para.vFeedDivid = 10;

nTrlsBlk = 25;
numHalfTrial = 250;
%[para.nDurations(1,:) ,  para.nDurations(2,:)] = genDurSeq(numHalfTrial, 1);
%[withblkFactors, nDurs] = size(para.nDurations);
%sessionType = withblkFactors;% 1: short matched to circle and long matched to square
%inBlkRep = 1; %inblock repetition
try
%    kb = CInput('k',[1], {'downArrow'});
    kb = CInput('m'); % replace with mouse
    myexp = CExp(1, numHalfTrial, 'blockFactors',  2,...
        'blockRepetition',1);
    % acquire subject information
    myexp.subInfo('Sequence', '1');
    % load sequence w1 from subfolder 'seqs'
    load(['seqs', filesep, 'seq', num2str(myexp.sPara)],'w1');
   % Dur, session, ntrl, nblock
    %production duration, session (1= predictive sequence, 2 = non predictive sequence) 
   myexp.seq( myexp.seq(:, 2) == 1, 1) = w1;
   myexp.seq( myexp.seq(:, 2) == 2, 1) = w1(randperm( length(w1) ) ); % randomized sequence
    % set second column ad block number, 4th colum as block information
    myexp.seq(:,3) = 1: myexp.maxTrls; % trial sequence no. 
    myexp.seq(:,4) = floor((myexp.seq(:,3)-1)/nTrlsBlk) + 1;
    
    v = CDisplay('bgColor',para.bkColor,'fontSize',para.fntSize,'monitorSize',para.monitor,...
        'viewDistance',para.viewDistance,'fullWindow',1, 'skipSync',1);
    HideCursor;
    
    % create stimuli
    para.vObjCircle = v.createShape('circle',para.vSize,para.vSize,'color',para.fColorCircle);
    para.vObjRectangle = v.createShape('rectangle',para.vSize,para.vSize,'color',para.fColorRectangle);

    % create feedback stimuli
    vGreenDisk = v.createShape('circle', para.vSize/para.vFeedDivid, para.vSize/para.vFeedDivid, 'color',para.green);
    vRedDisk = v.createShape('circle', para.vSize/para.vFeedDivid, para.vSize/para.vFeedDivid, 'color',para.red);
    vDiskFrame = v.createShape('circle',para.vSize/para.vFeedDivid, para.vSize/para.vFeedDivid, 'color',para.fColorW,'fill',0);
    para.vFullFrames = [vDiskFrame, vDiskFrame, vDiskFrame, vDiskFrame, vDiskFrame];
    para.vFullDisks = [vRedDisk, vGreenDisk, vGreenDisk, vGreenDisk, vRedDisk];
    %initialize text
    infoText = init_text;
    
    % start instruction
    v.dispText(infoText.instruction);
    kb.wait;
    WaitSecs(2);
    
    for iTrl = 1:myexp.maxTrls
        %get current condition
        cond = myexp.getCondition;  % duration, range
        curDuration = cond(1); % current standard
        
        %start trial presentation
        results = trialPresentation(v,kb, cond, curDuration, para);
        %store results
        myexp.setResp(results);%
        % debugging
        if kb.wantStop
            break;
        end 
        % ITI 0.8-1 seconds
        WaitSecs(para.iti(1) + (para.iti(2)-para.iti(1))*rand);
        if  mod(iTrl,nTrlsBlk) == 0 
             v.dispText(infoText.startBlock);
             kb.wait;
        end
        
        if  iTrl == numHalfTrial
            myexp.saveData;   %save data
            v.dispText(infoText.sessionBreak);
            kb.wait;
            WaitSecs(2);
            kb.wait;
        end
        
    end
    myexp.saveData;   %save data
    v.dispText(infoText.thankyou);
    kb.wait;
    v.close;
    ShowCursor; 
  catch ME
    % debugging
    v.close;
  
    disp(ME.message);
    disp(ME.stack);
    for i=1:length(ME.stack)
        disp(ME.stack(i).name);
        disp(ME.stack(i).line);
    end
    v.close;
    ShowCursor;
end
end


function results = trialPresentation(v, kb, cond, curDuration, para)

        v.dispFixation(20);
        WaitSecs(0.500); %at least 500 ms

        % initiated by key pressing, and measured by key release
        v.dispFixation(5,2); % change fixation from cross to a dot 
        [key, keyInitTime] = kb.response;
        dispObj = para.vObjCircle;
        v.dispItems([para.xPosition, para.yPosition],  dispObj,[para.vSize para.vSize],0,0); % draw texture    
        [vbl, vInitTime] = v.flip;
        WaitSecs(curDuration - 0.005); % 5 ms earlier, so make sure to clear next frame on time.
        [vbl, vStopTime] = v.flip(1); 
  
        keyReleaseTime = kb.keyRelease;
        v.flip(1); %clear screen

        phyDuration = vStopTime - vInitTime;        %visual duration
        proDuration = keyReleaseTime - keyInitTime; %key production

        % reproduction
        WaitSecs(para.iprp); %wait at least 250 ms
        v.dispFixation(5,2);
        
        [key, keyInitTime] = kb.response;
        v.dispItems([para.xPosition, para.yPosition],  dispObj,[para.vSize para.vSize],0,0);
        [vbl, vInitTime] = v.flip;
        keyReleaseTime = kb.keyRelease;

        [vbl, vStopTime]=v.flip(1);
        repDuration = keyReleaseTime - keyInitTime; % key reproduction
        repVDuration = vStopTime - vInitTime; % visual reproduction
       
        %store results
        results = [curDuration, phyDuration, proDuration, repVDuration, repDuration];
   
        if para.withFeedback
            % present a feedback display
            feedbackDisplay = para.vFullFrames;
            delta = (repDuration - phyDuration)/phyDuration;
            % find the range of the error
            cIdx = para.fbRange > delta; % column index of left and right boundary
            idx = find(xor(cIdx(:,1),cIdx(:,2)));
            feedbackDisplay(idx(1)) = para.vFullDisks(idx(1));

            WaitSecs(0.25); % wait 250 ms
            v.dispItems(para.xyFeedbackArray, feedbackDisplay,[para.vSize/para.vFeedDivid para.vSize/para.vFeedDivid]); % draw texture 
            WaitSecs(0.500); % display the feedback for 500 ms
            v.flip;  
        end
        
end

function infoText = init_text
    % specify experimental text
    infoText.instruction = [ 'Erklärung \n\n',...
        'Die folgende Sitzung starten Sie durch Drücken der linken Maustaste. ', ...
        'Bitte fixieren Sie das Kreuz in der Mitte des Bildschirms. ' ...
        'Nach einer sehr kurzen Zeit wird das Kreuz zu einem Punkt. Nun kann das Experiment starten. ', ...
        'Halten Sie nun die Maustaste solange gedrückt wie Sie den gelben Kreis sehen. Bitte achten Sie genau auf die Dauer. ', ...
        'Der Kreis verschwindet automatisch. Lassen Sie die Maustaste wieder los sobald der Kreis verschwindet. ' ...
        'Nachdem Sie nun wieder den kleinen Punkt sehen sollen Sie die Dauer des gelben Kreises reproduzieren. ' ...
        'Hierfür halten Sie die Maustaste solange gedrückt wie Sie die Dauer eingeschätzt haben. ' ...
        'Der gelbe Kreis erscheint dabei als Hilfsmittel. \n'];

    infoText.blockInfo = 'Bitte machen Sie eine Pause. Wenn Sie bereit sind drücken Sie die Maustaste. \n ';
    infoText.endTrial = 'Bitte lassen Sie die Maustaste los';
    infoText.production = '+';
    infoText.reproduction = '+';
    infoText.sessionBreak = ' Die erste Sitzung ist beendet! Bitte öffnen Sie die Tür und machen eine kurze Pause! \n';
    infoText.startBlock = ' Bitte machen Sie eine Pause! \n\n Bitte drücken Sie die Maustaste um den Block zu starten.\n';
    infoText.goingon = ' Bitte machen Sie eine Pause! \n\n Bitte drücken Sie die Maustaste um den Block fortzufahren.';
    infoText.thankyou = 'Das Experiment ist beendet! \nVielen herzlichen Dank!';

end

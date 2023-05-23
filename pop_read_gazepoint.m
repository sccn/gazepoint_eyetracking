function EEG = pop_read_gazepoint(filedata)

if nargin < 1
    help pop_read_gazepoint;
end

gzp = read_gazepoint(filedata);

% convert GAZEPOINT to EEG structure including events
EEG = eeg_emptyset;

EEG.srate = gzp.srate;
EEG.data  = gzp.dat';
EEG.pnts  = size(gzp.dat,2);
EEG.nbchan = size(gzp.dat,1);
EEG.trials = 1;
EEG.chanlocs = struct('labels', gzp.label);
EEG = eeg_checkset(EEG);

% add the events - DEEPA, the events are in smi.event
% place them in EEG.event according to the EEGLAB event format
% conversion is necessary
% https://eeglab.org/tutorials/ConceptsGuide/Data_Structures.html#eegevent

gzp.timestamps = gzp.dat(:,2);
timeInc = median(diff(gzp.timestamps));
realSampleRate = 1/timeInc;
firstSampleLat = gzp.timestamps(1);
if abs(realSampleRate-gzp.srate) > 1
    fprintf(2,'Issue with sample rate, file says %1.2f, sample say %1.2f\n', gzp.srate, realSampleRate)
end

if isequal(gzp.label{end}, 'USER')
    events = gzp.dat(:,end);
    diffevents = diff(events);
    diffeventsPos = [1;find(diffevents)+1; EEG.pnts];
    for iEvent = 1:length(diffeventsPos)-1
        eventVal = events(diffeventsPos(iEvent));
        eventDur = diffeventsPos(iEvent+1)-diffeventsPos(iEvent);
        if eventDur ==  1
            eventDur = [];
        end
        EEG.event(end+1).type = eventVal;
        EEG.event(end  ).latency = diffeventsPos(iEvent);
        EEG.event(end  ).duration = eventDur;
    end
end

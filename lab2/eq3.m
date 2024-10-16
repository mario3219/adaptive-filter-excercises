function eq3
    Panels = {
        {{'Main', 'TimeSeries'},    'TimeSeries',   [  1, 1, 114, 48]}, ...
        {{'Main', 'Channel'},       'Channel',      [117, 1, 114, 48]}, ...
        {{'Main', 'Settings'},      'Settings',     [233, 1, 50, 48]}, ...
    };

    AxesTime = {
        ... Time series plots.
        {{'TimeSeries', 'Equalized'},           [14,  4, 87, 10]}, ...
        {{'TimeSeries', 'Output'},              [14, 18, 87, 10]}, ...
        {{'TimeSeries', 'Input'},               [14, 32, 87, 10]}, ...
    };

    AxesChannel = {
        ... Equalizer plots.
        {{'Channel', 'ChannelAmplitude'},       [14,  4, 40, 17]}, ...
        {{'Channel', 'ChannelImpulse'},         [14, 25, 40, 17]}, ...
        {{'Channel', 'EqualizerAmplitude'},     [64,  4, 40, 17]}, ...
        {{'Channel', 'EqualizerImpulse'},       [64, 25, 40, 17]}, ...
    };

    Controls = {
        ... Runtime actions and settings.
        {{'Settings', 'Exit'},              'pushbutton',       'Exit',             [ 2  1 46 1.75]}, ...
        {{'Settings', 'Start'},             'pushbutton',       'Start',            [ 2  5 46 1.75]}, ...
        {{'Settings', 'StepSize'},          'slider',           [],                 [ 2 11 46 1.75]}, ...
        {{'Settings', 'StepSizeLabel'},     'text',             [],                 [ 2 13 46 1.25]}, ...
        {{'Settings', 'NoiseLevel'},        'slider',           [],                 [ 2 15 46 1.75]}, ...
        {{'Settings', 'NoiseLevelLabel'},   'text',             [],                 [ 2 17 46 1.25]}, ...
        {{'Settings', 'Training'},          'popupmenu',        {'Training', 'Decision feedback', 'Freeze'}, [ 2 21 46 1.25]}, ...
        {{'Settings', 'Fixed'},             'popupmenu',        {'Fixed', 'Drift'}, [ 2 23 46 1.25]}, ...
        ... Equalizer settings.
        {[],                                'text',             'Delay',            [ 2 25 30 1.50]}, ...
        {{'Settings', 'Delay'},             'edit',             10,                 [34 25 14 1.75]}, ...
        {[],                                'text',             'Equalizer order',  [ 2 27 30 1.50]}, ...
        {{'Settings', 'EqualizerOrder'},    'edit',             10,                 [34 27 14 1.75]}, ...
        {[],                                'text',             'Symbol interval',  [ 2 29 30 1.50]}, ...
        {{'Settings', 'SymbolInterval'},    'edit',             5,                  [34 29 14 1.75]}, ...
        {[],                                'text',             'Window',           [ 2 31 30 1.50]}, ...
        {{'Settings', 'Window'},            'edit',             30,                 [34 31 14 1.75]}, ...
        ... Channel settings.
        {{'Settings', 'MakeChannel'},       'pushbutton',       'Make channel',     [ 2  35 46 1.75]}, ...
        {[],                                'text',             'Stop band attenuation', [ 2 39 30 1.50]}, ...
        {{'Settings', 'StopAttenuation'},   'edit',             0.3                      [34 39 14 1.75]}, ...
        {[],                                'text',             'Edge frequency',   [ 2 41 30 1.50]}, ...
        {{'Settings', 'EdgeFrequency'},     'edit',             0.2,                [34 41 14 1.75]}, ...
        {[],                                'text',             'Channel order',    [ 2 43 30 1.50]}, ...
        {{'Settings', 'ChannelOrder'},      'edit',             10,                 [34 43 14 1.75]}, ...
    };

    %%
    g = gui.window('MainWindow', 'Channel Equalization', [284 50]);

    addpanels(g, Panels);
    addaxes(g, AxesTime, {'Main', 'TimeSeries'});
    addaxes(g, AxesChannel, {'Main', 'Channel'});
    addcontrols(g, Controls, {'Main', 'Settings'});

    handles = g.Controls;

    set(handles.Settings.Exit, 'Callback', @ExitCallback);
    set(handles.Settings.Start, 'Callback', @StartCallback, 'Enable', 'off');
    set(handles.Settings.StepSize,   'Callback', @(varargin) gui.SliderLabelCallback(handles.Settings.StepSize,    handles.Settings.StepSizeLabel,   'Step size: %4.3f'));
    set(handles.Settings.NoiseLevel, 'Callback', @(varargin) gui.SliderLabelCallback(handles.Settings.NoiseLevel,  handles.Settings.NoiseLevelLabel, 'Noise variance: %6.5f', @db2mag));
    set(handles.Settings.MakeChannel, 'Callback', @MakeChannelCallback);
    
    gui.SliderLabelValue(handles.Settings.StepSize, 0, 3, 0.5);
    gui.SliderLabelValue(handles.Settings.NoiseLevel, -100, 0, -60);

    states = struct();
    states.DisableOnStart = horzcat(...
        handles.Settings.Delay, ...
        handles.Settings.EqualizerOrder, ...
        handles.Settings.Window, ...
        handles.Settings.MakeChannel, ...
        handles.Settings.StopAttenuation, ...
        handles.Settings.EdgeFrequency, ...
        handles.Settings.ChannelOrder);

    objects = findall([handles.Main.TimeSeries, handles.Main.Channel], '-property', 'Title');
    titles = get(objects, 'Title');
    set(titles{3}, 'String', 'Input signal');
    set(titles{4}, 'String', 'Output signal');
    set(titles{5}, 'String', 'Equalized signal');
    set(titles{6}, 'String', 'Equalizer impulse response');
    set(titles{7}, 'String', 'Equalizer amplitude response');
    set(titles{8}, 'String', 'Channel impulse response');
    set(titles{9}, 'String', 'Channel amplitude response');
    
    set(handles.MainWindow, 'Visible', 'on');
    
    function ExitCallback(varargin)
        delete(handles.MainWindow);
    end

    function MakeChannelCallback(varargin)       
        f = gui.getdouble(handles.Settings.EdgeFrequency);
        A = gui.getdouble(handles.Settings.StopAttenuation);
        K = gui.getdouble(handles.Settings.ChannelOrder, @round);

        if f<0 || f>1
            error('Edge frequency must be between 0 and 1.');
        end
        
        if A<0 || A>1
            error('Stop band attenuation must be between 0 and 1.');
        end
        
        if K<1 || K>20
            error('Channel order must be between 1 and 20.');
        end
        
        if mod(K,2)
            error('Channel order must be even.');
        end
        
        fax = linspace(0, 1, 11);
        cut = round(f*2*11);
        mag0 = horzcat(ones(1,cut),    A*ones(1,11-cut));
        mag1 = horzcat(ones(1,cut), .5*A*ones(1,11-cut));
        
        states.h0 = fir2(K, fax, mag0);
        states.h1 = fir2(K, fax, mag1);
        states.fc = (0:256)'/512;
        
        H = fft(states.h0, 512);
        H = H(1:257);
        Hi = 1./abs(H);

        states.plothandles.hc = stem(handles.Channel.ChannelImpulse,     0:K, states.h0, 'bo');
        states.plothandles.Hc = plot(handles.Channel.ChannelAmplitude,   states.fc, abs(H));
        states.plothandles.He = plot(handles.Channel.EqualizerAmplitude, states.fc, nan(257,1), 'b', states.fc, nan(257,1), 'r:', states.fc, Hi, 'g:');
        
        axis(handles.Channel.ChannelImpulse,     [0, K, -.5, 1.5]);
        axis(handles.Channel.ChannelAmplitude,   [0, 0.5, 0, 1.1]);
        axis(handles.Channel.EqualizerAmplitude, [0, 0.5, 0, 2.1/A]);
        
        set(handles.Settings.Start, 'Enable', 'on');
    end

    %%
    function StartCallback(varargin)
        A = gui.getdouble(handles.Settings.StopAttenuation);
        channelorder = length(states.h0);
        equalizerorder = gui.getdouble(handles.Settings.EqualizerOrder, @round);
        windowlength = gui.getdouble(handles.Settings.Window, @round);
        delay = gui.getdouble(handles.Settings.Delay, @round);
        
        if equalizerorder<1 || equalizerorder>40
            error('Equalizer order must be between 1 and 40.');
        end
        
        if delay<0
            error('Delay must be non-negative.');
        end
        
        if windowlength<1
            error('Window must be positive.');
        end
        
        if windowlength<=channelorder
            error('Window must be larger than the channel order.');
        end

        if windowlength<=equalizerorder
            error('Window must be larger than the equalizer order.');
        end

        if windowlength<=delay
            error('Window must be larger than the delay.');
        end
     
        states.w = zeros(equalizerorder+1,1);
        states.x = zeros(windowlength,1);
        states.y = zeros(windowlength,1);
        states.e = zeros(windowlength,1);
        states.t = 1;
        states.drift = 0;
        
        T = timer( ...
            'TimerFcn', @TimerStepCallback, ...
            'StopFcn', @TimerStopCallback, ...
            'StartFcn', @TimerStartCallback, ...
            'ExecutionMode', 'fixedRate', ...
            'BusyMode', 'queue', ...
            'Period', 0.1 ...
            );
        
        states.plothandles.tx = stem(handles.TimeSeries.Input,     0:windowlength-1, nan(windowlength, 1), 'bo');
        states.plothandles.ty = stem(handles.TimeSeries.Output,    0:windowlength-1, nan(windowlength, 1), 'bo');
        states.plothandles.te = stem(handles.TimeSeries.Equalized, 0:windowlength-1, nan(windowlength, 1), 'bo');
        states.plothandles.he = stem(handles.Channel.EqualizerImpulse,   0:equalizerorder, nan(equalizerorder+1,1), 'bo');
        
        axis(handles.Channel.EqualizerImpulse,   [0, equalizerorder, -.5/A, 1.5/A]);
        axis(handles.TimeSeries.Input,     [0, windowlength-1, -1.5, 1.5]);
        axis(handles.TimeSeries.Output,    [0, windowlength-1, -1.5, 1.5]);
        axis(handles.TimeSeries.Equalized, [0, windowlength-1, -1.5, 1.5]);
        
        start(T);
        
        function TimerStartCallback(varargin)
            set(states.DisableOnStart, 'Enable', 'off');
%             set(handles.MainWindow, 'WindowStyle', 'modal', 'CloseRequestFcn', []);
%             set(handles.Settings.Exit, 'Enable', 'off');
            set(handles.Settings.Start, 'String', 'Stop', 'Callback', @(varargin) stop(T));
        end
       
        function TimerStopCallback(varargin)
            set(handles.Settings.Start, 'String', 'Start', 'Callback', @StartCallback);
%             set(handles.Settings.Exit, 'Enable', 'on');
%             set(handles.MainWindow, 'WindowStyle', 'normal', 'CloseRequestFcn', 'closereq');
            set(states.DisableOnStart, 'Enable', 'on');
        end

        function TimerStepCallback(varargin)
            interval = gui.getdouble(handles.Settings.SymbolInterval, @round);
           
            if interval<1
                interval = 1;
            end
            
            if interval>10
                interval = 10;
            end
            
            br = db2mag(get(handles.Settings.NoiseLevel, 'Value'));
            mu = get(handles.Settings.StepSize, 'Value');
            df = get(handles.Settings.Training, 'Value');
            dr = get(handles.Settings.Fixed, 'Value');

           
            if mod(states.t, interval)
                x0 = 0;
            else
                x0 = 2*round(rand) - 1;
            end
            
            xn = sqrt(br)*randn;
            
            states.x(2:windowlength) = states.x(1:windowlength-1);
            states.y(2:windowlength) = states.y(1:windowlength-1);
            states.e(2:windowlength) = states.e(1:windowlength-1);
            
            if dr == 1
                states.h = states.h0;
            elseif dr == 2
                states.h = (1-states.drift)*states.h0 + states.drift*states.h1;
                states.drift = min(1, states.drift+0.01);
            else
                error('Invalid program state.');
            end
            
            states.x(1) = x0;
            states.y(1) = states.h * states.x(1:channelorder) + xn;
            states.e(1) = states.w' * states.y(1:equalizerorder+1);


            if df == 1
                d = states.x(1 + delay);
            elseif df == 2
                if mod(states.t + delay, interval)
                    d = 0;
                else
                    d = sign(states.e(1));
                end
            elseif df == 3
                d = 0;
                mu = 0;
            else
                error('Invalid program state.');
            end
            
            states.w = states.w + mu * (d-states.e(1)) * states.y(1:equalizerorder+1);
            states.t = states.t + 1;
           
            W = fft(states.w, 512);
            H = fft(states.h, 512);
            W = W(1:257);
            H = H(1:257);
            Hw = (abs(H))./((abs(H)).^2 + br*(equalizerorder+1));
            Hi = 1./abs(H);

            set(states.plothandles.tx, 'YData', states.x);
            set(states.plothandles.ty, 'YData', states.y);
            set(states.plothandles.te, 'YData', states.e);
            set(states.plothandles.hc, 'YData', states.h);
            set(states.plothandles.he, 'YData', states.w);
            set(states.plothandles.Hc, 'YData', abs(H));
            set(states.plothandles.He(1), 'YData', abs(W));
            set(states.plothandles.He(2), 'YData', abs(Hw));
            set(states.plothandles.He(3), 'YData', abs(Hi));
            drawnow;
        end
    end
end


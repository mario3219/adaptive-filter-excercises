function eq2
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
        ... Equalizer settings.
        {[],                                'text',             'Delay',            [ 2 21 30 1.50]}, ...
        {{'Settings', 'Delay'},             'edit',             15,                 [34 21 14 1.75]}, ...
        {[],                                'text',             'Equalizer order',  [ 2 23 30 1.50]}, ...
        {{'Settings', 'EqualizerOrder'},    'edit',             30,                 [34 23 14 1.75]}, ...
        {[],                                'text',             'Symbol interval',  [ 2 25 30 1.50]}, ...
        {{'Settings', 'SymbolInterval'},    'edit',             5,                  [34 25 14 1.75]}, ...
        {[],                                'text',             'Window',           [ 2 27 30 1.50]}, ...
        {{'Settings', 'Window'},            'edit',             40,                 [34 27 14 1.75]}, ...
        ... Channel settings.
        {{'Settings', 'MakeChannel'},       'pushbutton',       'Make channel',     [ 2  31 46 1.75]}, ...
        ...{{'Settings', 'SampleChannel'},     'pushbutton',       'Sample channel',     [ 2  33 46 1.75]}, ...
        {[],                                'text',             'Sampling frequency', [ 2 35 30 1.50]}, ...
        {{'Settings', 'SamplingFrequency'}, 'edit',             6                      [34 35 14 1.75]}, ...
        {[],                                'text',             'Edge frequency',   [ 2 37 30 1.50]}, ...
        {{'Settings', 'EdgeFrequency'},     'edit',             1,                  [34 37 14 1.75]}, ...
        {[],                                'text',             'Channel order',    [ 2 39 30 1.50]}, ...
        {{'Settings', 'ChannelOrder'},      'edit',             2,                 [34 39 14 1.75]}, ...
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
    %set(handles.Settings.SampleChannel, 'Callback', @SampleChannelCallback);
    
    gui.SliderLabelValue(handles.Settings.StepSize, 0, 3, 0.5);
    gui.SliderLabelValue(handles.Settings.NoiseLevel, -100, 0, -60);

    states = struct();
    states.DisableOnStart = horzcat(...
        handles.Settings.Delay, ...
        handles.Settings.EqualizerOrder, ...
        handles.Settings.Window, ...
        handles.Settings.MakeChannel, ...
        handles.Settings.SamplingFrequency, ...
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
        K  = gui.getdouble(handles.Settings.ChannelOrder, @round);
        L  = gui.getdouble(handles.Settings.EqualizerOrder, @round);
        Fe  = gui.getdouble(handles.Settings.EdgeFrequency);
        Fs = gui.getdouble(handles.Settings.SamplingFrequency);

        if Fe>Fs/2
            error('Edge frequency must be less than half the sampling frequency.');
        end
        
        if K<1 || K>4
            error('Channel order must be between 1 and 4.');
        end
        
        Fv=(0:511)*Fs/512;
        [B,A]=butter(K,2*pi*Fe,'s');
        
        
        im=.6*5*2*pi;
        re1=3;
        re2=1;
       
        H = freqs(B,A,2*pi*Fv);
        Ba = poly([ re1+1i*im,  re1-1i*im]);
        Aa = poly([-re2+1i*im, -re2-1i*im]);
        Ht = H .* freqs(Ba,Aa,2*pi*Fv);
        
        [Bz, Az] = impinvar(conv(B, Ba), conv(A, Aa), Fs);
        
        hz = impz(Bz, Az, 20);
        Hz = freqz(Bz, Az, 2*pi/Fs*Fv);
        Hi = 1./abs(Hz);
        
        states.Bz = Bz;
        states.Az = Az;

        states.plothandles.hc = stem(handles.Channel.ChannelImpulse, 0:19, hz);
        states.plothandles.he = stem(handles.Channel.EqualizerImpulse, 0:L, nan(L+1,1), 'bo');
        states.plothandles.Hc = plot(handles.Channel.ChannelAmplitude, Fv, abs(Hz), 'b', Fv, abs(Ht), 'r:');
        states.plothandles.He = plot(handles.Channel.EqualizerAmplitude, Fv, nan(512,1), 'b', Fv, nan(512,1), 'r:', Fv, Hi, 'g:');
        
        Amax = max(abs(Hi));
        
        axis(handles.Channel.ChannelImpulse,     [0, 20, -.5, 1.5]);
        axis(handles.Channel.EqualizerImpulse,   [0, L, -.5, 1.5]);
        axis(handles.Channel.ChannelAmplitude,   [0, Fs, 0, 1.1]);
        axis(handles.Channel.EqualizerAmplitude, [0, Fs, 0, 1.1*max(5, Amax)]);
        
        set(handles.Settings.Start, 'Enable', 'on');
    end

    %%
    function StartCallback(varargin)
        channelorder = gui.getdouble(handles.Settings.ChannelOrder, @round);
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
        
        if windowlength<channelorder+3
            error('Window must be 3 orders larger than the channel order.');
        end

        if windowlength<equalizerorder
            error('Window must be larger than the equalizer order.');
        end

        if windowlength<delay
            error('Window must be larger than the delay.');
        end
      
        equalizerorder = equalizerorder+1;
        
        states.w = zeros(equalizerorder,1);
        states.x = zeros(windowlength,1);
        states.y = zeros(windowlength,1);
        states.e = zeros(windowlength,1);
        states.t = 1;
      
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
            br = db2mag(get(handles.Settings.NoiseLevel, 'Value'));
            mu = get(handles.Settings.StepSize, 'Value');
            
            if interval<1
                interval = 1;
            end
            
            if interval>10
                interval = 10;
            end
            

            if mod(states.t, interval)
                x0 = 0;
            else
                x0 = 2*round(rand) - 1;
            end
            
            xn = sqrt(br)*randn;
            
            states.x(2:windowlength) = states.x(1:windowlength-1);
            states.y(2:windowlength) = states.y(1:windowlength-1);
            states.e(2:windowlength) = states.e(1:windowlength-1);
            
            qb = length(states.Bz);
            qa = length(states.Az);
            
            states.x(1) = x0;
            states.y(1) = states.Bz*states.x(1:qb) - states.Az(2:qa)*states.y(2:qa)/states.Az(1) + xn;
            states.e(1) = states.w' * states.y(1:equalizerorder);
            
            d = states.x(1+delay);
            
            states.w = states.w + mu * (d-states.e(1)) * states.y(1:equalizerorder);
            states.t = states.t + 1;
           
            W = fft(states.w, 512);
            H = freqz(states.Bz,states.Az, 2*pi*(0:511)/512);
            Hw = (abs(H))./((abs(H)).^2 + br*equalizerorder);

            set(states.plothandles.tx, 'YData', states.x);
            set(states.plothandles.ty, 'YData', states.y);
            set(states.plothandles.te, 'YData', states.e);
            set(states.plothandles.he, 'YData', states.w);
            set(states.plothandles.He(1), 'YData', abs(W));
            set(states.plothandles.He(2), 'YData', abs(Hw));
            drawnow;
        end
    end
end

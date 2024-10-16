function ale
    SampleRate = 8000;
    BlockSize = 320;
    DisplaySize = 1920;
    SweepPeriod = 10;
    EnhancerDelay = 100;
    
    ProcessRate = BlockSize/SampleRate;
    
    Sources = { ...
        'Play sinusoid', ...
        'Play alternating sinusoids', ...
        'Play linear sweep', ...
        'Play music file', ...
    };

    Display = { ...
        'Show impulse response', ...
        'Show amplitude response', ...
        'Show PSD of d[n]', ...
        'Show PSD of y[n]', ...
        'Show PSD of e[n]', ...
        'Show d[n]', ...
        'Show y[n]', ...
        'Show e[n]', ...
    };
    
    Panels = {
        {{'Main', 'Display'},   'Display',      [  1, 1, 128, 39]}, ...
        {{'Main', 'Settings'},  'Settings',     [130, 1,  50, 39]}, ...
    };

    Axes = {
        {{'Display', 'Display'}, [14, 5, 100, 29]}, ...
    };

    Controls = {
        {{'Settings', 'Exit'},              'pushbutton',       'Exit',         [2  1 46 1.75]}, ...
        {{'Settings', 'Display'},           'popupmenu',        Display,        [2 33 46 1.75]}, ...
        {{'Settings', 'Source'},            'popupmenu',        Sources,        [2 35 46 1.75]}, ...
        {{'Settings', 'Start'},             'pushbutton',       'Start',        [2  5 46 1.75]}, ...
        {{'Settings', 'Reset'},             'pushbutton',       'Reset LMS',    [2  7 46 1.75]}, ...
        {{'Settings', 'SecFreq'},           'slider',           [],             [2 11 46 1.75]}, ...
        {{'Settings', 'SecFreqLabel'},      'text',             [],             [2 13 46 1.25]}, ...
        {{'Settings', 'PriFreq'},           'slider',           [],             [2 15 46 1.75]}, ...
        {{'Settings', 'PriFreqLabel'},      'text',             [],             [2 17 46 1.25]}, ...
        {{'Settings', 'NoiseLevel'},        'slider',           [],             [2 19 46 1.75]}, ...
        {{'Settings', 'NoiseLevelLabel'},   'text',             [],             [2 21 46 1.25]}, ...
        {{'Settings', 'Leakage'},           'slider',           [],             [2 23 46 1.75]}, ...
        {{'Settings', 'LeakageLabel'},      'text',             [],             [2 25 46 1.25]}, ...
        {{'Settings', 'StepSize'},          'slider',           [],             [2 27 46 1.75]}, ...
        {{'Settings', 'StepSizeLabel'},     'text',             [],             [2 29 46 1.25]}, ...
    };

    %%
    g = gui.window('MainWindow', 'Adaptive Line Enhancer', [182 41]);

    g.addpanels(Panels);
    g.addaxes(Axes, {'Main', 'Display'});
    g.addcontrols(Controls, {'Main', 'Settings'});

    handles = g.Controls;
    
    set(handles.Settings.Exit, 'Callback', @ExitCallback);
    set(handles.Settings.Start, 'Callback', @StartCallback);
    set(handles.Settings.Reset, 'Callback', @ResetCallback);
    set(handles.Settings.Display, 'Callback', @DisplayCallback);
    set(handles.Settings.StepSize, 'Callback', @(varargin) gui.SliderLabelCallback(handles.Settings.StepSize, handles.Settings.StepSizeLabel, 'Step size: %6.5f', @(x)10^x));
    set(handles.Settings.Leakage, 'Callback', @(varargin) gui.SliderLabelCallback(handles.Settings.Leakage, handles.Settings.LeakageLabel, 'Leakage factor: %6.5f'));
    set(handles.Settings.NoiseLevel, 'Callback', @(varargin) gui.SliderLabelCallback(handles.Settings.NoiseLevel, handles.Settings.NoiseLevelLabel, 'Noise variance: %6.5f', @db2mag));
    set(handles.Settings.PriFreq, 'Callback', @(varargin) gui.SliderLabelCallback(handles.Settings.PriFreq, handles.Settings.PriFreqLabel, 'Primary frequency: %d Hz', @round));
    set(handles.Settings.SecFreq, 'Callback', @(varargin) gui.SliderLabelCallback(handles.Settings.SecFreq, handles.Settings.SecFreqLabel, 'Secondary frequency: %d Hz', @round));

    gui.SliderLabelValue(handles.Settings.StepSize, -5, -1, -3);
    gui.SliderLabelValue(handles.Settings.Leakage, 0.999, 1, 1);
    gui.SliderLabelValue(handles.Settings.NoiseLevel, -80, -20, -50);
    gui.SliderLabelValue(handles.Settings.PriFreq, 0, 4000, 800);
    gui.SliderLabelValue(handles.Settings.SecFreq, 0, 4000, 2000);

    mfile = mfilename('fullpath');
    [mpath,~,~] = fileparts(mfile);

    params = struct();
    params.SampleRate = SampleRate;
    params.BlockSize = BlockSize;
    params.DisplaySize = DisplaySize;
    params.SweepPeriod = SweepPeriod;
    params.EnhancerDelay = EnhancerDelay;
    
    states = struct();
    states.file = mpath;
    states.n = 0;
    states.d = zeros(params.DisplaySize, 1);
    states.e = zeros(params.DisplaySize, 1);
    states.y = zeros(params.DisplaySize, 1);
    states.z = [];
   
    states.timer = timer(...
        'ExecutionMode', 'fixedrate', ...
        'Period', ProcessRate, ...
        'TasksToExecute', inf, ...
        'TimerFcn', @ProcessCallback ...
    );
    
    states.x = dsp.SignalSource(...
        'SamplesPerFrame', params.BlockSize, ...
        'SignalEndAction', 'Cyclic repetition' ...
    );

    states.h = dsp.LMSFilter(...
        'Length', 100 ...
    );

    set(handles.MainWindow, 'Visible', 'on');

    %%
    function ExitCallback(varargin)
        stop(states.timer);
        delete(states.timer);
        delete(handles.MainWindow);
    end
    
    function ResetCallback(varargin)
        reset(states.h);
    end

    %%
    function StartCallback(varargin)
        source = get(handles.Settings.Source, 'Value');
        
        if source == 4
            [name, path] = uigetfile('*.wav', 'Select file...', states.file);
            file = fullfile(path, name);
            data = audioread(file);
            
            N = size(data,1);
            B = params.BlockSize;

            states.file = file;
            states.x.release();
            states.x.Signal = data(1:N-rem(N,B),1);
        end
        
        states.n = 0;

        start(states.timer);
        
        set(handles.Settings.Source, 'Enable', 'off');
        set(handles.Settings.Start, 'String', 'Stop', 'Callback', @StopCallback);
    end

    function StopCallback(varargin)
        stop(states.timer);
        set(handles.Settings.Start, 'String', 'Start', 'Callback', @StartCallback);
        set(handles.Settings.Source, 'Enable', 'on');
    end
    
    function ProcessCallback(varargin)
        stepsize = get(handles.Settings.StepSize, 'Value');
        leakage = get(handles.Settings.Leakage, 'Value');
        noiselevel = get(handles.Settings.NoiseLevel, 'Value');
        source = get(handles.Settings.Source, 'Value');
        
        f0 = get(handles.Settings.PriFreq, 'Value');
        f1 = get(handles.Settings.SecFreq, 'Value');
        B = params.BlockSize;
        L = params.DisplaySize;
        T = params.SweepPeriod;
        D = params.EnhancerDelay;
        I = transpose(0:B-1);
        
        states.h.StepSize = mpower(10, stepsize);
        states.h.LeakageFactor = leakage;

        t = mod((states.n + I)/params.SampleRate, params.SweepPeriod);

        if source == 1
            s = sin(2*pi*t .* f0);
        elseif source == 2
            w = f0 + (f1-f0)*double(mod(t, T) > T/2);
            s = sin(2*pi*t .* w);
        elseif source == 3
            s = chirp(t, f0, T, f1, 'linear');
        elseif source == 4
            s = step(states.x);
        end

        v = randn(B, 1) * sqrt(db2mag(noiselevel));
        x = s+v;
        
        last = (L-B+1:L);
        rest = (1:L-B);

        states.n = states.n + B;
        states.d(rest) = states.d(rest+B);
        states.e(rest) = states.e(rest+B);
        states.y(rest) = states.y(rest+B);
        states.d(last) = x;
        [y, e, z] = step(states.h, states.d(last-D), states.d(last));
        states.e(last) = e;
        states.y(last) = y;
        states.z = z;

        if norm(z) > 100
            StopCallback;
        end
        
        DisplayCallback;
    end

    function DisplayCallback(varargin)
        B = params.BlockSize;
        N = params.SampleRate/2;
        D = get(handles.Settings.Display, 'Value');

        if D == 1
            stem(handles.Display.Display, states.z);
            set(handles.Display.Display, 'XLim', [0, 100], 'YLim', [-.1, .1]);
        elseif D == 2
            [H,w] = freqz(states.z);
            plot(handles.Display.Display, w*N/pi, pow2db(abs(H)));
            set(handles.Display.Display, 'XLim', [0, N], 'YLim', [-40, 10]);
        elseif D == 3
            [H,w] = pwelch(states.d);
            plot(handles.Display.Display, w*N/pi, pow2db(abs(H)));
            set(handles.Display.Display, 'XLim', [0, N], 'YLim', [-60, 20]);
        elseif D == 4
            [H,w] = pwelch(states.y);
            plot(handles.Display.Display, w*N/pi, pow2db(abs(H)));
            set(handles.Display.Display, 'XLim', [0, N], 'YLim', [-60, 20]);
        elseif D == 5
            [H,w] = pwelch(states.e);
            plot(handles.Display.Display, w*N/pi, pow2db(abs(H)));
            set(handles.Display.Display, 'XLim', [0, N], 'YLim', [-60, 20]);
        elseif D == 6
            plot(handles.Display.Display, states.d);
            set(handles.Display.Display, 'XLim', [0, B], 'YLim', [-4, 4]);
        elseif D == 7
            plot(handles.Display.Display, states.y);
            set(handles.Display.Display, 'XLim', [0, B], 'YLim', [-4, 4]);
        elseif D == 8
            plot(handles.Display.Display, states.e);
            set(handles.Display.Display, 'XLim', [0, B], 'YLim', [-4, 4]);
        end
    end
end

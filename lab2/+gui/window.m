classdef window < handle
    properties(Access=private)
        defaultEditHeight = 1.6923076923076;
        defaultTextHeight = 1.07692307692308;
        defaultGlobalStyle = {'Units', 'characters'};
        defaultFigureStyle = {'HandleVisibility', 'callback', 'NumberTitle', 'off', 'Resize', 'off'};
        defaultAxesStyle = {'HandleVisibility', 'callback', 'NextPlot', 'replacechildren', 'Box', 'on'};
        defaultPanelStyle = {'BorderType', 'line', 'Clipping', 'on', 'HighlightColor', [0, 0, 0]};
        defaultControlStyle = {'HorizontalAlignment', 'left'};
    end
    
    properties(SetAccess=private)
        Window = [];
        Controls = [];
    end

    methods
        function obj = window(varargin)
            obj = addwindow(obj, varargin{:});
        end
    end
    
    methods
        function cpos = vcenter(obj, pos)
            h = obj.defaultTextHeight;
            base = pos(2) + pos(4)/2 - h/2;
            cpos = horzcat(pos(1), base, pos(3), h);
        end
        
        function wait(obj)
            uiwait(obj.Window);
        end
        
        function resume(obj)
            uiresume(obj.Window);
        end
        
        function close(obj)
            close(obj.Window);
        end

        function obj = addaxes(obj, items, parent)
            if nargin < 3 || isempty(parent)
                hparent = obj.Window;
            elseif iscell(parent)
                hparent = getfield(obj.Controls, parent{:});
            else
                hparent = obj.Controls.(parent);
            end

            for n = 1:numel(items)
                item = items{n};

                name = item{1};
                position = item{2};

                h = axes(...
                    'Parent', hparent,...
                    obj.defaultGlobalStyle{:},...
                    obj.defaultAxesStyle{:},...
                    'Position', position);

                if iscell(name)
                    obj.Controls = setfield(obj.Controls, name{:}, h);
                elseif ~isempty(name)
                    obj.Controls.(name) = h;
                end
            end
        end
        
        function obj = addcontrols(obj, items, parent)
            if nargin < 3 || isempty(parent)
                hparent = obj.Window;
            elseif iscell(parent)
                hparent = getfield(obj.Controls, parent{:});
            else
                hparent = obj.Controls.(parent);
            end

            for n = 1:numel(items)
                item = items{n};

                % Required: control name, style, string and position.
                name = item{1};
                style = item{2};
                string = item{3};
                position = item{4};

                % Adjust control attributes.
                if any(strcmpi(style, {'edit', 'popupmenu', 'listbox'}))
                    additionalControlStyle = {'BackgroundColor', [1 1 1]};
                else 
                    additionalControlStyle = {};
                end

                % Add control.
                h = uicontrol(...
                    'Parent', hparent, ...
                    obj.defaultGlobalStyle{:}, ...
                    obj.defaultControlStyle{:}, ...
                    'Style', style, ...
                    'String', string, ...
                    'Position', position, ...
                    additionalControlStyle{:});

                if iscell(name)
                    obj.Controls = setfield(obj.Controls, name{:}, h);
                elseif ~isempty(name)
                    obj.Controls.(name) = h;
                end
            end
        end
        
        function obj = addgroups(obj, items, parent)
            if nargin < 3 || isempty(parent)
                hparent = obj.Window;
            elseif iscell(parent)
                hparent = getfield(obj.Controls, parent{:});
            else
                hparent = obj.Controls.(parent);
            end

            for n = 1:numel(items)
                item = items{n};

                name = item{1};
                title = item{2};
                position = item{3};

                h = uibuttongroup(...
                    'Parent', hparent, ...
                    obj.defaultGlobalStyle{:}, ...
                    obj.defaultPanelStyle{:}, ...
                    'Title', title, ...
                    'Position', position);

                if iscell(name)
                    obj.Controls = setfield(obj.Controls, name{:}, h);
                elseif ~isempty(name)
                    obj.Controls.(name) = h;
                end
            end
        end

        function obj = addpanels(obj, items, parent)
            if nargin < 3 || isempty(parent)
                hparent = obj.Window;
            elseif iscell(parent)
                hparent = getfield(obj.Controls, parent{:});
            else
                hparent = obj.Controls.(parent);
            end

            for n = 1:numel(items)
                item = items{n};

                name = item{1};
                title = item{2};
                position = item{3};

                h = uipanel(...
                    'Parent', hparent, ...
                    obj.defaultGlobalStyle{:}, ...
                    obj.defaultPanelStyle{:}, ...
                    'Title', title, ...
                    'Position', position);

                if iscell(name)
                    obj.Controls = setfield(obj.Controls, name{:}, h);
                elseif ~isempty(name)
                    obj.Controls.(name) = h;
                end
            end
        end
        
        function obj = addwindow(obj, varargin)
            if nargin == 2
                value = varargin{1};
            else
                value = varargin;
            end

            name = value{1};
            title = value{2};
            position = value{3};

            if numel(position) == 2
                wpos = vertcat(0, 0, position(:));
            else
                wpos = position;
            end

            defaultBackground = get(0, 'defaultUicontrolBackgroundColor');

            h = figure( ...
                'Color', defaultBackground, ...
                obj.defaultGlobalStyle{:},...
                obj.defaultFigureStyle{:},...
                'MenuBar','none',...
                'Name', title,...
                'Position', wpos,...
                'Visible', 'off');

            if numel(position) == 2
                units = get(h, 'Units');
                set(h, 'Units', 'normalized');
                pos = get(h, 'Position' );
                pos(1:2) = 0.5 - pos(3:4)/2;
                set(h, 'Position', pos);
                set(h, 'Units', units);
            end

            obj.Window = h;
            obj.Controls.(name) = h;
        end
    end
end

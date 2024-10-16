function SliderLabelCallback(slider, label, string, fun)
    value = get(slider, 'Value');
    if nargin >= 4
        value = fun(value);
    end
    str = sprintf(string, value);
    set(label, 'String', str);
end

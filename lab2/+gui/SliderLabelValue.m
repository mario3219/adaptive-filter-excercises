function SliderLabelValue(slider, min, max, value)
    set(slider, 'Min', min, 'Max', max, 'Value', value);
    callback = get(slider, 'Callback');
    callback(slider);
end

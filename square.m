function I = square(I)
    %adds coloums/rows of zeros to create a square image
    sz = size(I);
    if sz(1) < sz(2)
        temp = (sz(2) - sz(1))*0.5;
        if mod(temp,1) > 0
            I = padarray(I,[0 1], 'replicate', 'post');
        end
        I = padarray(I,[round(temp) 0], 'replicate');
    elseif sz(2) < sz(1)
        temp = (sz(1) - sz(2))*0.5;
        if mod(temp,1) > 0
            I = padarray(I, [1 0], 'replicate', 'post');
        end
        I = padarray(I,[0 round(temp)], 'replicate');
    end
end

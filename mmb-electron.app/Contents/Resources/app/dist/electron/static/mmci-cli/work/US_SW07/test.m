function test()
    a = 5;
    b = [1, 2, 3];
    c = "Hello";
    saveAllInputs(a, b, c);

end

function saveAllInputs(varargin)
    % This function saves all input arguments to a .mat file

    % Create a structure to store all input arguments
    data = struct();

    % Loop through each input and save it to the structure
    for k = 1:length(varargin)
        argname = inputname(k);
        if isempty(argname)
            argname = ['input' num2str(k)];
        end
        data.(argname) = varargin{k};
    end

    % Save the structure to a .mat file
    filename = ['inputs_' datestr(now, 'yyyymmdd_HHMMSS') '.mat'];
    save(filename, '-struct', 'data');
    disp(['Saved inputs to: ' filename]);
end

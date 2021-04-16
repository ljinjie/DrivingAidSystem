function [y] = difFilter(x,y)
% Differentiates a signal
    
    % Check to make sure the signal has at least two data points
    if(size(x,2) < 2)
        y = [];
        
    else
        % Subtract the last data point by the second to last
        for r = 1:size(x,1)
            
            y(r,end+1) = x(r,end)-x(r,end-1);
            
        end
        
    end
    
    
    
end


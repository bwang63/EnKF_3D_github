function [err] = checkfunction(function_name)

% check for the existence of a function.  0 on success.
err = 1;
if exist(function_name) == 2
  err = 0;
end
return

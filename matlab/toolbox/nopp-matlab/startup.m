arango_tools = '/n0/arango/ocean/matlab';
disp([ 'Adding ' arango_tools ' to path'])
addpath(arango_tools,'-begin')
disp([ 'Executing ' arango_tools '/startup'])
startup

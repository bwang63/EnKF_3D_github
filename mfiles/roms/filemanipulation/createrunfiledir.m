function createrunfiledir(runfile, cddir, executable, infname, outfname, np, qname, templatefile, makeexec, stdoutname, stderrname)
% createrunfile(runfile, executable, infilename, outfilename, np, qname, templatefile, makeexec, stdoutname, stderrname)
% Creates a new executable file ready to be submitted to a queue.
% 
% INPUT
% runfile: the name of the new executable that is created.
% executable: the file that is executed in runfile.
% infilename: a file that serves as the input file to exectuable.
% outfilename: an output or log file name.
% np: the number of processors used for the MPI job.
% qname (optional): the queue name of the job.
% templatefile (optional): the name of an existing template runfile.
%    If the template file resides in its standard directory, the path to 
%    that directory may be omitted.


if ~exist(templatefile, 'file')
    error('Specified template file ''%s'' does not exist.', templatefile);
end
   
sedstr = sprintf('sed -e ''s|<<NP>>|%d|g'' -e ''s|<<EXECUTABLE>>|%s|g'' -e ''s|<<INFILE>>|%s|g'' -e ''s|<<OUTFILE>>|%s|g'' -e ''s|<<QNAME>>|%s|g'' -e ''s|<<DIR>>|%s|g'' -e ''s|<<STDOUT>>|%s|g'' -e ''s|<<STDERR>>|%s|g'' < %s > %s', ...
    np, executable, infname, outfname, qname, cddir, stdoutname, stderrname, templatefile, runfile);
[status msg] = system(sedstr);
if status ~= 0
    warning('Sed command failed with the following message:')
    fprintf('%s\n', msg)
end
    



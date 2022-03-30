FATHOM: A Matlab Toolbox for Ecological & Oceanographic Data Analysis

by Dave Jones<djones@rsmas.miami.edu>
http://www.rsmas.miami.edu/personal/djones

This toolbox is a collection of Matlab functions and scripts
I've written for my everyday use. I'm releasing them to the public
in order to encourage the sharing of code and prevent duplication
of effort. If you find these function useful, drop me a line.
I'd also appreciate bug reports and suggestions for improvements.

While I've made every attempt to write functions that provide accurate
and precise results, these files are provided as is, with no guarantees
and are only intended for non-commercial use. These routines have been 
developed and tested under Matlab 6.1 (Release 12.1) under Windows 2000.


-----INSTALLATION NOTES:-----

There is currently only one issue related to installation that you need to be aware of:

f_nmds: NonMetric Multidimensional Scaling

This function calls Mark Steyver's NMDS routine. For it to work
you must install his toolbox from:
http://www-psych.stanford.edu/~msteyver/programs_data/mdszip.zip

I've been able to obtain better results with this program by 
editing Steyver's mds.m file and changing

randn( 'state',seed ); 

to

rand( 'state',seed );

This allows you to draw from "Uniformly distributed random numbers" for initial
configurations rather than "Normally distributed random numbers".


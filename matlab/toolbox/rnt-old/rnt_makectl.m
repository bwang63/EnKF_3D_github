function ctl=rnt_makectl(prefix)

files = rnt_getfilenames('.',prefix);
ctl=rnt_timectl(files,'ocean_time');

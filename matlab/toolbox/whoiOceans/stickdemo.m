% STICKDEMO  This demo shows what you can do easily with STICKPLOT
%
%

% RP (WHOI) 15/Jan/91


% Fake a data set

date=1:100;

vx=[ filter(hamming(20),1,rand(1,100)-.5);
     filter(hamming(20),1,rand(1,100)-.5) ]';
vy=[ filter(hamming(20),1,rand(1,100)-.5);
     filter(hamming(20),1,rand(1,100)-.5) ]';

stickplot(date,vx,vy,[0 100],'unit',['series 1';'series 2']);

title('Everything done by STICKPLOT!');

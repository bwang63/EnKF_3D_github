function x_filt=lanczos(x,time,cutoff,hww)
% lanczos filter - filters data and plots raw and filtered time series
% x_filt=lanczos(x,time,cutoff,hww)
% input: x - vector or array of data
%        time - vector of sampling times
%        cutoff - cutoff time (in hours) close to half power point
%        hww - number of filter weights
% output:  x_filt - filtered data
sizer=size(x);
n_samples=sizer(1);
n_stations=sizer(2);
% time in hours
dt=(time(2)-time(1))*24.0;
iww=fix(hww/dt);
iww2=fix((iww-1)/2);
omega=(pi*2.0/cutoff)*dt;
con=2.0*pi/iww;
for k=1:n_stations
  H_o=omega/pi;
  for i=1:iww2
    x_filt(i,k)=0.0;
  end
  for i=n_samples-iww2+1:n_samples
    x_filt(i,k)=0.0;
  end
% compute window weights
  sum=H_o;
  for i=1:iww2
    H(i)=H_o*sin(i*omega)/(i*omega)*sin(i*con)/(i*con);
    sum=sum+2.0*H(i);
  end
  H_o=H_o/sum;
  for i=1:iww2
    H(i)=H(i)/sum;
  end
  for i=iww2+1:n_samples-iww2
    temp=H_o*x(i,k);
    for j=1:iww2
      temp=temp+(x(i+j,k)+x(i-j,k))*H(j);
    end
    x_filt(i,k)=temp;
  end
end
subplot(2,1,1);
if n_stations==1
plot(time,x,'r');
else
plot(time,x);
end
set(gca,'Xlim',[min(time) max(time)])
set(gca,'Ylim',[min(min(x)) max(max(x))])
title('Unfiltered data');
subplot(2,1,2);
if n_stations==1
plot(time,x_filt,'b');
else 
plot(time,x_filt);
end
set(gca,'Xlim',[min(time) max(time)])
set(gca,'Ylim',[min(min(x)) max(max(x))])
title('Filtered data')


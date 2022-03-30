%  Driver for 1D Advection Tests.

figure;
[X,F]=advdat('/e0/dale/icp/1D_adv/fort.71');
plot(X.a,F.a,'k:',X.b,F.b,'k-.',X.c,F.c,'k-',X.d,F.d,'k--');
set(gca,'Ylim',[-0.4 1.0]);
legend('(100,100)','(100,200)','(100,400)','(200,400)');
text(0.8,-0.3,'FTUS');
xlabel('x'); ylabel('u(x)');
%print -dps adv1.ps
print -deps adv1.eps

figure;
[X,F]=advdat('/e0/dale/icp/1D_adv/fort.72');
plot(X.a,F.a,'k:',X.b,F.b,'k-.',X.c,F.c,'k-',X.d,F.d,'k--');
set(gca,'Ylim',[-0.4 1.0]);
legend('(100,100)','(100,200)','(100,400)','(200,400)');
text(0.8,-0.3,'CTCS');
xlabel('x'); ylabel('u(x)');
%print -dps adv2.ps
print -deps adv2.eps

figure;
[X,F]=advdat2('/e0/dale/icp/1D_adv/fort.73');
plot(X.a,F.a,'k:',X.b,F.b,'k--',X.c,F.c,'k-');
set(gca,'Ylim',[-0.4 1.0]);
legend('(50,100)','(100,200)','(100,400)');
text(0.8,-0.3,'CTCS4');
xlabel('x'); ylabel('u(x)');
%print -dps adv3.ps
print -deps adv3.eps

figure;
[X,F]=advdat2('/e0/dale/icp/1D_adv/fort.74');
plot(X.a,F.a,'k:',X.b,F.b,'k-.',X.c,F.c,'k-',X.d,F.d,'k--');
set(gca,'Ylim',[-0.4 1.0]);
legend('(100,1000)','(100,200)','(100,400)','(200,400)');
text(0.8,-0.3,'TOUS');
xlabel('x'); ylabel('u(x)');
%print -dps adv4.ps
print -deps adv4.eps



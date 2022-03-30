%    REFERENCE
%    McCann, K., A.Hasting & G.Huxel, (1998) "Weak trophic interaction and
%    the balance of nature"
%         Nature 395,794-798
%    
           
clc
clear


 tr=input('# of iterations for loop : ');
  
   


D1=0.5e-3;%gm C m-3                                %initial conditions
K1=4.34e-7;%gm C m-3                              %initial conditions
S1=4.34e-7;%gm C m-3                              %initial conditions
P =4e-6; %gm C m-3

Ca=1.25;%gm C m-3                               %Constants

oK =0.5;                               %Constants
xK=5.14e-1; % krill respiration to biomass ratio
yK=1.1; % max prod to biomass ratio
rDK=3.0e-3;                       %half saturation constant

oS =0.5;                               %Constants
xS=5.14e-1; % salp respiration to biomass ratio
yS=1.1; % max prod to biomass ratio
rDS=3.0e-3;                       %half saturation constant

xP= 2.056e-1;
yP=.55;
rKP=4e-5;
rSP=4e-5;

tt=1;                                %Constants
ud=1;                               %logistic growth rate
uc=1;                               %logistic growth rate
positive=1;      % (0=false, 1=true)
maxiter=20;


format long e
% Initialize model and Iterative steps


D(1)=D1;
K(1)=K1;
S(1)=S1;


D_iter(1,1:3)=0;
K_iter(1,1:3)=0;
S_iter(1,1:3)=0;


% time step
time(1)=0;


for r=2:tr;


time(r) = time(r-1)  + tt;
   
%Back calculations 

if (positive),
  Db_bak(r) = max(D(r-1),0);
  Kb_bak(r) = max(K(r-1),0);
  Sb_bak(r) = max(S(r-1),0);
else,
  Db_bak(r) = D(r-1);
  Kb_bak(r) = K(r-1);
  Sb_bak(r) = S(r-1);
end,
D(r)=Db_bak(r);
K(r)=Kb_bak(r);
S(r)=Sb_bak(r);



% iterate


for iter= 1:maxiter;


%  Diatom growth    

D_iter(r,iter,1)=tt*ud*D(r)*(1-(D(r)/Ca));


% grazing by krill

D_iter(r,iter,2)=tt*xK*yK*K(r)*D(r)/...
   												(D(r)+ rDK);

%Grazing by salps                                    
D_iter(r,iter,3)=tt*xS*yS*S(r)*((rDS/D(r))*tanh(D(r)/rDS));
% D_iter(r,iter,3)=tt*xS*yS*S(r)*D(r)/...
   											%	(D(r)+ rDS);                                   
                                    
Diter(r,iter)=Db_bak(r)+D_iter(r,iter,1)-D_iter(r,iter,2)-D_iter(r,iter,3);  

D(r)=Diter(r,iter);


% calculate in successive order krill growth and grazing by predators;

K_frc(r)=1-yK*D(r)/(D(r)+rDK);
                                    
%K_iter(r,iter,1)=xK*K(r)*(1-yK*(D(r)/ ...
%            			(D(r)+rDK)));

K_iter(r,iter,1)=-xK*K(r)*K_frc(r);
                  
K_iter(r,iter,2)=xP*yP*(P*K(r)/(K(r)+rKP));
   
Kiter(r,iter)=Kb_bak(r) + K_iter(r,iter,1)- K_iter(r,iter,2); %+ K_iter(r,iter,1)*-.85;
   
K(r)=Kiter(r,iter) ;

% calculate Salp growth, grazing by predators ;

S_frc(r) = (yS*((D(r))/ ...
                       (D(r)+rDS)));


S_iter(r,iter,1)=tt*xS*S(r)*(1-S_frc(r));                    

S_iter(r,iter,2)=xP*yP* (P*S(r)/(S(r)+rSP));

Siter(r,iter)=Sb_bak(r) + S_iter(r,iter,1)- S_iter(r,iter,2); %+ S_iter(r,iter,1)*-.85;


S(r)=Siter(r,iter);

end  %end iterate;


   D(r)=max(D(r-1)-Db_bak(r)+D(r),0.00001);       
   K(r)=max(K(r-1)-Kb_bak(r)+K(r),0.00001);         
   S(r)=max(S(r-1)-Sb_bak(r)+S(r),0.00001);     
         
end % end time step
save D_iter D  K  K_iter S S_iter time;


figure;
plot(time,D,'r',time,K,'b',time,S,'g');
legend('Diatom','Krill','Salps',0);

figure;
plot(time, S, time, K);

   fclose('all');
   
%end                                                    %end for o=0:lo loop
%end                                                    %end for a=0:lo1 loop

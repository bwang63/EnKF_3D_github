% CSL_DEP Given a vector of real CSL levels, return depths (m)
%         CSL = CSIRO Standard Levels, a superset of Levitus standard levels

function [deps] = csl_dep(levels);

std_deps = [ 0; 10; 20; 30; 40; 50; 60; 70; 75; 80; 90; 100; 110; ...
        125; 150; 175; 200; 225; 250; 275; 300; 350; 400; 450; 500; ...
        550; 600; 650; 700; 750; 800; 850; 900; 950; 1000; 1100; ...
        1200; 1300; 1400; 1500; 1600; 1750; 2000; 2250; 2500; 2750; ...
        3000; 3250; 3500; 3750; 4000; 4250; 4500; 4750; 5000; 5500; ...
        6000; 6500; 7000; 7500; 8000; 8500; 9000];

lcsl = length(std_deps);

deps = NaN*ones(size(levels));

ii = find(levels<1);
if ~isempty(ii)
  deps(ii) = 1-levels(ii)*10;       % Hypothetical 10m levels above s.l.
  
  jj = find(levels>=1);
  if ~isempty(jj)
    deps(jj) = interp1(1:lcsl,std_deps,levels(jj));
  end
else
  ii = find(~isnan(levels));
  deps(ii) = interp1(1:lcsl,std_deps,levels(ii));
end

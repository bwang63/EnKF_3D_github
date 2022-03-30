function [eofs,eofs_coeff,varexp]=doEof(d2,varargin)

[I,J,imons]=size(d2);

if nargin > 1
   mask=varargin{1};
   d2=d2.*repmat(mask,[ 1 1 imons]);
end

  clear eofs eofs_coeff
  [I,J,T]=size(d2);
  eofs=zeros(I,J);
  dnew=reshape(d2,[I*J,T]);
  in=find(isnan(dnew(:,1)) == 0);
  dnew=dnew(in,:);
  
  dd=dnew'*dnew;
  % compute EOFs  
  %normalize
  %dd=dd./max(diag(dd));
  [A,D] = eig(dd);
  E=dnew*A;
  %size(E)
  %size(dnew)
  %size(A)
  %A=E*dnew;
  lambda=diag(D);
  modes=lambda/sum(lambda)*100;
  im=find(modes > -1);
  
  for i=length(im):-1:1
    m1=zeros(I,J); m1(:)=NaN;
    m1(in)=E(:,im(i));
    eofs(:,:,-i+1+length(im))=m1;
    eofs_coeff(:,-i+1+length(im))=A(:,im(i));
    varexp(-i+1+length(im))=modes(im(i));
  end


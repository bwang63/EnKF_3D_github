function [outlist, outvariablelist] = addvariables(inlist, ...
    invariablelist, newvariables, pos);
if ~isempty(invariablelist)
  addlen = size(newvariables,1);
  % add new colums to dataprops for new variables
  all_dataprops = cat(1,inlist(:).dataprops);
  s = size(all_dataprops);
  all_dataprops = [all_dataprops, zeros(s(1),addlen)];
  all_dataprops(pos,(s(2)+1):(s(2)+addlen)) = 1;
  invariablelist = str2mat(invariablelist, newvariables);
  % re-order variables so they are alphabetic
  tmplist = lower(invariablelist);
  [inx] = alphabet(tmplist);
  invariablelist = invariablelist(inx,:);
  all_dataprops = all_dataprops(:,inx);
  for i = 1:s(1)
    inlist(i).dataprops = all_dataprops(i,:);
  end
else
  addlen = size(newvariables,1);
  s = size(inlist,1);
  all_dataprops = zeros(s,addlen);
  all_dataprops(pos, :) = 1;
  invariablelist = newvariables;
  % re-order variables so they are alphabetic
  tmplist = lower(invariablelist);
  [inx] = alphabet(tmplist);
  invariablelist = invariablelist(inx,:);
  all_dataprops = all_dataprops(:,inx);
  for i = 1:s
    inlist(i).dataprops = all_dataprops(i,:);
  end
end

if nargout > 0
  outlist = inlist;
  outvariablelist = invariablelist;
end
return

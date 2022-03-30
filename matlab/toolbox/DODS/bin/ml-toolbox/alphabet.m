function inx = alphabet(list)

% alphabetize a string matrix

s = size(list);
inx = 1:s(1);
for k = s(2):-1:1
  [i j] = sort(list(:,k));
  list = list(j,:);
  inx = inx(j);
end
return

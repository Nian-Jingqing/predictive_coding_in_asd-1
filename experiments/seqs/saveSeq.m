function saveSeq()
% to keey the ASD and control group equal, we save the randomwalk sequence
% first
for i= 1:60
    w1 = genDurSeq(250,1);
    save(['seq', num2str(i)], 'w1');
end

%%
w = [];
for i=1:27
   load(['seq' num2str(i)]);
   figure;
   plot(w1);
   w = [w, w1];
end
figure;
hist(w);
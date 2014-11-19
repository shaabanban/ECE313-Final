% vim:noexpandtab tabstop=4

function [feature] = crosstab_f(dset1, dset2,H0,H1)
% The probabilities are divided by 100% to make the likelihood matrix.
% Zero extend the feature matrix so that H1 and H0 have the same size.
% Concatenate the golden and non-golden alarms to find their min/maxes.
max_val = max([
   dset1,dset2 ]);
min_val = min([dset1,dset2]);
dset1=tabulate(dset1);
dset2=tabulate(dset2);
cval=min_val;
result=zeros(max_val-min_val,5);
for i=1:(max_val-min_val)
      result(i,1)=cval;
 [~,idx]=ismember([cval],dset1(:,1),'rows');
  [~,idx2]=ismember([cval],dset2(:,1),'rows');
  if idx ~=0
    result(i,2)=dset1(idx,3)/100;
  end
    if idx2 ~=0
            result(i,3)=dset2(idx2,3)/100;
    end
     if result(i,2)>=result(i,3)
         result(i,4)=1;
         
     end
     if (result(i,2)*H1)>=(result(i,3)*H0)
         result(i,5)=1;
         
     end
    cval=cval+1;
end
feature=result;
end
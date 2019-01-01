input = inputshuffle(9200,:);
target = targetshuffledb2(9200,:);
output1 = net1(input');
output2 = net2(input');
output3 = net3(input');
a = (output1 + output2 + output3)/3;
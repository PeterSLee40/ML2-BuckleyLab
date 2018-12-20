TSG_db2_2_denoisedshort = single(csvread("TSG_db2_2_denoisedshort.csv"));
TSG_db2_2_denoisedlong = single(csvread("TSG_db2_2_denoisedlong.csv"));
TSG_db2_2_denoised = [TSG_db2_2_denoisedshort, TSG_db2_2_denoisedlong];
TSG_db2_2_target = single(csvread("TSG_db2_2_target.csv"));
TSG_db2_2_target1 = TSG_db2_2_target(2:end,:);
TSG_db2_2_input = single(csvread("TSG_db2_2_input.csv"));
TSG_db2_2_input1 = TSG_db2_2_input(2:end,:);
TSG_db2_2_inputnn = single(csvread("TSG_db2_2_inputnn.csv"));
TSG_db2_2_inputnn1 = TSG_db2_2_inputnn(2:end,:);
nnstart


plot(TSG_db2_2_denoised(2,:)); hold on;
plot(TSG_db2_2_input1(2,:));hold on;
plot(TSG_db2_2_inputnn1(2,:));
legend('de','noise','nn');

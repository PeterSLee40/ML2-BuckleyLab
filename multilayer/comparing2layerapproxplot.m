

difdbreshape = reshape(difdb, 429, 11);
difdbreshapem = mean(abs(difdbreshape),1);
difdbreshapes = std((difdbreshape),1);
errorbar(x,difdbreshapem,difdbreshapes);

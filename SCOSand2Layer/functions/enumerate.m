function combos=enumerate(numelem,taken_at_a_time)

subhandle = loopchoose(numelem,taken_at_a_time); % initialization call
p = nchoosek(numelem,taken_at_a_time);
combos = zeros(p,taken_at_a_time);

for i = 1:nchoosek(numelem,taken_at_a_time)
    combos(i,:) = subhandle(); % subsequent calls
end

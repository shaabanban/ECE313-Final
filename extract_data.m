% vim:noexpandtab tabstop=4

function [data_mean_area, data_mean_r2r, data_bpm, data_p2p, ...
    data_systolic, data_diastolic, data_pulse] = extract_data(data)
data_mean_area =	data(1,:);
data_mean_r2r =		data(2,:);
data_bpm =			data(3,:);
data_p2p =			data(4,:);
data_systolic =		data(5,:);
data_diastolic =	data(6,:);
data_pulse =		data(7,:);
end
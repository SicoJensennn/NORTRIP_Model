%Converts variables

%--------------------------------------------------------------------------
%Put binned data in integrated data. Inside road loop
%--------------------------------------------------------------------------
for x=1:num_size,
    M_road_data(:,x,:,:,ro)=sum(M_road_bin_data(:,x:num_size,:,:,ro),2);
    M_road_balance_data(:,x,:,:,:,ro) =sum(M_road_bin_balance_data(:,x:num_size,:,:,:,ro),2);
    E_road_data(:,x,:,:,:,ro)=sum(E_road_bin_data(:,x:num_size,:,:,:,ro),2);
    C_data(:,x,:,:,:,ro)=sum(C_bin_data(:,x:num_size,:,:,:,ro),2);
end

%Set concentration data to nodata when f_conc not available
r=find(f_conc(:,ro)==nodata);
C_data(:,:,:,r,:,ro)=nodata;


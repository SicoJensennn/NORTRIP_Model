%test_grid_lines
clear

n_grid=2;
x_grid(1,:)=[-1,1];
y_grid(1,:)=[-1,1];
x_grid(2,:)=[1,3];
y_grid(2,:)=[1,3];

line(1,:)=[.5,.5,1,2];%x1,y1,x2,y2
line(2,:)=[.5,0,-2,-0];%x1,y1,x2,y2
line(3,:)=[0,-0.2,-0,-2];%x1,y1,x2,y2
line(4,:)=[2,3,0.5,2];%x1,y1,x2,y2
line(5,:)=[-2,-3,1.5,1.5];%x1,y1,x2,y2
line(6,:)=[.7,-.9,.2,.7];%x1,y1,x2,y2
line(7,:)=[-1,-3,-1,+1];%x1,y1,x2,y2
line(8,:)=[-.5,-1,3,-1];%x1,y1,x2,y2
line(9,:)=[-.5,1,3,1];%x1,y1,x2,y2
line(10,:)=[1,-3,1,+0];%x1,y1,x2,y2
line(11,:)=[-.7,-3,-.7,+2];%x1,y1,x2,y2
line(12,:)=[.5,1.5,1.5,.6];%x1,y1,x2,y2
line(13,:)=[-1,1,1,-1];%x1,y1,x2,y2
line(14,:)=[-1,-1,1,1];%x1,y1,x2,y2
line(15,:)=[-1,1,1,1];%x1,y1,x2,y2
line(16,:)=[-1.5,.3,1.5,.3];%x1,y1,x2,y2
line(17,:)=[-3,2,1.5,-3];%x1,y1,x2,y2
line(18,:)=[-3,-2,1,1];%x1,y1,x2,y2
line(19,:)=[+3,-2,-1,1];%x1,y1,x2,y2
line(20,:)=[-3,0,1,-1];%x1,y1,x2,y2

n_line=size(line,1);

for l=1:n_line,
    x_line(l,1)=line(l,1);
    x_line(l,2)=line(l,3);
    y_line(l,1)=line(l,2);
    y_line(l,2)=line(l,4);
    length_line(l)=sqrt((x_line(l,1)-x_line(l,2))^2+(y_line(l,1)-y_line(l,2))^2);
end

clf
hold on
for g=1:n_grid;
for l=1:n_line,
    x_line_temp(1:2,1)=x_line(l,:);
    y_line_temp(1:2,1)=y_line(l,:);
    x_grid_temp(1:2,1)=x_grid(g,:);
    y_grid_temp(1:2,1)=y_grid(g,:);
    
    [f(l),x_int(l,:),y_int(l,:)]=grid_lines_func(x_grid_temp,y_grid_temp,x_line_temp,y_line_temp);
    fprintf('Line: %u  F: %6.4f\n',l,f(l));
end
    length_grid(g)=mean(f(1:n_line).*length_line(1:n_line));
    fprintf('Mean length: %u  F: %6.4f\n',g,length_grid(g));

    plot([x_grid(g,1),x_grid(g,1),x_grid(g,2),x_grid(g,2),x_grid(g,1)],...
        [y_grid(g,1),y_grid(g,2),y_grid(g,2),y_grid(g,1),y_grid(g,1)],'g','linewidth',2);
    for l=1:n_line,
        if g==1,
            plot([x_line(l,1),x_line(l,2)],[y_line(l,1),y_line(l,2)],'bx-');
        end
        plot(x_int(l,1),y_int(l,1),'ro');
        plot(x_int(l,2),y_int(l,2),'rs');
        plot([x_int(l,1),x_int(l,2)],[y_int(l,1),y_int(l,2)],'r:','linewidth',2);    
    end
    
end
    for l=1:n_line,
        text((x_line(l,1)+x_line(l,2))/2,(y_line(l,1)+y_line(l,2))/2,num2str(l));
    end


axis([-4 4 -4 4]);

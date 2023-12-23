%grid_lines_func
%returns the fraction of the road length that is in a grid
%x_grid(1:2),y_grid(1:2),x_line(1:2),y_line(1:2)

function [f,x_int,y_int] = grid_lines_func(x_grid,y_grid,x_line,y_line)

    if length(x_grid)~=2||length(y_grid)~=2||length(x_line)~=2||length(y_line)~=2,
        fprintf('Wrong dimensions in input data\n');
        return
    end
    
    length_line=sqrt((x_line(1)-x_line(2))^2+(y_line(1)-y_line(2))^2);
    f=0.;
    
    x_int(1:2)=NaN;
    y_int(1:2)=NaN;

    if length_line==0.
        return
    end
    
    dx=max(x_grid)-min(x_grid);
    dy=max(y_grid)-min(y_grid);
       
    %Check first for lines that cannot have an intersection
    if x_line(1)<x_grid(1)&&x_line(2)<x_grid(1),
        f=0.;
        return
    end
    if x_line(1)>=x_grid(2)&&x_line(2)>=x_grid(2),
        f=0.;
        return
    end
    if y_line(1)<y_grid(1)&&y_line(2)<y_grid(1),
        f=0.;
        return
    end
    if y_line(1)>=y_grid(2)&&y_line(2)>=y_grid(2),
        f=0.;
        return
    end

    %Check for lines that are completely inside the grid
    if (x_line(1)>=x_grid(1)&&x_line(2)>=x_grid(1))...
        &&(x_line(1)<x_grid(2)&&x_line(2)<x_grid(2))...
        &&(y_line(1)>=y_grid(1)&&y_line(2)>=y_grid(1))...
        &&(y_line(1)<y_grid(2)&&y_line(2)<y_grid(2)),
        f=1.;
        x_int=x_line;
        y_int=y_line;
        return
    end
        
    %Check for lines with the one of the nodes within
    for node=1:2,
        
        if node==1, anti_node=2;end
        if node==2, anti_node=1;end
                    
        if (x_line(node)>=x_grid(1)&&x_line(node)<x_grid(2))...
            &&(y_line(node)>=y_grid(1)&&y_line(node)<y_grid(2)),
            %This node is in the grid
            %fprintf('One node in grid\n');
            %Shift parallel and equal lines when they are on the grid edge
            if x_line(node)== x_line(anti_node)&&x_line(node)== x_grid(1),
               x_line=x_line+dx*1e-6; 
            end
            %Shift parallel and equal lines
            if y_line(node)== y_line(anti_node)&&y_line(node)== y_grid(1),
               y_line=y_line+dy*1e-6; 
            end
            
            %Can't intersect since it is parallel to the horizontal grid lines
            if y_line(node)~= y_line(anti_node),
            
                %Check intersection with the horizontal grid faces
                for node_y_grid=1:2,
                    x_temp=x_line(node)+(y_grid(node_y_grid)-y_line(node))*(x_line(anti_node)-x_line(node))/(y_line(anti_node)-y_line(node));
                    y_temp=y_grid(node_y_grid);
                    %if (x_temp>=x_grid(1)&&x_temp<x_grid(2)&&x_temp>=min(x_line)&&x_temp<=max(x_line)),
                    %fprintf('H NODE %u:%f %f %f %f %f %f \n',node,x_line(node),y_line(node),x_temp,y_temp,min(y_line),max(y_line));
                    if (y_temp>=min(y_line) && y_temp<=max(y_line) && y_temp~=y_line(node) && x_temp>=min(x_grid) && x_temp<=max(x_grid)),
                        y_int(anti_node)=y_grid(node_y_grid);
                        x_int(anti_node)=x_temp;
                        x_int(node)=x_line(node);
                        y_int(node)=y_line(node);
                        %fprintf('Here 1\n');
                        length_int=sqrt((x_int(node)-x_int(anti_node))^2+(y_int(node)-y_int(anti_node))^2);
                        f=length_int/length_line;                        
                        return
                    end
                end
            end
            
            %Can't intersect since it is parallel with the vertical grid lines
            if x_line(node)~= x_line(anti_node),
                
                %Check intersection with the vertical grid faces
                for node_x_grid=1:2,
                    y_temp=y_line(node)+(x_grid(node_x_grid)-x_line(node))*(y_line(anti_node)-y_line(node))/(x_line(anti_node)-x_line(node));
                    x_temp=x_grid(node_x_grid);
                    %if (y_temp>=y_grid(1)&&y_temp<y_grid(2)&&y_temp>=min(y_line)&&y_temp<=max(y_line)),
                    %fprintf('V NODE %u:%f %f %f %f %f %f \n',node,x_line(node),y_line(node),x_temp,y_temp,min(x_line),max(x_line));
                    if (x_temp>=min(x_line) && x_temp<=max(x_line) && x_temp~=x_line(node) && y_temp>=min(y_grid) && y_temp<=max(y_grid)),
                        x_int(anti_node)=x_grid(node_x_grid);
                        y_int(anti_node)=y_temp;
                        y_int(node)=y_line(node);
                        x_int(node)=x_line(node);
                        %fprintf('Here 2: \n');
                        length_int=sqrt((x_int(node)-x_int(anti_node))^2+(y_int(node)-y_int(anti_node))^2);
                        f=length_int/length_line;                        
                        return
                    end
                end
            end
        end
    
    end%node
    
    %Only posibility left is that both nodes are outside the grid
    %Find 2 intersections then
    n_intersection=0;
    node=1;
    anti_node=2;
        if y_line(node)~= y_line(anti_node), %Can't intersect since it is parallel            
            for node_y_grid=1:2,            
                %Check intersection with the horizontal grid faces
                    x_temp=x_line(node)+(y_grid(node_y_grid)-y_line(node))*(x_line(anti_node)-x_line(node))/(y_line(anti_node)-y_line(node));                    
                    y_temp=y_grid(node_y_grid);
                    %if (x_temp>=x_grid(1)&&x_temp<x_grid(2)&&x_temp>=min(x_line)&&x_temp<=max(x_line)),
                    if (y_temp>=min(y_line) && y_temp<=max(y_line) && x_temp>=min(x_grid) && x_temp<=max(x_grid) && n_intersection<2),
                        n_intersection=n_intersection+1;
                        y_int(n_intersection)=y_temp;
                        x_int(n_intersection)=x_temp;
                        %fprintf('Here 3: %u %u\n',n_intersection,node_y_grid);
                    end              
            end
        end
        if x_line(node)~= x_line(anti_node), %Can't intersect since it is parallel
            for node_x_grid=1:2,
                    y_temp=y_line(node)+(x_grid(node_x_grid)-x_line(node))*(y_line(anti_node)-y_line(node))/(x_line(anti_node)-x_line(node));
                    x_temp=x_grid(node_x_grid);
                    %if (y_temp>=y_grid(1)&&y_temp<y_grid(2)&&y_temp>=min(y_line)&&y_temp<=max(y_line)),
                    % Use y_temp<max(y_grid) incase it is in one of the corners
                    if (x_temp>=min(x_line) && x_temp<=max(x_line) && y_temp>=min(y_grid) && y_temp<max(y_grid) && n_intersection<2),
                        n_intersection=n_intersection+1;
                        x_int(n_intersection)=x_temp;
                        y_int(n_intersection)=y_temp;
                        %fprintf('Here 4: %u %u\n',n_intersection,node_x_grid);
                    end                
            end
         end
      
    if n_intersection==2,
        length_int=sqrt((x_int(node)-x_int(anti_node))^2+(y_int(node)-y_int(anti_node))^2);
        f=length_int/length_line;
        %fprintf('N intersections = %u\n',n_intersection);
    elseif n_intersection==1,
        %fprintf('Error: Number of intersections should be 2 but is = %u\n',n_intersection);
        %Do nothing as this means one node is on the edge and f=0
    end
    
            
    
end


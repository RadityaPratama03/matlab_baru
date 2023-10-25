    % Code: AODV Routing
    x = 1:20;
    s1 = x(1);
    d1 = x(20);
    clc;
    xy_array = rand(20);
    % Making matrix all diagonals=0 and xy_array(i,j)=xy_array(j,i), i.e. xy_array(1,4)=xy_array(4,1),
    % xy_array(6,7)=xy_array(7,6)
    for i = 1:20
        for j = 1:20
            if i == j
                xy_array(i, j) = 0;
            else
                xy_array(j, i) = xy_array(i, j);
            end
        end
    end
    disp(xy_array);
    t = 1:20;
    disp(t);
    
    disp(xy_array);
    status(1) = '!';
    dist(2) = 0;
    next(1) = 0;
    
    for i = 2:20
        status(i) = '?';
        dist(i) = xy_array(i, 1);
        next(i) = 1;
        disp(['i == ' num2str(i) ' xy_array(i,1) = ' num2str(xy_array(i, 1)) ' status: = ' status(i) ' dist(i) = ' num2str(dist(i))]);
    end
    
    flag = 0;
    for i = 2:20
        if xy_array(1, i) == 1
            disp([' Node 1 sends RREQ to node ' num2str(i)]);
            if i == 20 && xy_array(1, i) == 1
                flag = 1;
            end
        end
    end
    disp(['Flag = ' num2str(flag)]);
    while (1)
        if flag == 1
            break;
        end
        temp = 0;
        for i = 1:20
            if status(i) == '?'
                D = dist(i);
                vert = i;
                break;
            end
        end
        for i = 1:20
            if D > dist(i) && status(i) == '?'
                D = dist(i);
                vert = i;
            end
        end
        status(vert) = '!';
        for i = 1:20
            if status() == '!'
                temp = temp + 1;
            end
        end
        if temp == 20
            break;
        end
    end
    i = 20;
    count = 1;
    route(count) = 20;
    while next(i) ~= 1
        disp([' Node ' num2str(i) ' sends RREP message to node ' num2str(next(i))]);
        i = next(i);
        count = count + 1;
        route(count) = i;
%         route(count) = i;
    end
    disp([ ' Node ' num2str(i) ' sends RREP to node 1']);
    disp(' Node 1 ');
    for i = count: -1:1
        disp([ ' Sends message to node ' num2str(route(i))]);
    end

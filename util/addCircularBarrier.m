function layout = addCircularBarrier(layout)
%ADDCIRCULARBARRIER Adds barriers to the layout so that a circular plate is
%formed

mask = layout.barrier;
for i = 1:layout.xdim
    for j = 1:layout.ydim
        [bar, dist] = distFromCenter(layout,i,j);
        mask(i,j) = mask(i,j) | bar;
    end
end
layout = applyBarrierMask(layout,mask);

end

function [bar, dist] = distFromCenter(layout,x,y)
%return whether an input coordinate is far enough from the center that it
%should be a barrier, and the euclidian distance
cx = floor(layout.xdim/2);
cy = floor(layout.ydim/2);
r = min(cx,cy);
dx = floor(abs(x - cx));
dy = floor(abs(y - cy));
dist = sqrt((dx^2) + (dy^2));
bar = dist > r;
end
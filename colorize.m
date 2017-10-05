# Copy-modified from "Computational Colour Science using MATLAB 2e"
# code, available in
# http://www.mathworks.com/matlabcentral/fileexchange/40640-computational-colour-science-using-matlab-2e?focused=3779480&tab=function

function colorize(x_in, y_in)
  assert(length(x_in) == length(y_in));

  # Throw away K-1 input samples, for speed.
  K = 2
  x = x_in(1:K:length(x_in));
  y = y_in(1:K:length(y_in));
  N = length(x);
  # Output matrix of xy coordinates and corresponding rgb color.
  xyrgb = zeros(N*steps*4, 5, 'double');

  # "center" of the radial slices, coordinates: {e, e}
  e = 0.4;
  # Amount of radial steps, i.e. from center to outside line.
  steps = 4;

  i = 1;  
  for w = 1:N                                  % wavelength
    w2 = mod(w, N)+1;
    a1 = atan2(y(w)  -e, x(w)  -e);            % start angle
    a2 = atan2(y(w2) -e, x(w2) -e);            % end angle
    r1 = ((x(w)  - e)^2 + (y(w)  - e)^2)^0.5;  % start radius
    r2 = ((x(w2) - e)^2 + (y(w2) - e)^2)^0.5;  % end radius
    for c = 1:steps                            % colourfulness
      % patch polygon
      xyz(1,1) = e+r1*cos(a1)*c/steps;
      xyz(1,2) = e+r1*sin(a1)*c/steps;
      xyz(1,3) = 1 - xyz(1,1) - xyz(1,2);
      
      xyz(2,1) = e+r1*cos(a1)*(c-1)/steps;
      xyz(2,2) = e+r1*sin(a1)*(c-1)/steps;
      xyz(2,3) = 1 - xyz(2,1) - xyz(2,2);
      
      xyz(3,1) = e+r2*cos(a2)*(c-1)/steps;
      xyz(3,2) = e+r2*sin(a2)*(c-1)/steps;
      xyz(3,3) = 1 - xyz(3,1) - xyz(3,2);
      xyz(4,1) = e+r2*cos(a2)*c/steps;
      xyz(4,2) = e+r2*sin(a2)*c/steps;
      xyz(4,3) = 1 - xyz(4,1) - xyz(4,2);
      % compute sRGB for vertices
      rgb = xyz2srgb(xyz');
      % store the results
      xyrgb(i:i+3, 1:2) = xyz(:,1:2);
      xyrgb(i:i+3, 3:5) = rgb';
      i = i + 4;
    end
  end
  
  [rows cols] = size(xyrgb);
  for i = 1:4:rows
    patch(xyrgb(i:i+3 ,1), xyrgb(i:i+3 ,2), 'FaceVertexCData', xyrgb(i:i+3,3:5),
	  'Edgecolor', 'none', 'FaceColor', 'interp');
  end

end


function [rgb] = xyz2srgb(xyz)
    M = [ 3.2406 -1.5372 -0.4986; -0.9689 1.8758 0.0415; 0.0557 -0.2040 1.0570 ];
    [rows cols ] = size(xyz);
    rgb = M*xyz;
    for c = 1:cols
        for ch = 1:3
            if rgb(ch,c) <= 0.0031308
                rgb(ch,c) = 12.92*rgb(ch,c);
            else
                rgb(ch,c) = 1.055*(rgb(ch,c)^(1.0/2.4)) - 0.055;
            end
            % clip RGB
            if rgb(ch,c) < 0
                rgb(ch,c) = 0;
            elseif rgb(ch,c) > 1
                rgb(ch,c) = 1;
            end
        end
    end
end

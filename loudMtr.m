 function [y,yDB] = loudMtr( x )

y = log10( sqrt(smooth(x.^2,44100*0.2)) );
%y = log10( sqrt(x.^2) );
%y(y<-100) = -100;

yDB = log10( sqrt(mean(x.^2)) );

if isnan( yDB )
    keyboard;
end

filename = 'noisemovie.gif';
picnames = dir('*BMP');

for n = 1 : length(picnames) - 1
      nstr = num2str(n);
      nstr = ['a' nstr '.BMP'];
      im = imread(nstr);
      [imind,cm] = rgb2ind(im,256);
      if n == 1;
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
      else
          imwrite(imind,cm,filename,'gif','WriteMode','append');
      end
end
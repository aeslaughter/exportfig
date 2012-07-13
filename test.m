% A test script for exportfig.m

% Create a plot (see "doc plot3")
t = 0:pi/50:10*pi;
plot3(sin(t),cos(t),t)
xlabel('sin(t)')
ylabel('cos(t)')
zlabel('t')
grid on
axis square

% Export the figure, this will create a pdf to look exactly like the figure
exportfig(gcf, 'test.fig', 'test.pdf');

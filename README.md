Gdarley
https://gurtd.github.io/hw05-road-generation/

For both the terrain and population density I used fbm. For the terrain the lighter the color
the higher the elevation, and for the population the dark the color the greater the 
population. I didnt have time to add a switch for the user to set which of the two to see, so 
instead I simply made the screen transition between the two over time. The green is the 
terrain (with blue being the water), and the purple is the population density. 

For my lsystem, I modified it from before to simply be one head that starts at a random 
point, designated in the main when construction the lsystem, and I expand from that point 
onwards to create the main road. Each part of the road is saved as an edge, of which are all 
stored in a set of edges (with an edge being made up of two points). In the lsystem, I keep 
track of the head and at each call to expand I have the head make a new point 0.05 away from 
it, but scan for the point with the highest population, by changing the angle the new point 
is from its start. In the case of my lsystem, it scans 7 points in front of it at various 
angles, and what ever has the highest population density is the next point and a new edge is 
created from the starting point and the new point, it also saves the angle that made the end 
point. As for the grid part of my road, I take every third edge ive made, and branch off and 
make the grid streets. I do this by calling a function that creates 3 offshoot roads, at 
angles of 0 90 and 180 from the original edge. It then calls itself recursively to further 
deepen the grid. Finally to draw the roads, I iterate though all the edges I have, and get 
the start point, use its coordinates to make a translation matrix for where the drawn road 
segment will start, and then takes the rotation angle saved from before to rotate the 
segment. I then do this for all edges and send each transformation matrix to the instanced 
shader to draw.


For the gui, I give the parameters of number of iterations of the main road, the recursion 
depth of the grid road creation, and an angle modifier used to scale the search angles for 
the main road expansion mentioned earlier. I didn't have time to do the road intersection 
part unfortunately

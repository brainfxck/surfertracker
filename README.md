# surfertracker
Basically a surfing tracker. The goal is to make a script which will constantly record a player's movements in order try and find some reccurent patterns among them.
Currently, it works by turning the positions into paths. The paths's length can be adjusted with the convars, as well as the distance between each position inside the path.
Then it stores the paths. Every time a path is about to be stored, it checks if the path is similar to a previous one, and if it is it'll increment a number to see how many times a reccurency occured for a specific path.
The tricky part is sorting out the paths which should be drawn and the others which shouldn't, which I haven't really figured out yet.

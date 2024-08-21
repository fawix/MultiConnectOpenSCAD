/*Created by Andy Levesque
Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution
*/

/* [Internal Dimensions] */
//Height (in mm) from the top of the back to the base of the internal floor
internalHeight = 50.0; //.1
//Width (in mm) of the internal dimension or item you wish to hold
internalWidth = 50.0; //.1
//Length (i.e., distance from back) (in mm) of the internal dimension or item you wish to hold
internalDepth = 40.0; //.1

/* [Shelf Customizations] */
//Distance upward from the bottom (in mm) that captures the bottom front of the item
rimHeight = 3;
bracket_style = "45deg"; //[45deg,half_distance,none]

/* [Additional Customization] */
//Thickness of bin walls (in mm)
wallThickness = 3; //.1
//Thickness of bin  (in mm)
baseThickness = 3; //.1

/*[Slot Customization]*/
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;
//QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale of slots in the back (1.015 scale is default per MultiConnect specs)
slotTolerance = 1.00; //[0.925:0.005:1.075]
//Move the slot in (positive) or out (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]


/* [Hidden] */
//Thickness of the back of the item (default in 6.5mm). Changes are untested. 
backThickness = 6.5; //.1
//profile coordinates for the multiconnect slot
slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]];


//Calculated
totalHeight = max(internalHeight+baseThickness,25);
totalDepth = internalDepth + backThickness + wallThickness;
totalWidth = max(internalWidth + wallThickness*2,25);
productCenterX = internalWidth/2;
//slot count calculates how many slots can fit on the back. Based on internal width for buffer.
slotCount = floor(totalWidth/distanceBetweenSlots);
echo(str("Slot Count: ",slotCount));

//move to center
translate(v = [-totalWidth/2,0,-baseThickness]) 
    multiconnectBack(backWidth = totalWidth, backHeight = totalHeight);
translate(v = [-internalWidth/2,0,0]) 
    //Basket minus slots
    difference() {
        shelf();
            //delete tool for anything above the product (i.e., bracket fix)
        color("red") translate(v = [-wallThickness-1 ,-1,internalHeight]) cube([totalWidth+2,totalDepth+2,totalHeight]); 
    }

//Create Basket
module shelf() {
    union() {
        //bottom
        translate([-wallThickness,0,-baseThickness])
            cube([internalWidth + wallThickness*2, internalDepth + wallThickness,baseThickness]);

        //left wall
        translate([-wallThickness,0,0])
            cube([wallThickness, internalDepth + wallThickness, rimHeight]);

        //right wall
        translate([internalWidth,0,0])
            cube([wallThickness, internalDepth + wallThickness, rimHeight]);

        //front wall
        translate([0,internalDepth,0]) 
            cube([internalWidth,wallThickness,rimHeight]);

        bracketDistance = min(internalHeight/2,internalDepth/2);
        echo(str("Bracket Distance: ",bracketDistance));
        
        //shelf brackets      
        if (bracket_style == "half_distance") {
            translate(v = [0,0,internalHeight/2+rimHeight])
                shelfBracket(bracketHeight = internalHeight/2, bracketDepth = internalDepth/2);
            translate(v = [internalWidth+wallThickness,0,internalHeight/2+rimHeight])
                shelfBracket(bracketHeight = internalHeight/2, bracketDepth = internalDepth/2);
        }
        if (bracket_style == "45deg"){
            translate(v = [0,0,bracketDistance+rimHeight])
                shelfBracket(bracketHeight = bracketDistance, bracketDepth = bracketDistance);
            translate(v = [internalWidth+wallThickness,0,bracketDistance+rimHeight])
                shelfBracket(bracketHeight = bracketDistance, bracketDepth = bracketDistance);
        }
    }
            
}

//BEGIN MODULES
//Slotted back
module multiconnectBack(backWidth, backHeight)
{
    difference() {
        translate(v = [0,-6.5,0]) cube(size = [backWidth,6.5,backHeight]);
        //Loop through slots and center on the item
        //Note: I kept doing math until it looked right. It's possible this can be simplified.
        for (slotNum = [0:1:slotCount-1]) {
            translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-13]) {
                color(c = "red")  slotTool(backHeight);
            }
        }
    }
    //Create Slot Tool
    module slotTool(totalHeight) {
        scale(v = slotTolerance)
        difference() {
            union() {
                //round top
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = slotProfile);
                //long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0]) 
                    linear_extrude(height = totalHeight+1) 
                        union(){
                            polygon(points = slotProfile);
                            mirror([1,0,0])
                                polygon(points = slotProfile);
                        }
            }
            //dimple
            if (slotQuickRelease == false)
                scale(v = dimpleScale) 
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = [[0,0],[0,1.5],[1.5,0]]);
        }
    }
}

module shelfBracket(bracketHeight, bracketDepth){
        rotate(a = [-90,0,90]) 
            linear_extrude(height = wallThickness) 
                polygon([[0,0],[0,bracketHeight],[bracketDepth,bracketHeight]]);
}
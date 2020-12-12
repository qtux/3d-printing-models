module SphereFeet (sphereAngle) {
	difference() {
		rotate(-sphereAngle, [0,1,0]) {
			translate([0,0,-16]) { //-22.4
				difference() {
					translate([0,3,0]) {
					sphere(r = 20, $fn=200); //d=42
					}
					translate([0,0,20+1000/2]) {
						cube(size = 1000, center = true);
					}
				}
			}
		};
		rotate(-9, [1,0,0]) {
			rotate(90, [1,0,0]) {
				cylinder(h = 100, d = 49, center = true, $fn=200);
			}
		}
	}
}

rotate(-90+9, [1,0,0]) {
		SphereFeet(-50);
		SphereFeet(50);
	rotate(-9, [1,0,0]) {
		rotate(90, [1,0,0]) {
			difference() {
				cylinder(h = 44.8+2.2, d = 49, center = true, $fn=200);
				translate([0,0,2.2]) {
					cylinder(h = 44.8, d = 43, center = true, $fn=200);
				}
			}
		}
	}
}
//translate([0,50,0]){cube([2,2,44.8+2.2], center = true);}
//translate([0,50,0]){cube([51,2,2], center = true);}
//rotate(9, [1,0,0]){translate([0,-30,0]){cube([2,2,100], center = true);}}
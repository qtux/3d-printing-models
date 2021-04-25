cover_diameter = 22;
cover_thickness = 0.4;

screw_diameter = 2.8;

difference() {
	//cylinder(h=cover_thickness, d=cover_diameter, $fn=200);
	hull()
		rotate_extrude(convexity = 10, $fn=200)
			translate([(cover_diameter)/2, 0, 0])
				circle(d=cover_thickness*2, $fn=200);
	// screw hole
	cylinder(h=cover_thickness+1, d=screw_diameter, $fn=200);
	// slice
	cut_thickness = 0.1; // smallest possible with PrusaSlicer
	translate([-cut_thickness/2, 0, 0])
		cube([cut_thickness,cover_diameter,cover_thickness+1]);
	// cut lower donut part
	translate([0,0,-cover_thickness])
		cylinder(h=cover_thickness,d=cover_diameter*2);
}
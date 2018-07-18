// Compact direct drive bowden extruder for 1.75mm filament
// Licence: CC BY-SA 3.0, http://creativecommons.org/licenses/by-sa/3.0/
// Author: Dominik Scholz <schlotzz@schlotzz.com> and contributors
// Using MK8 style hobbed pulley 13x8mm from: https://www.reprapsource.com/en/show/6889
// visit: http://www.schlotzz.com
// changed: 2014-04-04, added idler slot and funnel on bowden side for easier filament insertion
// changed: 2014-04-27, placed base and idler "printer ready"
// changed: 2014-09-22, fixed non-manifold vertexes between base and filament tunnel
// changed: 2014-11-13, added bowden inlet
// changed: 2015-03-17, updated idler for better MK7 drive gear support
// changed: 2015-10-13, designed alternative idler to solve breaking of bearing support

// changed: 2017-09-14, several improvements, see git log
// changed: 2017-11-09, several improvements, see git log
// changed: 2017-11-18, several improvements, see git log
// changed: 2017-11-30, several improvements, see git log
// changed: 2018-05-30, see git log
// changed: 2018-06-09, +idler_mount_hole_depth
// changed: 2018-07-17, +idler handle
// changed: 2018-07-18, +idler handle fix

/*
	design goals:
	- use 13x8mm hobbed pulley (mk8) or 13x12mm (mk7)
	- filament diameter parametric (1.75mm or 3mm)
	- use 608zz bearing
	- use M5 push fit connector
*/

direction_invert = false;
generate_idler = true;
generate_extruder = true;
generate_holder = true;
idler_mount_hole_depth = 4;

// avoid openscad artefacts in preview
epsilon = 0.01;

// increase this if your slicer or printer make holes too tight
extra_radius = 0.1;
bearing_extra_radius = 0;

// major diameter of metric 3mm thread
m3_major = 3;
m3_radius = m3_major / 2 + extra_radius;
m3_wide_radius = m3_major / 2 + extra_radius + 0.2;

m4_major = 4;
m4_radius = m4_major / 2 + extra_radius;
m4_wide_radius = m4_major / 2 + extra_radius + 0.2;

// diameter of metric 3mm hexnut screw head
m3_head_radius = 3 + extra_radius;
m4_head_radius = 4 + extra_radius;

// drive gear
drive_gear_outer_radius = 9.00 / 2;
drive_gear_hobbed_radius = 7 / 2;
drive_gear_hobbed_offset = 3.35;
drive_gear_hexscrew_offset = 8.5;
drive_gear_length = 11;
drive_gear_tooth_depth = 0.2;
drive_gear_hole = drive_gear_outer_radius + 1 + extra_radius;

//push fit connector
//pushfit_radius = 2.55;    //M6
pushfit_radius = 3;    //M5 insert nut
pushfit_depth = 6;     //M5 insert nut
pushfit_house_width = 2;
pushfit_length_offset = 6;

idler_bearing_screw_hole_radius = 1.8;  //2.5 for M5, 1.8 for M4
idler_bearing_screw_hole_radius2 = 2;   //2.5 for M5, 2 for M4

// base width for frame plate
base_width = 15;
base_length = 64;
body_thickness = 9;

base_thickness = 6;

// nema 17 dimensions
nema17_width = 42.3;
nema17_hole_offsets = [
	[-15.5, -15.5, 4],
	[-15.5,  15.5, 4],
	[ 15.5, -15.5, 4],
	[ 15.5,  15.5, 3 + body_thickness]
];

// inlet type
inlet_type = 1; // 0:normal, 1:push-fit


// filament
filament_diameter = 1.75; // 1.75, 3.00
filament_extra_radius = filament_diameter / 2 + 2 * extra_radius + 0.2;
filament_offset = [
	drive_gear_hobbed_radius + filament_diameter / 2 - drive_gear_tooth_depth,
	0,
	body_thickness + drive_gear_length - drive_gear_hobbed_offset - 2.5
];





// helper function to render a rounded slot
module rounded_slot(r = 1, h = 1, l = 0, center = false)
{
	hull()
	{
		translate([0, -l / 2, 0])
			cylinder(r = r, h = h, center = center);
		translate([0, l / 2, 0])
			cylinder(r = r, h = h, center = center);
	}
}


// mounting plate for nema 17
module nema17_mount()
{
	// settings
	width = nema17_width;
	height = body_thickness;
	edge_radius = 27;

	difference()
	{
		// base plate
		translate([0, 0, height / 2])
			intersection()
			{
				cube([width, width, height], center = true);
				cylinder(r = edge_radius, h = height + 2 * epsilon, $fn = 128, center = true);
			}
		
		// center hole
		translate([0, 0, -epsilon])
			cylinder(r = 11.25 + extra_radius, h = 3 + 2 * epsilon, $fn = 32);

		translate([0, 0, 3])
			cylinder(r1 = 11.25 + extra_radius, r2 = drive_gear_hole, h = body_thickness - 3 , $fn = 32);

		// axle hole
		translate([0, 0, -epsilon])
			cylinder(r = drive_gear_hole, h = height + 2 * epsilon, $fn = 32);

		// mounting holes
		for (a = nema17_hole_offsets)
			translate(a)
			{
				cylinder(r = m3_radius, h = height * 4, center = true, $fn = 16);
				cylinder(r = m3_head_radius, h = height + epsilon, $fn = 16);
			}
	}
}


// plate for mounting extruder on frame
module frame_mount()
{
	// settings
	width = base_width;
	length = base_length;
	height = base_thickness;
	hole_offsets = [
		[0,  length / 2 - 6, height / 2],
		[0, -length / 2 + 6, height / 2]
	];
	corner_radius = 3;

	difference()
	{
		// base plate
		intersection()
		{
			union()
			{
				translate([0, 0, height / 2])
					cube([width, length, height], center = true);
                // base for fillet
				translate([base_width / 2 - body_thickness / 2 - corner_radius / 2, 0, height + corner_radius / 2])
					cube([body_thickness + corner_radius, nema17_width, corner_radius], center = true);
                // nema17 base connector
				translate([base_width / 2 - body_thickness / 2, 0, 6 / 2 + height])
					cube([body_thickness, nema17_width, 6], center = true);
			}

            // slightly rounded corners of the mounting plate
			cylinder(r = base_length / 2, h = 100, $fn = 32);
		}

		// rounded corner
		translate([base_width / 2 - body_thickness - corner_radius, 0, height + corner_radius])
			rotate([90, 0, 0])
				cylinder(r = corner_radius, h = nema17_width + 2 * epsilon, center = true, $fn = 32);

		// mounting holes
		for (a = hole_offsets)
			translate(a)
			{
				cylinder(r = m4_wide_radius, h = height + 2 * epsilon, center = true, $fn = 16);
                translate([0, 0, height - 3])
                    cylinder(r = m4_head_radius, h = height + 2 * epsilon, center = true, $fn = 16);
			}

		// nema17 mounting holes
		translate([base_width / 2, 0, nema17_width / 2 + height])
			rotate([0, -90, 0])
			for (a = nema17_hole_offsets)
				translate(a)
				{
					cylinder(r = m3_radius, h = body_thickness * 4, center = true, $fn = 16);
					cylinder(r = m3_head_radius, h = body_thickness + epsilon, $fn = 16);
				}
	}
}


// inlet for filament
module filament_tunnel()
{
	// settings
	width = 8;
	length = nema17_width;
	height = filament_offset[2] - body_thickness + 4;

	translate([0, 0, height / 2])
	{
		difference()
		{
			union()
			{
				// base
				translate([-height / 2, 0, 0])
					cube([width + height, length, height], center = true);

				// Pushfit support
				translate([0, 0, -height / 2 + filament_offset[2] - body_thickness])
				{
					translate([0, -nema17_width/2, 0])
						rotate([90, 0, 90])
							pushfit_support();

					translate([0, nema17_width/2, 0])
						rotate([90, 0, -90])
							pushfit_support();
				}

				// idler tensioner
				intersection()
				{
					translate([5, -length / 2 + 8, 0])
						cube([width, 16, height], center = true);
					translate([-17.8, -20 ,0])
						cylinder(r = 27, h = height + 2 * epsilon, center = true, $fn = 32);
				}

			}

			// middle cutout for drive gear
			translate([-filament_offset[0], 0, 0])
				cylinder(r = drive_gear_hole, h = height + 2 * epsilon, center = true, $fn = 32);

			// middle cutout for idler
			translate([11 + filament_diameter / 2, 0, 0])
				cylinder(r = 12.5, h = height + 2 * epsilon, center = true, $fn = 32);

			// idler mounting hexnut
			translate([filament_diameter + 0.5, -nema17_width / 2 + 4, .25])
				rotate([0, 90, 0])
					cylinder(r = m3_radius, h = 50, center = false, $fn = 32);

			hex_thick = 2.5 + 3 * extra_radius;
			hex_width = 5.5 + 2.5 * extra_radius;
			translate([filament_diameter + 3, -nema17_width / 2 + 4, 5])
				cube([hex_thick, hex_width, 10], center = true);
			translate([filament_diameter + 3, -nema17_width / 2 + 4, 0])
				rotate([0, 90, 0])
					cylinder(r = hex_width / sqrt(3), h = hex_thick, center = true, $fn = 6);
			
			// rounded corner
			translate([-height - width / 2 - 1, 0, height / 2])
				rotate([90, 0, 0])
					cylinder(r = height, h = length + 2 * epsilon, center = true, $fn = 32);
			
			// funnnel inlet
			if (inlet_type == 0)
			{
				// normal type
				translate([0, -length / 2 + 1 - epsilon, -height / 2 + filament_offset[2] - body_thickness])
					rotate([90, 0, 0])
						cylinder(r1 = filament_extra_radius, r2 = filament_extra_radius + 1 + epsilon / 1.554,
							h = 3 + epsilon, center = true, $fn = 16);
			}
			else
			{
				// inlet push fit connector m* hole
				translate([0, -(length - pushfit_depth) / 2 - pushfit_length_offset - epsilon, -height / 2 + filament_offset[2] - body_thickness])
					rotate([90, 0, 0])
						cylinder(r = pushfit_radius, h = pushfit_depth + 2 * epsilon, center = true, $fn = 32);

				// funnel inlet outside
				translate([0, -length/ 2 - pushfit_length_offset + pushfit_depth, -height / 2 + filament_offset[2] - body_thickness])
					rotate([90, 0, 0])
						cylinder(r1 = filament_extra_radius, r2 = filament_extra_radius + 1,
							h = 2, center = true, $fn = 16);

			}

			// funnnel inside
			translate([0, 0, -height / 2 + filament_offset[2] - body_thickness])
				union () {
					rotate([90, 0, 0])
						cylinder(r1 = filament_extra_radius + 1.25, r2 = filament_extra_radius, h = 8, $fn = 16);
					rotate([-90, 0, 0])
						cylinder(r1 = filament_extra_radius + 1.25, r2 = filament_extra_radius, h = 8, $fn = 16);
				}

			// outlet push fit connector m* hole
			translate([0, (length - pushfit_depth) / 2 + pushfit_length_offset + epsilon, -height / 2 + filament_offset[2] - body_thickness])
				rotate([90, 0, 0])
					cylinder(r = pushfit_radius, h = pushfit_depth + 2 * epsilon, center = true, $fn = 32);

			// funnel outlet outside
			translate([0, length / 2 + pushfit_length_offset - pushfit_depth, -height / 2 + filament_offset[2] - body_thickness])
				rotate([90, 0, 0])
					cylinder(r1 = filament_extra_radius + 1, r2 = filament_extra_radius,
						h = 2, center = true, $fn = 16);

			// filament path
			translate([0, 0 - pushfit_length_offset, -height / 2 + filament_offset[2] - body_thickness])
				rotate([90, 0, 0])
					cylinder(r = filament_extra_radius,
						h = length + 2 * epsilon + 2 * pushfit_length_offset, center = true, $fn = 16);
			
			// screw head inlet
			translate(nema17_hole_offsets[2] - [filament_offset[0], 0, height / 2 + nema17_hole_offsets[2][2]])
				sphere(r = m3_head_radius, $fn = 32);
			
		}
	}
}


// render drive gear
module drive_gear()
{
	r = drive_gear_outer_radius - drive_gear_hobbed_radius;
	rotate_extrude(convexity = 10)
	{
		difference()
		{
			square([drive_gear_outer_radius, drive_gear_length]);
			translate([drive_gear_hobbed_radius + r, drive_gear_length - drive_gear_hobbed_offset])
				circle(r = r, $fn = 16);
		}
	}
}


// render 608zz
module bearing_608zz()
{
	difference()
	{
		cylinder(r = 11, h = 7, center = true, $fn = 32);
		cylinder(r = 4, h = 7 + 2 * epsilon, center = true, $fn = 16);
	}
}


// idler with 608 bearing, simple version
module idler_608_v1()
{
	// settings
	width = nema17_width;
	height = filament_offset[2] - body_thickness + 4;
	edge_radius = 27;
	hole_offsets = [-width / 2 + 4, width / 2 - 4];
	bearing_bottom = filament_offset[2] / 2 - body_thickness / 2 - 6;
	offset = drive_gear_hobbed_radius - drive_gear_tooth_depth + filament_diameter;
	pre_tension = 0.25;
	gap = 1;

	// base plate
	translate([0, 0, height / 2])
	difference()
	{
		union()
		{
			// base
			intersection()
			{
				cube([width, width, height], center = true);
				cylinder(r = edge_radius, h = height + 2 * epsilon, $fn = 128, center = true);
				translate([offset + 10.65 + gap, 0, 0])
					cube([15, nema17_width + epsilon, height], center = true);
			}
			
			// bearing foot enforcement
			translate([offset + 11 - pre_tension, 0, -height / 2])
				cylinder(r = 4 - extra_radius + 1, h = height - .5, $fn = 32);
			
			// spring base enforcement
			translate([17.15, -nema17_width / 2 + 4, .25])
				rotate([0, 90, 0])
					cylinder(r = 3.75, h = 4, $fn = 32);
		}

		translate([offset + 11 - pre_tension, 0, bearing_bottom])
			difference()
			{
				// bearing spare out
				cylinder(r = 11.5, h = 60, $fn = 32);
				
				// bearing mount
				cylinder(r = 4 - extra_radius, h = 7.5, $fn = 32);
				
				// bearing mount base
				cylinder(r = 4 - extra_radius + 1, h = 0.5, $fn = 32);
			}

		// bearing mount hole
		translate([offset + 11 - pre_tension, 0, 0])
			cylinder(r = idler_bearing_screw_hole_radius, h = 50, center = true, $fn = 32);

		// tensioner bolt slot
		translate([17.15, -nema17_width / 2 + 4, .25])
			rotate([0, 90, 0])
				rounded_slot(r = m3_wide_radius, h = 50, l = 1.5, center = true, $fn = 32);

		// fastener cutout
		translate([offset - 18.85 + gap, -20 ,0])
			cylinder(r = 27, h = height + 2 * epsilon, center = true, $fn = 32);

		// mounting hole
		translate([15.5, 15.5, 0])
		{
			cylinder(r = m3_wide_radius, h = height * 4, center = true, $fn = 16);
			cylinder(r = m3_head_radius, h = height + epsilon, $fn = 16);
		}

	}

	translate([offset + 11 - pre_tension, 0, filament_offset[2] - body_thickness])
		bearing_608zz();
}


// new idler with 608 bearing
module idler_608_v2()
{
	// settings
	width = nema17_width;
	height = filament_offset[2] - body_thickness + 4;
	edge_radius = 27;
	hole_offsets = [-width / 2 + 4, width / 2 - 4];
	bearing_bottom = filament_offset[2] / 2 - body_thickness / 2 - 6;
	offset = drive_gear_hobbed_radius - drive_gear_tooth_depth + filament_diameter;
	pre_tension = 0.25;
	gap = 1.25;
	top = 2;

	// base plate
	translate([0, 0, height / 2])
	difference()
	{
		union()
		{
			// base
			translate([0, 0, top / 2]) {
				intersection()
				{
					cube([width, width, height + top], center = true);
					cylinder(r = edge_radius, h = height + top + 2 * epsilon, $fn = 128, center = true);
					translate([offset + 10.65 + gap, 0, 0])
						cube([15, nema17_width + epsilon, height + top], center = true);
				}
				// idler handle
				translate([width / 2 - 8, -width / 2, -(height + top)/2])
					linear_extrude(height + top)
						polygon([[-1,5],[5,-10],[8,-10],[8,7]]);
			}
			
			// bearing foot enforcement
			translate([offset + 11 - pre_tension, 0, -height / 2])
				cylinder(r = 4 - extra_radius + 1, h = height - .5, $fn = 32);
			
			// spring base enforcement
			translate([17.15, -nema17_width / 2 + 4, .25])
				rotate([0, 90, 0])
					cylinder(r = 3.75, h = 4, $fn = 32);
		}

		translate([offset + 11 - pre_tension, 0, bearing_bottom])
			difference()
			{
				// bearing spare out
				cylinder(r = 11.5, h = 8, $fn = 32);
				
				// bearing mount
				cylinder(r = 4 - bearing_extra_radius, h = 8, $fn = 64);
				
				// bearing mount base
				cylinder(r = 4 - bearing_extra_radius + 1, h = 0.5, $fn = 64);
				
				// bearing mount top
				translate([0, 0, 7.5])
					cylinder(r = 4 - bearing_extra_radius + 1, h = 0.5, $fn = 64);
			}

		// bearing mount hole
		translate([offset + 11 - pre_tension, 0, 0])
			cylinder(r = idler_bearing_screw_hole_radius, h = 50, center = true, $fn = 32);

		// bearing mount hole
		translate([offset + 11 - pre_tension, 0, bearing_bottom + 4 - 0.1])
			cylinder(r = idler_bearing_screw_hole_radius2 + extra_radius, h = 20, $fn = 32);

		// tensioner bolt slot
		translate([17.15, -nema17_width / 2 + 4, .25])
			rotate([0, 90, 0])
				rounded_slot(r = m3_wide_radius, h = 50, l = 1.5, center = true, $fn = 32);

		// fastener cutout
		translate([offset - 18.85 + gap, -20, top / 2])
			cylinder(r = 27, h = height + top + 2 * epsilon, center = true, $fn = 32);

		// mounting hole
		translate([15.5, 15.5, 0])
		{
			cylinder(r = m3_wide_radius, h = height * 4, center = true, $fn = 16);
			translate([0, 0, height / 2 + top - idler_mount_hole_depth])
				cylinder(r = m3_head_radius, h = height + epsilon, $fn = 16);
		}

		// mounting hole radius
		rw = width / 2 - 15.5;
		rg = 15.5 - (offset + 10.65 + gap - 7.5);
		rcut = (rw > rg) ? rw : rg;
		translate([15.5, 15.5, -15])
			rotate([0, 0, 90])
				difference() {
					cube([50, 50, 30]);
					cylinder(r = rcut, h = 30, $fn = 32);
				}
	}

	translate([offset + 11 - pre_tension, 0, filament_offset[2] - body_thickness])
		%bearing_608zz();
}

module idler_cutter () {
	height = filament_offset[2] - body_thickness + 4;
	bearing_bottom = filament_offset[2] / 2 - body_thickness / 2 - 6;
	top = 2;

	union () {
		translate([0, 15.5 - 9, -1])
			cube([30, 18, (17.25 - body_thickness) / 2 + 1]);
		translate([0, -10, -1])
			cube([30, 19, bearing_bottom + height / 2 + 4 + 1]);
		translate([0, -nema17_width / 2 + 4 - 18, -1])
			cube([30, 26, height / 2 + 0.25 + 1]);
	}
}

// new idler splitted in printable parts
module idler_608_v2_splitted()
{
	
	intersection()
	{
		idler_608_v2();
		idler_cutter();
	}
	
	translate([nema17_width + 8, 0, filament_offset[2] - body_thickness + 4 + 2])
		rotate([0, 180, 0])
			difference()
			{
				idler_608_v2();
				idler_cutter();
			}
	
}


// compose all parts
module compact_extruder()
{
	// motor plate
	nema17_mount();

	// mounting plate
    if(( generate_holder) && (base_thickness != 0 )) {
        translate([-nema17_width / 2 - base_thickness, 0, base_width / 2])
            rotate([0, 90, 0])
                frame_mount();
    }

	// filament inlet/outlet
	translate([filament_offset[0], 0, body_thickness - epsilon])
		filament_tunnel();

	// drive gear
	color("grey")
		%translate([0, 0, body_thickness - 2.5])
			drive_gear();

	// filament
	color("red")
		%translate(filament_offset - [0, 0, epsilon])
			rotate([90, 0, 0])
				cylinder(r = filament_diameter / 2, h = 100, $fn = 16, center = true);
}

module pushfit_support () {
	pwr = pushfit_radius + pushfit_house_width;
	union () {
		linear_extrude(height = 2 * pwr, center = true)
			polygon(points=[
				[1, 0],
				[-pushfit_length_offset, 0],
				[-pushfit_length_offset, -pwr],
				[0, -pwr - pushfit_length_offset],
				[1, -pwr - pushfit_length_offset]
			]);
		translate([1, 0, 0]) {
			rotate([90, 90, 0])
				difference () {
					cylinder(r = pwr , h = pwr + pushfit_length_offset, $fn=32);
					translate([-pwr, -pwr, 0])
						cube([2 * pwr, pwr, pwr + pushfit_length_offset]);
				}
			rotate([0, -90, 0])
				sphere(r = pushfit_radius + pushfit_house_width, $fn=32);
			rotate([0, -90, 0])
				cylinder(r = pushfit_radius + pushfit_house_width, h = pushfit_depth + 1, $fn = 32);
		}
	}
}

//translate([-nema17_width / 2 - base_thickness, 0, base_width / 2]) rotate([0, 90, 0])
//    frame_mount();

//translate([20, 0, 0])
//	idler_608_v1();


module generate () {
	mirror([0,(direction_invert)?1:0,0]) {
		if (generate_extruder)
			difference() {
				compact_extruder();
				// drive_gear_hexscrew
				translate([nema17_width / 2 + epsilon, 0, filament_offset[2] + drive_gear_hobbed_offset - drive_gear_hexscrew_offset])
					rotate([90, 0, -90])
						cylinder(r = 2, h = nema17_width + base_thickness + 2 * epsilon, $fn = 16);
			}

		if (generate_idler)
			translate([20, 0, 0])
				idler_608_v2_splitted();
	}
}

generate();

// (c)2013 Pavel Suchmann <pavel@suchmann.cz>
// licensed under the terms of the GNU GPL version 3 (or later)

height = 7;
width = 4;
outer_radius = 38.5;
innner_radius = 33.5;
joint_radius = 15;
joint_y_ext = 2.2;
bar_x_shift = 3;
axis_radius = 1.1;
hole_radius = axis_radius + 0.2;
hole_with_border = hole_radius + 0.8;
through_len = (bar_x_shift + width) * 2.2;
stopper_height = 1.2;
stopper_width = 1.2;
width_half = width / 2;
inner_width = width_half * 1.3;
outer_bar_hole_z = height / 3.4;
ring_cube_y = width * 2.3;
stopper_y = 11.35;
stopper_z = -2.9;
$fn=200;

module ring(radius, h, shift=0) {
    translate([0, 0, shift]) {
        difference() {
            cylinder(h, radius+width_half, radius+width_half, center=true);
            union() {
                cylinder(h, radius-width_half, radius-width_half, center=true);
                for(angle = [0 : 45 : 315])
                    rotate([0, 0, angle]) 
                        translate([radius, 0, 0])
                            cube([through_len, ring_cube_y, h], center=true);
            }
        }
    }
    for(angle = [0 : 45 : 315]) // ring axes
        rotate([0, 0, angle])  
            translate([0, radius, 0])
                rotate([0, 90, 0])
                    cylinder(through_len, axis_radius, axis_radius, center=true);  
}

module moveable(angle=0) {
  rotate([0, 0, angle]) {
    
    // outer bars
    outer_bar_len = outer_radius - joint_radius + hole_with_border*2 + joint_y_ext;
    outer_bar_y_shift = joint_radius-hole_with_border+outer_bar_len/2 - joint_y_ext;
    difference() {
        union () { 
            // bars
            translate([bar_x_shift, outer_bar_y_shift, -width_half/4])
                cube([width_half, outer_bar_len, height-width_half/2], center=true);
            translate([ -bar_x_shift, outer_bar_y_shift, -width_half/4])
                cube([width_half, outer_bar_len, height-width_half/2], center=true);
            // softer edges
            translate([bar_x_shift, outer_bar_y_shift/2-joint_y_ext, (height-width_half)/2]) 
                rotate([-90, 0, 0])
                    cylinder(outer_bar_len, width_half/2, width_half/2);
            translate([ -bar_x_shift, outer_bar_y_shift/2-joint_y_ext, (height-width_half)/2]) 
                rotate([-90, 0, 0])
                    cylinder(outer_bar_len, width_half/2, width_half/2);
        }
        union() { // holes
            translate([0, outer_radius, 0]) 
                rotate([0, 90, 0])
                    cylinder(through_len, hole_radius, hole_radius, center=true);
            translate([0, innner_radius, outer_bar_hole_z])
                cube([through_len, 2*hole_with_border, height], center=true);
        }
    } 
    
    // stopper
    translate([0, stopper_y, stopper_z])    
        cube([width*2, stopper_width, stopper_height], center=true); 
    
    // inner bar
    inner_bar_len = innner_radius - joint_radius + hole_with_border*2;
    difference() {
        translate([0, joint_radius-hole_with_border+inner_bar_len/2, -stopper_height/2])
            cube([inner_width, inner_bar_len, height - stopper_height], center=true);

        union() { // holes
            translate([0, innner_radius, 0])
                rotate([0, 90, 0])
                    cylinder(width*2, hole_radius, hole_radius, center=true);
            translate([0, joint_radius, 0])
                rotate([0, 90, 0])
                    cylinder(width*2, hole_radius, hole_radius, center=true);
        }
    }

    // joint axis
    translate([0,joint_radius,0])
        rotate([0, 90, 0])
            cylinder(width, axis_radius, axis_radius, center=true);
            
  }
}

// outer ring
ring(outer_radius, height);

// inner ring
ring(innner_radius, height);

// bars
for(angle = [0 : 45 : 315])
    moveable(angle);

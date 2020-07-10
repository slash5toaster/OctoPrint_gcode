$fn=50;

top=true;
//top=false;

side=100;
face_h=side*sqrt(3)/2;
face_center=face_h*2/3;
thick=8;
channel_w=1;
channel_h=4;
hole_d=1;

//60% diameter of an inscribed circle
channel_d=thick*sqrt(3)/3*0.6;
//channel_d=thick/3;


tetrahedron_h=sqrt(6)/3 * side;
face_angle=acos(1/3);
edge_angle=acos(1/sqrt(3));

//base_h=thick/2*tan(face_angle);
base_h=thick*sin(face_angle);
base_w=thick*cos(face_angle)*2;

//marker for center of triangle
//%translate([0, 0, tetrahedron_h]) color("green") circle(0.5);

module base_triangle() {
   polygon([[0,-face_center], [-side/2,face_h/3], [side/2,face_h/3]]);
}

module base_tetrahedron() {
   linear_extrude(tetrahedron_h, scale=0)
      base_triangle();
}

module base_3d() {
   difference() {
      base_tetrahedron();
      translate([0,0,base_h*2]) union() {
         mirror([0,0,1]) base_tetrahedron();
         translate([0,0,side-0.01]) cube(side*2, center=true);
      }
   }
   
}

module skew_y(angle) {
   M=[
      [ 1, 0, 0, 0 ],
      [ 0, 1, tan(angle), 0 ],
      [ 0, 0, 1, 0 ],
      [ 0, 0, 0, 1 ]
   ];
   multmatrix(M) children();
}

module post_2d(e) {
   h=e*sqrt(3)/2;
   //translate([0,-face_center])
   difference() {
      translate([0,-h*2/3,0]) polygon([[0,0], [-e/2,h], [e/2,h]]);
      //TODO: move hole out of this module?
      if (!top) {
         circle(d=channel_d, $fn=6);
      }
   }
}

module post_3d() {
   post_h=thick*sqrt(3)/2;
   post_center=post_h*2/3;
   off=-face_center + post_center;

   twist_r=15;

   difference() {
      skew_y(90-edge_angle)
      translate([0,off,0]) union() {
         linear_extrude(base_h,convexity=5)
            post_2d(thick);
         translate([0,0,base_h])
            //skew_y(-atan(2*twist_r/(tetrahedron_h-base_h)))
            //put the center of the post at the top
            skew_y(-atan(post_center/(tetrahedron_h-base_h)))
            translate([0,twist_r,0])
            linear_extrude(tetrahedron_h-base_h, twist=360, slices=200,convexity=5)
            translate([0,-twist_r,0])
            post_2d(thick);
      }
      
      //translate([-face_h,face_h/3,0]) rotate([90-face_angle,0,0]) cube(face_h*2);
   }
}

module tetra() {
   base_3d();
   post_3d();
}


module hole_midpoint() {
   translate([0,face_h/3-base_w/2,0]) cylinder(d=hole_d,h=base_h);
}

module hole_vertex(d=hole_d, h=base_h*2) {
   translate([0,-face_center+base_w/sin(30)/2,0]) cylinder(d=d,h=h);
}

module channels_bottom() {
   /*
   difference() {
      translate([0,0,-base_h+channel_w]) base_3d();
      translate([0,0,-side]) cube(side*2, center=true);
   }
   */
   linear_extrude(channel_h) difference() {
      offset(-base_w/2+channel_w/2) base_triangle();
      offset(-base_w/2-channel_w/2) base_triangle();
   }

   //notches
   #translate([0,0,1]) {
      for (a=[0:120:240])
         rotate([0,0,a])
         translate([0,channel_w,0]) hole_vertex(d=channel_w*2, h=channel_h-1);
   }
}


module holes_bottom() {
   for (a=[0:120:240])
      rotate([0,0,a])
      hole_midpoint();
}

module channels_top() {
   difference() {
      translate([0,0,base_h-channel_h])
         linear_extrude(channel_h/3) difference() {
         offset(-base_w/2+channel_w/2) base_triangle();
         offset(-base_w/2-channel_w/2) base_triangle();
      }
   }
}

module holes_top() {
   for (a=[0:120:240])
      rotate([0,0,a])
      translate([0,0,base_h-channel_h])
      hole_vertex(d=hole_d*2);
}

module post_channel() {
   post_h=thick*sqrt(3)/2;
   post_center=post_h*2/3;

   skew_y(atan(post_center/base_h))
      hole_vertex(d=channel_d, h=base_h, $fn=6);

   //disabled for now, since channel is made during extrusion
   *skew_y(90-edge_angle)
      translate([0,-face_center+post_center,base_h])
      cylinder(h=tetrahedron_h-base_h,d=channel_d,$fn=6);

}

module post_hole() {
   translate([0, 0, tetrahedron_h-thick*2]) cylinder(d=hole_d,h=thick*2);
}

//cut channels for the fishing line
difference() {
   tetra();
   if (!top) {
      channels_bottom();
      holes_bottom();
      post_channel();
   } else {
      channels_top();
      holes_top();
   }

   post_hole();
}

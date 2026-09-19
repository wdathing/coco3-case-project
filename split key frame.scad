$fn = 50;

box_width = 334;
box_depth = 155;
front_height = 14.7;
slope_angle = 15;
wall_thickness = 3;
corner_radius = 8;
grill_enabled = true;

left_right_support = 30;
front_back_support = 20;

pcb_width = 316;
pcb_depth = 124;
pcb_recess = 12;

pin_sd = 5;
pin_wd = 7;
pin_tol = 0.12;


base_plate_thickness = 2 + 2 + 1;

rear_height = front_height + tan(slope_angle) * (box_depth-2*corner_radius);

keyb_pcb_left_edge = (box_width - pcb_width) / 2;
keyb_pcb_right_edge = keyb_pcb_left_edge + pcb_width;

module grill(g_x, g_y, width, slots)
{
    grill_slot_width = 30;
    grill_slot_height = 30;
    grill_slot_spacing = 20;
    grill_z = -60;
    grill_x_start = 10;

    // grill slots with rounded ends
    spacing = grill_slot_width + grill_slot_spacing ;
    for (y = [g_y : spacing : g_y + spacing * slots]) 
    {
        // vertical slot body
        hull()
        {
        //translate([g_x+grill_slot_width/5, y, grill_z])
        //rotate([-slope_angle, 0, 0])
        //cube([width, grill_slot_width, 400]);

        // rounded ends (top and bottom)
        translate([g_x, y+grill_slot_width/2, grill_z])
            rotate([-slope_angle, 00, 0])
                cylinder(h = 100, d = grill_slot_width);

        translate([g_x + width,  y+grill_slot_width / 2, grill_z])
            rotate([-slope_angle, 0, 0])
                cylinder(h = 100, d = grill_slot_width);
        }
    }
}

module hollow_int(offset_hollow_x=0)
{
    translate([offset_hollow_x,0,0])
    translate([left_right_support, front_back_support, base_plate_thickness])
        hull() {
            // front left corner
            translate([corner_radius - 10, corner_radius, 0])
                cylinder(h = rear_height, r = corner_radius - wall_thickness);
            // front right
            translate([box_width/2 - 2 * left_right_support - corner_radius+10, corner_radius, 0])
                cylinder(h = rear_height, r = corner_radius - wall_thickness);
            translate([corner_radius - 10, box_depth - front_back_support - corner_radius - 20, 0])
                cylinder(h = rear_height, r = corner_radius - wall_thickness);
            translate([box_width/2 - 2 * left_right_support - corner_radius + 10, box_depth - front_back_support - corner_radius - 20, 0])
                cylinder(h = rear_height, r = corner_radius - wall_thickness);
        }
}

// original full box module
module full_shell(cut_left=true, pins_and_holes=false) {
    slide_back = 4;
    rotate([-slope_angle, 0, 0])
    difference() {
        // Outer shell
        hull() {
            translate([corner_radius, corner_radius, 0])
                cylinder(h = front_height, r = corner_radius);
            translate([box_width - corner_radius, corner_radius, 0])
                cylinder(h = front_height, r = corner_radius);
            translate([corner_radius, box_depth - corner_radius, 0])
                cylinder(h = rear_height, r = corner_radius);
            translate([box_width - corner_radius, box_depth - corner_radius, 0])
                cylinder(h = rear_height, r = corner_radius);
        }

        // Hollow interior
        hollow_int();
        hollow_int(box_width/2);
        
        // PCB recess
        //if (0)
        rotate([slope_angle, 0, 0])
        translate([
            keyb_pcb_left_edge,
            (box_depth - pcb_depth ) / 2+slide_back,
            0 //rear_height - pcb_recess - 34
        ])
            cube([pcb_width, pcb_depth, rear_height]);
        
        // underside metal lip on stock keyb
        translate([
            keyb_pcb_left_edge,
            (box_depth - pcb_depth ) / 2 + slide_back+4.5,
            //rear_height - pcb_recess - 6
            6
        ])
            rotate([slope_angle, 0, 0])
            {
                //cube([pcb_width, 3, 100]);
                rotate([0,90,0])
                    cylinder(h=pcb_width, d=4);
                rotate([0,90,0])
                translate([0,114.5,0])
                    //cube([pcb_width, 3, 100]);
                    
                    cylinder(h=pcb_width, d=4);
            }
        
        
        // make room for ribbon cable off keyboard
        {
            ribbon_w = 66;
            ribbon_vert = 18;
            ribbon_x = (box_width - ribbon_w) / 2;
            ribbon_y = box_depth - wall_thickness - 0.1 - 16;
            ribbon_z = rear_height - 24;
            translate([ribbon_x, box_depth-71-3, ribbon_z-1.6])
                cube([ribbon_w, 70.8, ribbon_vert]);  
            translate([ribbon_x, box_depth-70.8-1, ribbon_z-1.6-12])
                cube([ribbon_w, 70.8-8, ribbon_vert]);  

        }

        // USB passthrough (right half only)
        //if (!cut_left) 
        {
            usb_w = 66;
            usb_h = 20;
            usb_vert = 13;
            usb_x = (box_width - usb_w) / 2;
            usb_y = box_depth - wall_thickness - 0.1 - 15;
            usb_z = base_plate_thickness-1*1.6;

            // back panel cutout
            translate([usb_x, box_depth-70.8-1, usb_z-1.6])
                cube([usb_w, 68, 15]);  
            
            // recess for controller pcb... brought in a bit to make a lip
            translate([usb_x, usb_y-10, usb_z])
                cube([usb_w, 50, usb_vert]); 
        }

        // cutouts in the angled PCB plane
        //rotate([slope_angle, 0, 0])
        {
            // rear_height = front_height + tan(slope_angle) * box_depth;
            promicro_x = 16;
            // promicro_y = (box_depth - 45)/2-3;
            promicro_y = (box_depth - 45)/2-3;
            promicro_z = 6;// + tan(slope_angle) * 15;
            promicro_w = 24;
            promicro_d = 50;
            promicro_height = 20;
            
            // Clearance cutout on left interior support wall
            translate([promicro_x-7, promicro_y+slide_back+1, promicro_z-1])  // centered vertically on the left side
                rotate([slope_angle, 0, 0])
                    cube([promicro_w, promicro_d-5, promicro_height-2]);  // 25mm wide (x), 45mm deep (y), 15mm tall (z)

            if (0)
            // piano switch cutout
            translate([0, promicro_y+2+slide_back, promicro_z])  // centered vertically on the left side
                rotate([slope_angle, 0, 0])
                    cube([promicro_w, promicro_d-6, 10]);  // 25mm wide (x), 45mm deep (y), 15mm tall (z)

            
            
            // Clearance cutout on left interior support wall  smaller higher shelf
//            translate([promicro_x-7, promicro_y+slide_back, promicro_z+8.5])  // centered vertically on the left side
//                rotate([slope_angle, 0, 0])
//                    cube([promicro_w, promicro_d-6, 5]);  // 25mm wide (x), 45mm deep (y), 15mm tall (z)

            // Clearance cutout on right washers
            
            // front
            translate([keyb_pcb_right_edge-6.5, promicro_y-7+slide_back, promicro_z+2])  // centered vertically on the left side
                rotate([slope_angle, 0, 0])
                    cylinder(d=12, h=20);  // 25mm wide (x), 45mm deep (y), 15mm tall (z)
            
            // back
            translate([keyb_pcb_right_edge-6.5, promicro_y+promicro_d+slide_back, promicro_z+promicro_height-3
            ])  // centered vertically on the left side
                rotate([slope_angle, 0, 0])
                    cylinder(d=12, h=20);  // 25mm wide (x), 45mm deep (y), 15mm tall (z)


            // left side
            
            // Clearance cutout on left washers
            
            // front
            translate([promicro_x-0.5, promicro_y-7+slide_back, promicro_z+2])  // centered vertically on the left side
                rotate([slope_angle, 0, 0])
                    cylinder(d=11, h=20);  // 25mm wide (x), 45mm deep (y), 15mm tall (z)
            
            // back
            translate([promicro_x-0.5, promicro_y+promicro_d+slide_back+1, promicro_z+promicro_height-3
            ])  // centered vertically on the left side
                rotate([slope_angle, 0, 0])
                    cylinder(d=12, h=20);  // 25mm wide (x), 45mm deep (y), 15mm tall (z)            
        }


        
        // Cut the unwanted half
        if (cut_left) {
            
            //translate([box_width / 2 - 0, box_depth -11 + pin_tol, 0])
            // hole for pin
            if (pins_and_holes)
            translate([box_width / 2, box_depth - 8, 20])
                rotate([0,-90,0])
                    cylinder(h=25+pin_tol,d1=pin_wd+pin_tol, d2=pin_sd+pin_tol);            
            
            // Remove right half
            translate([box_width / 2, -10, -50])
                cube([box_width, box_depth + 20, rear_height + 100]);

            // add some holes for pins
//            translate([box_width / 2+20, -10, -50])
//                cylinder(h=20,d1=10,d2=12);
            
        } else {
            // Remove left half
            translate([-10, -10, -50])
                cube([box_width / 2 + 10, box_depth + 20, rear_height + 100]);
            
            if(pins_and_holes)
            {
                // holes for pins
                // front
                translate([box_width / 2 + 25, 10, 6])
                    rotate([0,-90,0])
                        cylinder(h=25,d1=pin_sd+pin_tol, d2=pin_wd+pin_tol);
                
                // upper back
                translate([box_width / 2 -0.05, box_depth-9, 45])
                    rotate([0,90,0])
                        cylinder(h=25,d1=pin_wd+pin_tol, d2=pin_sd+pin_tol);
            }
            
        }
        // grills
        grill(35 + 10, front_back_support, 70, 1);        
        grill(box_width / 2 + 35 + 20, front_back_support, 70, 1);        

    }
    // add some pins and holes
    if (pins_and_holes)
    {
        if (cut_left) 
        {
            // add some pins
            // front 
            translate([box_width / 2, 11, 3])
                rotate([0,90,0])
                    cylinder(h=25,d1=pin_wd, d2=pin_sd);
            // upper back
            translate([box_width / 2, box_depth-2, 7])
                rotate([0,90,0])
                    cylinder(h=25,d1=pin_wd, d2=pin_sd);

        }
        else
        {
            
            // mid back pin
            translate([box_width / 2, box_depth - 8, -17])
                rotate([0,-90,0])
                    cylinder(h=25,d1=pin_wd, d2=pin_sd);            
        }
        
       
    }
    
}

// Render halves individually
// Comment/uncomment as needed for printing

full_shell(true);  // left half
//
translate([-0.01,0,0])
  full_shell(false);  // right half with USB hole

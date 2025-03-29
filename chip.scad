$fa=5;
$fs=.1;

// Standard "chipfinity" dimensions
chip_width = 17;
chip_height = 13;
chip_depth = 2;
chip_corner_radius = 0.5;

// locking tabs
chip_tab_radius = 0.5;
chip_tab_extend = 0.0;
chip_tab_offset = 2;

chip_level_2_inset = 0.5;
chip_level_2_height = 0.6;
chip_level_2_extra = 1;

text_area_factor = 0.9;
text_emboss = .25 * 2;

module chip_base() {

hull()
for (x = [chip_corner_radius, chip_width-chip_corner_radius]) {
  for (y = [chip_corner_radius, chip_height-chip_corner_radius]) {
  translate([x, y, 0]) 
    cylinder(r=chip_corner_radius, h=chip_depth);
}};
}



module cutting_tool_2d(width, h1, h2, extra) {
  polygon([
    [0, 0],
    [width + extra, 0],
    [width + extra, h1 + extra],
    [extra, extra + h2],
    [0, extra + h2],
  ]);
}

module cutting_tool_2d_chip() {
  cutting_tool_2d(
    width=chip_level_2_inset,
    h1=chip_level_2_height,
    h2=chip_depth - chip_level_2_height,
    extra=chip_level_2_extra
  );
}

module chip_level_2_linear_cutter(h) {
  rotate([-90, 0, 0])
    linear_extrude(h) 
      cutting_tool_2d_chip();
}

module level2_radial_cutter() {
  translate([0 ,0 ,chip_depth + chip_level_2_extra]) 
    rotate([0,180,90]) 
      rotate_extrude(90) 
        translate([chip_level_2_extra + chip_level_2_inset, 0, 0])
          rotate([0, 180, 00])
            cutting_tool_2d_chip();
}



module level2_cutter() {
translate([chip_corner_radius, chip_height+ chip_level_2_extra, chip_depth + chip_level_2_extra])
rotate([0, 0, -90])
  chip_level_2_linear_cutter(chip_width - chip_corner_radius*2);

translate([chip_width-chip_corner_radius, -chip_level_2_extra, chip_depth + chip_level_2_extra])
rotate([0, 0, 90])
  chip_level_2_linear_cutter(chip_width - chip_corner_radius*2);


translate([-chip_level_2_extra, chip_corner_radius, chip_depth + chip_level_2_extra])
  chip_level_2_linear_cutter(chip_height - chip_corner_radius*2);

translate([chip_width+chip_level_2_extra, chip_height - chip_corner_radius, chip_depth + chip_level_2_extra])
rotate([0, 0, 180])
  chip_level_2_linear_cutter(chip_height - chip_corner_radius*2);


translate([chip_level_2_inset ,chip_level_2_inset, 0]) 
level2_radial_cutter();

translate([chip_level_2_inset, chip_height-chip_level_2_inset, 0])
rotate([0,0,-90]) 
  level2_radial_cutter();

translate([-chip_level_2_inset + chip_width, chip_level_2_inset, 0])
rotate([0,0,90]) 
  level2_radial_cutter();

translate([-chip_level_2_inset + chip_width, chip_height - chip_level_2_inset, 0])
rotate([0,0,180]) 
  level2_radial_cutter();

};

module chip() {
  difference() {
  chip_base();
  level2_cutter();
  }

  hull(){
    translate([chip_tab_radius-chip_tab_extend,chip_tab_offset,0]) 
    cylinder(r=chip_tab_radius, h = chip_depth);

    translate([chip_width-chip_tab_radius+chip_tab_extend,chip_tab_offset,0]) 
    cylinder(r=chip_tab_radius, h = chip_depth);
    }
}


module text_chip_old(s, font = "Noto Sans:style=Bold") {
  chip();
  text_width = (chip_width - chip_level_2_inset*2) * text_area_factor;
  text_height = (chip_height - chip_level_2_inset*2) * text_area_factor;

  translate([chip_width/2,chip_height / 2,chip_depth]) 
  color([.2,.2,.2])
  resize([text_width, text_height,text_emboss])
  linear_extrude(text_emboss)
  text(s,
    halign="center",
    valign="center",
    font = font
    );
}


// TODO keep_aspect_ratio is a lie, it just squishes into a square
module chip_2d(keep_aspect_ratio = true) {
  chip();
  width_area = (chip_width - chip_level_2_inset*2) * text_area_factor;
  height_area = (chip_height - chip_level_2_inset*2) * text_area_factor;
  min_area = min(width_area, height_area);
  resize_x = keep_aspect_ratio ? min_area: width_area;
  resize_y = keep_aspect_ratio ? min_area: height_area;

  translate([chip_width/2,chip_height / 2,chip_depth]) 
  color([.2,.2,.2])
  resize([resize_x, resize_y,text_emboss])
  linear_extrude(text_emboss)
    children();
}

module chip_3d() {
  chip_2d()
    projection()
      children();
}


module text_chip(s, font = "Noto Sans:style=Bold") {
  chip_2d(keep_aspect_ratio = false)
    text(s,
      halign="center",
      valign="center",
      font = font
      );
}

chip_3d() {
  cube(1, center = false);
  sphere(1);
}


chips = ["", "\u03a9", "123457", "Scott", "M8", "1M\u03a9"];
// chips = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
// chips = ["1", "2", "3", "4", "5", "6", "7", "8"];
// chips = ["1", "2", "3", "4", "5", "6", "7"];
// chips = ["1", "2", "3", "4", "5", "6"];
// chips = ["1", "2", "3", "4", "5"];
// chips = ["1", "2", "3", "4"];
// chips = ["1", "2", "3"];
// chips = ["1", "2"];
// chips = ["1"];

gridwidth = floor(sqrt(len(chips)) + .5);
for (i = [0 : len(chips) - 1]) {
  x = i % gridwidth;
  y = floor(i / gridwidth);
  s = chips[i];
  translate([x *(chip_width+2), y * (chip_height + 2), 0])
  text_chip(s);
}



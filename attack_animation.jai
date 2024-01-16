// This whole thing is run each frame in the rendering loop of the game.
//
// https://easings.net/ to grab the easing funcs
//
// (pseudocode)

en: *Entity; // this is just the player
held_item := just_some_other_structure_i_have_for_storing_item_data;
length := 0.2;

do_flip := en.x_dir == -1; // for flipping around on the X when the player turns around to move the other way
is_up := en.attack_count % 2 == 0; // up and down flip flop. Incremeted for every attack.

// attack_timer plays out for something like 200ms
// the timer_alpha just maps 0 -> 200ms down to a 0.0 -> 1.0
// now we've basically got the progress of the attack animation (which I like to call the alpha)
alpha := timer_alpha(en.attack_timer, length);

xform := Matrix4_Identity;

// the pivot point of all of this starts at the base of the player.
// + 18.0 to get up to the chest-ish area
xform *= xform_translate(.{en.pos.x, 18.0});

// X flip. Self explanatory.
if do_flip then xform *= make_scale_matrix4(xyz(-1, 1, 1));
  
// Y flip flop
if !is_up then xform *= make_scale_matrix4(xyz(1, -1, 1));

// rotate the arm, around the torso centrepoint
arm_rotation := 160.0 + (1.0-ease_out_back(alpha)) * -90.0;
if !is_up then arm_rotation += 35.0; // if we're down, do a bit more of a rotation since it looks better
xform *= xform_rotate(arm_rotation);

// this gives us our radius of 8.0 for the rotation above
xform *= xform_translate(xy(0.0, -8.0));

// now we rotate the grip
grip_rotation := (1.0-ease_out_circ(alpha)) * -90.0;
xform *= xform_rotate(grip_rotation);

// apply a grip rotation and translation for each item. That way we can have every item coming from a nice pivot point where the grip should be.
xform *= xform_rotate(-held_item.grip_rotation);
xform *= xform_translate(-held_item.grip_offset);

// go behind the player when up
z_layer := Z_PLAYER + ifx is_up then 0.1 else -0.1;

// DRAAAAAAAAAAAAAAW
draw_sprite_with_transform(held_item.id, xform, z_layer=z_layer);
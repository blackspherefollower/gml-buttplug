/// @description Insert description here
// You can write your code in this editor
if keyboard_check(vk_up)
{
        motion_add(image_angle, 0.1);
}
if keyboard_check(vk_left)
{
        image_angle += 4;
}
if keyboard_check(vk_right)
{
        image_angle -= 4;
}
move_wrap(true, true, 0)

if mouse_check_button_pressed(mb_left)
{
        instance_create_layer(x, y, "Instances", obj_bullet)
}
if keyboard_check(vk_tab)
{
	try{
        obj_buttplug_client.connect("ws://127.0.0.1:12345/buttplug")
	} catch (_e) {
		show_debug_message("Error: {0}", _e)
	}
}
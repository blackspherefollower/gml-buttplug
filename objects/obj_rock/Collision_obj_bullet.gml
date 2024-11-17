/// @description Insert description here
// You can write your code in this editor

instance_destroy(other);
effect_create_above(ef_explosion, x, y, 1, c_white);

direction = random(360);

if sprite_index == spr_rock_big
{
        sprite_index = spr_rock_small;
        instance_copy(true);
		obj_buttplug_client.vibrate(1.0)
		obj_buttplug_client.alarm[0] = 120;
}
else if instance_number(obj_rock) < 12
{
        sprite_index = spr_rock_big;
        x = -100;
		obj_buttplug_client.vibrate(0.5)
		obj_buttplug_client.alarm[0] = 120;
}
else
{
        instance_destroy();
}
obj_game.points += 50;
/// @description Insert description here
// You can write your code in this editor
var _event = async_load;
switch(_event[? "type"]) {
case network_type_connect:
case network_type_non_blocking_connect:
	show_debug_message("in connected callback {0}", async_load)
	if( _event[? "succeeded"] ) {
		var json = json_stringify([
		  {
		    "RequestServerInfo": {
		      "Id": int64(msgid++),
		      "ClientName": "Test Client",
		      "MessageVersion": int64(3)
		    }
		  }
		])
		var _buffer = buffer_create(256, buffer_grow, 1);
		buffer_write(_buffer, buffer_string, json);
		network_send_raw(socket, _buffer, buffer_tell(_buffer)-1, network_send_text)
	}
	else
	{
		state = buttplug_disconnected
		network_destroy(socket)
	}
		
	break;
	
case network_type_data:
	var _json = buffer_read(_event[? "buffer"], buffer_string)
	show_debug_message("in data callback {0} {1}", json_stringify(_event), _json)
	var _data = json_parse(_json)
	var _len = array_length(_data)
	for(var i = 0; i < _len; i++ ) {
		if(_data[i][$ "ServerInfo"]) {
			// Got server info - get initial device list
			var json = json_stringify([
			  {
			    "RequestDeviceList": {
			      "Id": int64(msgid++)
			    }
			  }
			])
			var _buffer = buffer_create(256, buffer_grow, 1);
			buffer_write(_buffer, buffer_string, json);
			network_send_raw(socket, _buffer, buffer_tell(_buffer)-1, network_send_text)
		} else if(_data[i][$ "DeviceList"]) {
			// Got initial device list
			devices = _data[i][$ "DeviceList"][$ "Devices"]
			
			if( state == buttplug_connecting ) {
				state = buttplug_connected
				// callbacks.connected() //ToDo calbacks
			}
		} else if(_data[i][$ "DeviceAdded"]) {
			var _dcount = array_length(devices)
			var _d = 0
			for( ; _d < _dcount; _d++ )
			{
				if( devices[_d][$ "DeviceIndex"] == _data[i][$ "DeviceAdded"][$ "DeviceIndex"] ) {
					// match
					 devices[_d][$ "DeviceName"] = _data[i][$ "DeviceAdded"][$ "DeviceName"]
					 devices[_d][$ "DeviceMessages"] = _data[i][$ "DeviceAdded"][$ "DeviceMessages"]
					break
				}
			}
			if( _d == _dcount )
			{
				array_push(devices, {"DeviceIndex": _data[i][$ "DeviceAdded"][$ "DeviceIndex"], "DeviceName": _data[i][$ "DeviceAdded"][$ "DeviceName"], "DeviceMessages": _data[i][$ "DeviceAdded"][$ "DeviceMessages"]})
			}
		}  else if(_data[i][$ "DeviceRemoved"]) {
			var _dcount = array_length(devices)
			var _d = 0
			for( ; _d < _dcount; _d++ )
			{
				if( devices[_d][$ "DeviceIndex"] == _data[i][$ "DeviceAdded"][$ "DeviceIndex"] ) {
					array_delete(devices, _d, 1)
					break
				}
			}
		} 
	}
	
	break;
	
case network_type_disconnect:
	show_debug_message("in disconnected callback {0}", json_stringify(_event))
	state = buttplug_disconnected
	network_destroy(socket)
	break;
}

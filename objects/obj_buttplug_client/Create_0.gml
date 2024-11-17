buttplug_disconnected = int64(0);
buttplug_connecting = int64(1);
buttplug_connected = int64(2);

state = buttplug_disconnected
msgid =  int64(1)
devices = []


function connect(url) {
	if( state != buttplug_disconnected ) 
	{
		throw( "Buttplug Client not disconnected!")
	}
	state = buttplug_connecting
	msgid =  int64(1)
	devices = []
	socket = network_create_socket(network_socket_ws)
	network_connect_raw_async(socket, url, 0); // port not needed for WS
}

function get_devices() {
	if( state != buttplug_connected ) 
	{
		throw( "Buttplug Client not connected!")
	}
	return devices
}

function vibrate(_speed) {
	if( state != buttplug_connected ) 
	{
		throw( "Buttplug Client not connected!")
	}
	if(_speed < 0.0 || _speed > 1.0 ) 
	{
		throw( "Vibration speed must be in the range 0.0-1.0!")
	}
	
	var _dcount = array_length(devices)
	for(var _i = 0; _i < _dcount; _i++ ) {
	   var _msgs = devices[_i][$ "DeviceMessages"]
	   if( !is_undefined(_msgs) && is_array(_msgs[$ "ScalarCmd"]) )
	   {
		   var _scalar_cmds = []
			var _scalars =_msgs[$ "ScalarCmd"]
			var _scount = array_length(_scalars)
			for(var _s = 0; _s < _scount; _s++ ) {
				if( _scalars[_s][$ "ActuatorType"] == "Vibrate" ) {
					array_push(_scalar_cmds, { "Index": int64(_s), "Scalar": _speed, "ActuatorType":"Vibrate"})
				}	
			}
			
			var json = json_stringify([
			  {
			    "ScalarCmd": {
			      "Id": int64(msgid++),
				  "DeviceIndex": int64(devices[_i][$ "DeviceIndex"]),
				  "Scalars": _scalar_cmds
			    }
			  }
			])
			var _buffer = buffer_create(256, buffer_grow, 1);
			buffer_write(_buffer, buffer_string, json);
			network_send_raw(socket, _buffer, buffer_tell(_buffer)-1, network_send_text)
	   }
	}
}